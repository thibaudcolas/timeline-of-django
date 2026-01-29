-- DuckDB: Computes aggregate statistics (release counts, recency, ecosystem breakdowns) for Django packages.
SELECT
  COUNT(distinct(name)) FILTER (
    WHERE upload_time >= CAST('2025-01-16T09:15:08.000Z' AS TIMESTAMP)
  ) AS released_since_django_5_2,

  COUNT(distinct(name)) FILTER (
    WHERE upload_time >= CAST('2025-12-03T16:26:16.000Z' AS TIMESTAMP)
  ) AS released_since_django_6_0,

  COUNT(distinct(name)) FILTER (
    WHERE upload_time >= NOW() - INTERVAL '1 year'
  ) AS released_last_1_year,
  COUNT(distinct(name)) FILTER (
    WHERE upload_time >= NOW() - INTERVAL '3 years'
  ) AS released_last_3_years,
  COUNT(distinct(name)) FILTER (
    WHERE upload_time >= NOW() - INTERVAL '5 years'
  ) AS released_last_5_years,

  -- >1 release
  -- COUNT(distinct(name)) FILTER (
  --   WHERE number_of_releases > 1
  -- ) AS more_than_one_release,

  -- only one release
  -- COUNT(distinct(name)) FILTER (
  --   WHERE number_of_releases = 1
  -- ) AS only_one_release,

  COUNT(distinct(name)) FILTER(
    WHERE (
      name like '%wagtail%'
      or 'Framework :: Wagtail' in classifiers
    )
  ) AS wagtail_packages,

  COUNT(distinct(name)) FILTER(
    WHERE regexp_matches(name, 'djangorestframework|drf')
  ) AS drf_packages,

  COUNT(distinct(name)) AS total_packages,
FROM all_pkg;

-- copy (SELECT
--   distinct(name), upload_time,
--   -- Calculate the difference in days (as a fractional value) between now and the last release timestamp
--   (EXTRACT('epoch' FROM (NOW() - upload_time)) / 86400.0)
--     AS days_since_last_release
-- FROM all_pkg order by days_since_last_release asc) to './days-since-release.csv';
-- copy (select * from './all_pkg.parquet.zst' order by downloads_30d desc) to './all-packages.csv';
