#standardSQL
--- Retrieves all package releases declaring compatibility with Django 5.2.
-- https://docs.google.com/spreadsheets/d/1CnBjurD7WE0NDXt-KU_Y3p_VABLNKf3pSuDSDUfoSpU/edit?gid=1028186010#gid=1028186010
CREATE TEMP FUNCTION toMarkdown(
    name STRING,
    version STRING,
    home_page STRING,
    project_urls ARRAY<STRING>)
RETURNS STRING
LANGUAGE js AS """
    // Convert project_urls to map for easy access
    const urls = {};
    project_urls.forEach((entry) => {
      const [key, value] = entry.split(', ');
      urls[key.toLowerCase()] = value;
    });
    const url = urls.changelog || urls.home || urls.homepage || urls.source || urls.repository || home_page || `https://pypi.org/project/${name}/`;
    return `- [${name} v${version}](${url})`;
""";

WITH
  -- Factor out the pattern logic once.
  allowed_packages AS (
    SELECT DISTINCT name
    FROM `bigquery-public-data.pypi.distribution_metadata`
    WHERE packagetype = 'bdist_wheel'
      AND REGEXP_CONTAINS(name, r'^(django|posthog|ralph|pretix|iommi|wagtail|coderedcms|longclaw|wagalytics|puput|ls\.joyous|feincms|mezzanine)$|^dj|^drf-|^wagtail|^feincms|^mezzanine|wagtail$|django$')
  ),
  latest AS (
    SELECT
      dm.name,
      dm.version,
      dm.author,
      dm.home_page,
      dm.project_urls,
      dm.upload_time,
      toMarkdown(dm.name, dm.version, dm.home_page, dm.project_urls) AS markdown
    FROM `bigquery-public-data.pypi.distribution_metadata` dm
    JOIN allowed_packages ap
      ON dm.name = ap.name
    WHERE dm.packagetype = 'bdist_wheel'
      AND dm.upload_time BETWEEN TIMESTAMP('2025-01-16T09:15:08.000Z') AND CURRENT_TIMESTAMP()
      AND "Framework :: Django :: 5.2" IN UNNEST(dm.classifiers)
    QUALIFY ROW_NUMBER() OVER (PARTITION BY dm.name ORDER BY dm.upload_time DESC) = 1
  )

SELECT
  l.name,
  l.version AS latest_release,
  l.author,
  l.home_page,
  l.project_urls,
  l.upload_time,
  l.markdown
FROM latest l
ORDER BY l.upload_time DESC;
