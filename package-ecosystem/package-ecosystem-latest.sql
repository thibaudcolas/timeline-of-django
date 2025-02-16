WITH
  latest_uploads AS (
    SELECT
      name,
      MAX(upload_time) AS latest_upload
    FROM
      `bigquery-public-data.pypi.distribution_metadata`
    WHERE
      packagetype = 'bdist_wheel'
      AND (
        name IN (
          'django',
          'posthog',
          'ralph',
          'pretix',
          'iommi',
          'wagtail',
          'coderedcms',
          'longclaw',
          'wagalytics',
          'puput',
          'ls.joyous',
          'feincms',
          'strawberry'
        )
        OR name LIKE 'dj%'
        OR name LIKE 'drf-%'
        OR name LIKE 'wagtail%'
        OR name LIKE 'feincms%'
        OR name LIKE 'strawberry%'
      )
    GROUP BY
      name
  )
SELECT
  d.name,
  d.version,
  d.author,
  d.license,
  d.home_page,
  d.requires_python,
  ARRAY_TO_STRING (dm.project_urls, ', ') as project_urls,
  ARRAY_TO_STRING (dm.classifiers, ', ') as classifiers,
  ARRAY_TO_STRING (dm.requires_dist, ', ') as requires_dist,
  d.upload_time
FROM
  `bigquery-public-data.pypi.distribution_metadata` AS d
  JOIN latest_uploads AS l ON d.name = l.name
  AND d.upload_time = l.latest_upload
WHERE
  d.packagetype = 'bdist_wheel'
ORDER BY
  d.upload_time DESC;