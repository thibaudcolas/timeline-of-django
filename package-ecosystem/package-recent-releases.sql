SELECT
  dm.name,
  downloads.downloads_count,
  dm.version as latest_release,
  dm.author,
  dm.license,
  dm.home_page,
  dm.requires_python,
  ARRAY_TO_STRING (dm.project_urls, ', ') as project_urls,
  ARRAY_TO_STRING (dm.classifiers, ', ') as classifiers,
  ARRAY_TO_STRING (dm.requires_dist, ', ') as requires_dist,
  dm.upload_time,
FROM
  `bigquery-public-data.pypi.distribution_metadata` as dm,
  (
    SELECT
      dm.name,
      MAX(dm.upload_time) as latest_upload
    FROM
      `bigquery-public-data.pypi.distribution_metadata` as dm
    WHERE
      dm.packagetype = 'bdist_wheel'
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
      dm.name
  ) as latest,
  (
    SELECT
      dl.project,
      COUNT(*) AS downloads_count
    FROM
      `bigquery-public-data.pypi.file_downloads` AS dl
    WHERE
      dl.details.installer.name = 'pip'
      AND dl.timestamp > TIMESTAMP_SUB (CURRENT_TIMESTAMP(), INTERVAL 1 DAY)
      AND (
        dl.project IN (
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
        OR dl.project LIKE 'dj%'
        OR dl.project LIKE 'drf-%'
        OR dl.project LIKE 'wagtail%'
        OR dl.project LIKE 'feincms%'
        OR dl.project LIKE 'strawberry%'
      )
    GROUP BY
      dl.project
  ) as downloads
WHERE
  dm.packagetype = 'bdist_wheel'
  AND latest.latest_upload = dm.upload_time
  AND latest.name = dm.name
  AND downloads.project = dm.name
ORDER BY
  downloads_count desc