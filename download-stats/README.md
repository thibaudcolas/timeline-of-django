# Django downloads statistics

## Releases

View [Django - Download](https://www.djangoproject.com/download/) for an overview of release end-of-life dates, see also [PyPI Django releases history](https://pypi.org/project/Django/#history).

```bash
curl https://packages.ecosyste.ms/api/v1/registries/pypi.org/packages/django/versions\?per_page\=500 > django-versions.json
cat django-versions.json  | jq '.[] | "\(.number): \(.published_at)"' > django-versions.txt
cat django-versions.txt | grep -v -e '\.[0-9]\.' | grep -v -e '\.[0-9][0-9]\.' | grep -v -e '[bc]' > django-releases.csv
```

## Downloads

```bash
cat versions-over-time-daily.sql | bq query --max_rows 5000000 --use_legacy_sql=false --dry_run 2>&1 | grep -o '[0-9]\+' | awk '{printf "%.2f GB\n", $1/1024/1024/1024}'
cat versions-over-time-daily.sql | bq query --max_rows 5000000 --use_legacy_sql=false --format=csv > versions-over-time-daily.csv
```
