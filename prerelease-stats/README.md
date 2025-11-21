# Pre-release downloads statistics

## Queries methodology

Generated from an extract of all past Django feature releases, including their pre- and final releases.

```bash
curl https://packages.ecosyste.ms/api/v1/registries/pypi.org/packages/django/versions\?per_page\=500 | jq '[ .[] | { number, published_at } ]' > django-versions.json
# Only keep numbers and dates.
cat django-versions.json  | jq '.[] | "\(.number): \(.published_at)"' > django-versions.txt
# Only keep pre-releases and final releases.
cat django-versions.txt | grep -v -e '\.[0-9]\.' | grep -v -e '\.[0-9][0-9]\.' | grep -v -e '[bc]' > django-pre-releases.txt
```

Then update the queries for the relevant release, and run:

```bash
# Check costs.
cat pre-release-version-downloads.sql | bq query --max_rows 50000 --use_legacy_sql=false --dry_run 2>&1 | grep -o '[0-9]\+' | awk '{printf "%.2f GB\n", $1/1024/1024/1024}'
cat pre-release-total-downloads.sql | bq query --max_rows 50000 --use_legacy_sql=false --dry_run 2>&1 | grep -o '[0-9]\+' | awk '{printf "%.2f GB\n", $1/1024/1024/1024}'
# Actually run.
cat pre-release-version-downloads.sql | bq query --max_rows 50000 --use_legacy_sql=false --format=csv >> pre-release-version-downloads.csv
cat pre-release-total-downloads.sql | bq query --max_rows 50000 --use_legacy_sql=false --format=csv >> pre-release-total-downloads.csv
```

## Queries

### Pre-release version downloads

Compares the download figures for pre-release versions (alpha, beta, release candidate) and the downloads of the previous "stable / latest" version.

Query: `pre-release-version-downloads.sql`

### Total downloads

Total downloads of Django across all versions, but sampled specifically during pre-release phases.

Query: `pre-release-total-downloads.sql`
