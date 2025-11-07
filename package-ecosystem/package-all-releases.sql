-- All past releases of Django-related packages on PyPI (name-based OR classifier-based),
-- one row per package+version, with canonical release timestamp.
WITH candidates AS (
  SELECT *
  FROM `bigquery-public-data.pypi.distribution_metadata`
  WHERE
    packagetype IN ('bdist_wheel', 'sdist')
    AND (
      -- Name-based detection (lowercased for safety)
      LOWER(name) IN (
        'django','posthog','ralph','pretix','iommi','wagtail','coderedcms',
        'longclaw','wagalytics','puput','ls.joyous','feincms','strawberry'
      )
      OR LOWER(name) LIKE 'dj%'
      OR LOWER(name) LIKE 'drf-%'
      OR LOWER(name) LIKE 'wagtail%'
      OR LOWER(name) LIKE 'feincms%'
      OR LOWER(name) LIKE 'strawberry%'

      -- OR: Classifier-based detection (this distribution declares Django)
      OR EXISTS (
        SELECT 1
        FROM UNNEST(classifiers) AS c
        WHERE
          -- exact framework classifier or any classifier containing 'django'
          c LIKE 'Framework :: Django%'
          OR LOWER(c) LIKE '%django%'
      )
    )
),
releases AS (
  SELECT
    name,
    version,
    MIN(upload_time) AS first_upload_time,   -- canonical "release" timestamp
    MAX(upload_time) AS last_upload_time,    -- last file uploaded for that version
    COUNT(*)           AS num_distributions
  FROM candidates
  GROUP BY name, version
)

SELECT
  r.name,
  r.version,
  r.first_upload_time AS release_time,
  r.last_upload_time,
  r.num_distributions
FROM releases r
ORDER BY r.name, release_time DESC;
