--- Retrieves all ecosystem packages with their latest release and download statistics.

CREATE TEMP FUNCTION toMarkdown(name STRING, version STRING, home_page STRING, project_urls ARRAY<STRING>) RETURNS STRING
LANGUAGE js AS """
    const urls = {};
    project_urls.forEach((entry) => { const [key, value] = entry.split(', '); urls[key.toLowerCase()] = value; });
    const url = urls.changelog || urls.home || urls.homepage || urls.source || urls.repository || home_page || `https://pypi.org/project/${name}/`;
    return `- [${name} v${version}](${url})`;
""";

WITH
  DjangoPackages AS (
    SELECT DISTINCT
      name
    FROM
      `bigquery-public-data.pypi.distribution_metadata`
    WHERE
      -- Hyphenation attack or preemptive hyphenation attack in 2020-07-29
      author != 'The Guardians'
      AND (
        -- Bug: must account for Django having an uppercase 'D' in its name.
        REGEXP_CONTAINS(name, r'^(django|posthog|ralph|pretix|iommi|wagtail|coderedcms|longclaw|wagalytics|puput|ls\.joyous|feincms|mezzanine)$|^dj|^drf-|^wagtail|^feincms|^mezzanine|wagtail$|django$')
        OR
        EXISTS (SELECT 1 FROM UNNEST(classifiers) AS c WHERE c = 'Framework :: Django')
      )
  ),
  PackageStats AS (
    SELECT
      md.name,
      COUNT(DISTINCT md.version) AS number_of_releases,
      MIN(md.upload_time) AS first_release_upload_time,
      MAX(md.upload_time) AS latest_release_upload_time
    FROM
      `bigquery-public-data.pypi.distribution_metadata` AS md
    JOIN
      DjangoPackages USING (name)
    GROUP BY
      md.name
  ),
  RecentDownloads AS (
    SELECT
      fd.project       AS name,
      COUNT(*)         AS downloads_30d
    FROM
      `bigquery-public-data.pypi.file_downloads` AS fd
    JOIN
      DjangoPackages AS dp
    ON
      fd.project = dp.name
    WHERE
      -- Expensive: 30 days across all releases (1.5TB)
      fd.timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
    GROUP BY
      fd.project
  )
SELECT
  ps.name,
  IFNULL(rd.downloads_30d, 0) AS downloads_30d,
  ps.number_of_releases,
  ps.latest_release_upload_time,
  d.version AS latest_version,
  d.author AS latest_author,
  d.license AS license,
  d.requires_python as requires_python,
  d.home_page AS home_page,
  d.project_urls AS project_urls,
  d.classifiers AS classifiers,
  d.requires_dist AS requires_dist,
  toMarkdown(ps.name, d.version, d.home_page, d.project_urls) AS markdown
FROM
  PackageStats AS ps
  LEFT JOIN
    `bigquery-public-data.pypi.distribution_metadata` AS d
    ON ps.name = d.name AND ps.latest_release_upload_time = d.upload_time
  LEFT JOIN
    RecentDownloads AS rd
    ON ps.name = rd.name
ORDER BY
  ps.latest_release_upload_time DESC;
