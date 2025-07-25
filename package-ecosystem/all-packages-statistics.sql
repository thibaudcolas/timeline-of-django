-- DuckDB SQL for local use after package-ecosystem-downloads.sql
SELECT
  -- after Django 5.2 release
  COUNT(*) FILTER (
    WHERE latest_release_upload_time >= CAST('2025-01-16T09:15:08.000Z' AS TIMESTAMP)
  ) AS released_since_django_5_2,

  COUNT(*) FILTER (
    WHERE latest_release_upload_time >= NOW() - INTERVAL '1 year'
  ) AS released_last_1_year,
  COUNT(*) FILTER (
    WHERE latest_release_upload_time >= NOW() - INTERVAL '3 years'
  ) AS released_last_3_years,
  COUNT(*) FILTER (
    WHERE latest_release_upload_time >= NOW() - INTERVAL '5 years'
  ) AS released_last_5_years,

  -- >1 release
  COUNT(*) FILTER (
    WHERE number_of_releases > 1
  ) AS more_than_one_release,

  -- only one release
  COUNT(*) FILTER (
    WHERE number_of_releases = 1
  ) AS only_one_release,

  COUNT(*) FILTER(
    WHERE name like '%wagtail%'
  ) AS wagtail_packages,

  COUNT(*) FILTER(
    WHERE regexp_matches(name, 'django|^dj') AND NOT name like 'django-cms%'
  ) AS vanilla_packages,

  COUNT(*) FILTER(
    WHERE regexp_matches(name, 'djangorestframework|drf')
  ) AS drf_packages,

  COUNT(*) FILTER(
    WHERE regexp_matches(name, '')
  ) AS drf_packages,

  COUNT(*) AS total_packages,
FROM all_pkg;
