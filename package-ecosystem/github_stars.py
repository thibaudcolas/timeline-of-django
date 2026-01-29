#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "duckdb>=1.0.0",
# ]
# ///

import json
import re
import subprocess
import sys
from collections.abc import Iterator

import duckdb

DB_PATH = "all_pkg.duckdb"
PARQUET_PATH = "all_pkg.parquet.zst"
BATCH_SIZE = 100


def extract_github_repo(home_page: str | None, project_urls: str | None) -> str | None:
    """Extract GitHub org/repo from home_page or project_urls."""
    pattern = r"github\.com/([a-zA-Z0-9_.-]+)/([a-zA-Z0-9_.-]+)"
    
    for url in [home_page, project_urls]:
        if url:
            match = re.search(pattern, url)
            if match:
                owner, repo = match.groups()
                repo = repo.rstrip("/").removesuffix(".git")
                return f"{owner}/{repo}"
    return None


def extract_failed_repo_from_error(stderr: str) -> str | None:
    """Extract the failed repo name from GitHub API error message."""
    match = re.search(
        r"Could not resolve to a Repository with the name '([^']+)'", stderr
    )
    return match.group(1) if match else None


def run_graphql_query(
    repos: list[tuple[str, str]],
) -> tuple[dict[str, int | None], str | None]:
    """Run a GraphQL query for the given repos."""
    if not repos:
        return {}, None

    # Build GraphQL query with aliases
    query_parts = []
    alias_to_package = {}
    
    for i, (package_name, repo) in enumerate(repos):
        owner, name = repo.split("/", 1)
        alias = f"repo{i}"
        alias_to_package[alias] = package_name
        query_parts.append(
            f'  {alias}: repository(owner: "{owner}", name: "{name}") {{\n'
            f"    stargazerCount\n"
            f"  }}"
        )

    query = "{\n" + "\n".join(query_parts) + "\n}"

    try:
        result = subprocess.run(
            ["gh", "api", "graphql", "-f", f"query={query}"],
            capture_output=True,
            text=True,
            check=False,
        )

        if result.returncode != 0:
            failed_repo = extract_failed_repo_from_error(result.stderr)
            if failed_repo:
                return {}, failed_repo
            print(
                f"    Warning: GraphQL query failed: {result.stderr[:200]}",
                file=sys.stderr,
            )
            return {pkg: None for pkg, _ in repos}, None

        data = json.loads(result.stdout)
        results = {}
        
        for alias, package_name in alias_to_package.items():
            repo_data = data.get("data", {}).get(alias)
            results[package_name] = repo_data.get("stargazerCount") if repo_data else None

        return results, None

    except (json.JSONDecodeError, subprocess.SubprocessError) as e:
        print(f"    Error fetching stars: {e}", file=sys.stderr)
        return {pkg: None for pkg, _ in repos}, None


def fetch_stars_batch(repos: list[tuple[str, str]]) -> dict[str, int | None]:
    """Fetch star counts for a batch of repos using GitHub CLI GraphQL API."""
    if not repos:
        return {}

    remaining_repos = list(repos)
    all_results: dict[str, int | None] = {}
    failed_repos: set[str] = set()

    while remaining_repos:
        results, failed_repo = run_graphql_query(remaining_repos)

        if failed_repo:
            # A specific repo failed - exclude it and retry
            failed_repos.add(failed_repo)
            # Find and remove the failed repo from remaining
            new_remaining = []
            for pkg, repo in remaining_repos:
                if repo == failed_repo:
                    all_results[pkg] = None  # Mark as failed
                    print(f"    Skipping unavailable repo: {repo}")
                else:
                    new_remaining.append((pkg, repo))
            remaining_repos = new_remaining
        else:
            # Success or unrecoverable error - merge results and finish
            all_results.update(results)
            break

    return all_results


def batched(iterable: list, n: int) -> Iterator[list]:
    """Yield successive n-sized chunks from iterable."""
    for i in range(0, len(iterable), n):
        yield iterable[i : i + n]


