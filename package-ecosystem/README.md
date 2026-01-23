# Package ecosystem

Tools related to analyzing the packages landscape. Dataset: [PyPI on BigQuery](https://cloud.google.com/blog/topics/developers-practitioners/analyzing-python-package-downloads-bigquery)

## Package ecosystem overview

```bash
cat package-ecosystem-downloads.bq.sql | bq query --max_rows 50000 --use_legacy_sql=false --dry_run 2>&1 | grep -o '[0-9]\+' | awk '{printf "%.2f GB\n", $1/1024/1024/1024}'
cat package-recent-releases.bq.sql | bq query --max_rows 50000 --use_legacy_sql=false --dry_run 2>&1 | grep -o '[0-9]\+' | awk '{printf "%.2f GB\n", $1/1024/1024/1024}'

cat package-ecosystem-downloads.bq.sql | bq query --max_rows 50000 --use_legacy_sql=false --format=csv > package-ecosystem-downloads.bq.csv
cat package-recent-releases.bq.sql | bq query --max_rows 50000 --use_legacy_sql=false --format=csv > package-recent-releases.bq.csv

duckdb

create table recent as select * from './package-recent-releases.csv';
create table dl as SELECT * from './package-ecosystem-downloads.csv';
copy(select dl.project, dl.downloads_count as downloads_30d, recent.* from recent full outer join dl on dl.project = recent.name order by dl.downloads_count desc) to './30d-overview.csv';
```

### Example: trove classifiers

From `package-recent-releases.bq.sql`, review how many packages declare their support for specific Django versions in their [trove classifiers](https://github.com/pypa/trove-classifiers). Results as of 2025-02-15, one month after Django [5.2 alpha 1 release](https://www.djangoproject.com/weblog/2025/jan/16/django-52-alpha-1-released/).

| Version      | 5.2          | 5.1       | 5.0       | 4.2       | Total       |
| ------------ | ------------ | --------- | --------- | --------- | ----------- |
| **Packages** | 23 🎉 (1.6%) | 240 (17%) | 409 (29%) | 570 (41%) | 1394 (100%) |

## Django 5.2 usage

Evaluates which packages already declare support for Django 5.2, and returns them in a neat list.

Spreadsheet: [Django 5.2 - Django-Wagtail packages ecosystem on PyPI](https://docs.google.com/spreadsheets/d/1CnBjurD7WE0NDXt-KU_Y3p_VABLNKf3pSuDSDUfoSpU/edit?gid=1028186010#gid=1028186010)

SQL: [packages-django-5-2.bq.sql](packages-django-5-2.bq.sql)

Here are the packages from the first run:

- [django-csp v4.0b3](https://github.com/mozilla/django-csp/blob/main/CHANGES.md)
- [django-bird v0.14.2](https://github.com/joshuadavidthomas/django-bird)
- [django-filter v25.1](https://github.com/carltongibson/django-filter/blob/main/CHANGES.rst)
- [django-tailwind-cli v4.1.0](https://django-tailwind-cli.rtfd.io/)
- [django-appconf v1.1.0](https://github.com/django-compressor/django-appconf)
- [django-rich v1.14.0](https://github.com/adamchainz/django-rich/blob/main/CHANGELOG.rst)
- [django-mysql v4.16.0](https://django-mysql.readthedocs.io/en/latest/changelog.html)
- [django-perf-rec v4.28.0](https://github.com/adamchainz/django-perf-rec/blob/main/CHANGELOG.rst)
- [django-version-checks v1.14.0](https://github.com/adamchainz/django-version-checks/blob/main/CHANGELOG.rst)
- [django-read-only v1.19.0](https://github.com/adamchainz/django-read-only/blob/main/CHANGELOG.rst)
- [django-permissions-policy v4.25.0](https://github.com/adamchainz/django-permissions-policy/blob/main/CHANGELOG.rst)
- [django-linear-migrations v2.17.0](https://github.com/adamchainz/django-linear-migrations/blob/main/CHANGELOG.rst)
- [django-watchfiles v1.1.0](https://github.com/adamchainz/django-watchfiles/blob/main/CHANGELOG.rst)
- [django-minify-html v1.12.0](https://github.com/adamchainz/django-minify-html/blob/main/CHANGELOG.rst)
- [django-cors-headers v4.7.0](https://github.com/adamchainz/django-cors-headers/blob/main/CHANGELOG.rst)
- [django-htmx v1.22.0](https://django-htmx.readthedocs.io/en/latest/changelog.html)
- [django-harlequin v1.5.0](https://github.com/adamchainz/django-harlequin/blob/main/CHANGELOG.rst)
- [django-browser-reload v1.18.0](https://github.com/adamchainz/django-browser-reload/blob/main/CHANGELOG.rst)
- [django-auto-prefetch v1.12.0](https://github.com/tolomea/django-auto-prefetch/blob/main/CHANGELOG.rst)
- [django-ditto v3.5.0](https://github.com/philgyford/django-ditto/blob/main/CHANGELOG.md)
- [django-syzygy v1.2.0](https://github.com/charettes/django-syzygy)
- [django-extra-checks v0.17.0a1](https://github.com/kalekseev/django-extra-checks)
- [django-admin-groups v0.3](https://github.com/OmarSwailam/django-admin-groups)

## Released since

[20,000 Django packages](https://wagtail.org/blog/20000-django-packages/)

```sql
create table all_pkg as select * from './20250724_all_pkg.parquet.zst';
copy(select name, downloads_30d, number_of_releases, markdown from all_pkg where latest_release_upload_time >= NOW() - INTERVAL '1 years' order by latest_release_upload_time desc) to './released_1_year.csv';
copy(select name, downloads_30d, number_of_releases, markdown from all_pkg where latest_release_upload_time >= NOW() - INTERVAL '3 years' order by latest_release_upload_time desc) to './released_3_year.csv';
copy(select name, downloads_30d, number_of_releases, markdown from all_pkg where latest_release_upload_time >= CAST('2025-01-16T09:15:08.000Z' AS TIMESTAMP) order by latest_release_upload_time desc) to './released_since_5_2.csv';
```
