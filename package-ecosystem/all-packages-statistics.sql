-- DuckDB SQL for local use after package-ecosystem-downloads.sql
SELECT
  -- after Django 5.2 release
  COUNT(distinct(name)) FILTER (
    WHERE latest_release_upload_time >= CAST('2025-01-16T09:15:08.000Z' AS TIMESTAMP)
  ) AS released_since_django_5_2,

  COUNT(distinct(name)) FILTER (
    WHERE latest_release_upload_time >= NOW() - INTERVAL '1 year'
  ) AS released_last_1_year,
  COUNT(distinct(name)) FILTER (
    WHERE latest_release_upload_time >= NOW() - INTERVAL '3 years'
  ) AS released_last_3_years,
  COUNT(distinct(name)) FILTER (
    WHERE latest_release_upload_time >= NOW() - INTERVAL '5 years'
  ) AS released_last_5_years,

  -- >1 release
  COUNT(distinct(name)) FILTER (
    WHERE number_of_releases > 1
  ) AS more_than_one_release,

  -- only one release
  COUNT(distinct(name)) FILTER (
    WHERE number_of_releases = 1
  ) AS only_one_release,

  COUNT(distinct(name)) FILTER(
    WHERE name like '%wagtail%' or list_contains(classifiers, 'Framework :: Wagtail')
  ) AS wagtail_packages,

  COUNT(distinct(name)) FILTER(
    WHERE regexp_matches(name, 'djangorestframework|drf')
  ) AS drf_packages,

  COUNT(distinct(name)) AS total_packages,
FROM all_pkg;

-- copy (SELECT
--   distinct(name), latest_release_upload_time,
--   -- Calculate the difference in days (as a fractional value) between now and the last release timestamp
--   (EXTRACT('epoch' FROM (NOW() - latest_release_upload_time)) / 86400.0)
--     AS days_since_last_release
-- FROM all_pkg order by days_since_last_release asc) to './days-since-release.csv';
-- copy (select * from './all_pkg.parquet.zst' order by downloads_30d desc) to './all-packages.csv';