def main():
    print(f"Connecting to {DB_PATH}...")
    con = duckdb.connect(DB_PATH)

    # Check if all_pkg table exists, if not create from parquet
    tables = con.execute("SHOW TABLES").fetchall()
    table_names = [t[0] for t in tables]

    if "all_pkg" not in table_names:
        print(f"Creating all_pkg table from {PARQUET_PATH}...")
        con.execute(f"CREATE TABLE all_pkg AS SELECT * FROM '{PARQUET_PATH}'")

    # Add repo and star_count columns if they don't exist
    columns = con.execute("DESCRIBE all_pkg").fetchall()
    column_names = [c[0] for c in columns]

    if "repo" not in column_names:
        print("Adding 'repo' column...")
        con.execute("ALTER TABLE all_pkg ADD COLUMN repo VARCHAR")

    if "star_count" not in column_names:
        print("Adding 'star_count' column...")
        con.execute("ALTER TABLE all_pkg ADD COLUMN star_count INTEGER")

    # Extract GitHub repos from home_page and project_urls
    print("Extracting GitHub repositories...")
    rows = con.execute("SELECT name, home_page, project_urls FROM all_pkg").fetchall()

    repo_updates = []
    for name, home_page, project_urls in rows:
        repo = extract_github_repo(home_page, project_urls)
        if repo:
            repo_updates.append((repo, name))

    print(f"Found {len(repo_updates)} packages with GitHub repos")

    # Update repo column
    print("Updating repo column...")
    con.executemany(
        "UPDATE all_pkg SET repo = ? WHERE name = ?",
        repo_updates,
    )

    # Get unique repos to fetch stars for (deduplicate repos across packages)
    print("Fetching GitHub star counts...")
    packages_with_repos = con.execute(
        "SELECT name, repo FROM all_pkg WHERE repo IS NOT NULL"
    ).fetchall()

    # Group packages by repo (multiple packages might share a repo)
    repo_to_packages: dict[str, list[str]] = {}
    for name, repo in packages_with_repos:
        if repo not in repo_to_packages:
            repo_to_packages[repo] = []
        repo_to_packages[repo].append(name)

    # Prepare list of (package_name, repo) for fetching
    unique_repos = [(packages[0], repo) for repo, packages in repo_to_packages.items()]

    print(f"Fetching stars for {len(unique_repos)} unique repositories...")

    star_counts: dict[str, int | None] = {}
    total_batches = (len(unique_repos) + BATCH_SIZE - 1) // BATCH_SIZE

    for batch_num, batch in enumerate(batched(unique_repos, BATCH_SIZE), 1):
        print(f"  Batch {batch_num}/{total_batches} ({len(batch)} repos)...")
        batch_results = fetch_stars_batch(batch)

        # Map back to repo -> star_count
        for package_name, repo in batch:
            star_count = batch_results.get(package_name)
            star_counts[repo] = star_count

    # Update star_count for all packages
    print("Updating star_count column...")
    updates = []
    for repo, packages in repo_to_packages.items():
        star_count = star_counts.get(repo)
        if star_count is not None:
            for package_name in packages:
                updates.append((star_count, package_name))

    con.executemany(
        "UPDATE all_pkg SET star_count = ? WHERE name = ?",
        updates,
    )

    # Print summary
    stats = con.execute("""
        SELECT
            COUNT(*) as total,
            COUNT(repo) as with_repo,
            COUNT(star_count) as with_stars,
            MAX(star_count) as max_stars
        FROM all_pkg
    """).fetchone()

    print(f"\nSummary:")
    print(f"  Total packages: {stats[0]}")
    print(f"  With GitHub repo: {stats[1]}")
    print(f"  With star count: {stats[2]}")
    print(f"  Max stars: {stats[3]}")

    # Show top 10 by stars
    print("\nTop 10 packages by stars:")
    top_10 = con.execute("""
        SELECT name, repo, star_count
        FROM all_pkg
        WHERE star_count IS NOT NULL
        ORDER BY star_count DESC
        LIMIT 10
    """).fetchall()

    for name, repo, stars in top_10:
        print(f"  {stars:>7,} ⭐  {name} ({repo})")

    con.close()
    print("\nDone!")


if __name__ == "__main__":
    main()
