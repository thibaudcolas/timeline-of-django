## FastAPI

## Releases

```bash
curl https://packages.ecosyste.ms/api/v1/registries/pypi.org/packages/fastapi/versions\?per_page\=500 > fastapi-versions.json
cat fastapi-versions.json  | jq '.[] | "\(.number): \(.published_at)"' > fastapi-versions.txt
cat fastapi-versions.txt | grep -e '\.0:' > releases-published.csv
```

There doesn’t seem to be a set support policy for FastAPI, so assume only the latest version is supported.

## Downloads

Downloads data is available on the BigQuery PyPI dataset. Then with DuckDB:

```sql
-- Manual transformation needed
create table releases as select * from './releases-published.csv';
create table dl as select * from './versions-over-time-daily.csv.zst';
create table feature_versions as select
    day,
    concat(regexp_extract(version, '^(\d+\.\d+)'), '.0') as minor_version,
    sum(num_downloads) as total_downloads
from dl
group by day, minor_version
order by day, minor_version;
copy (select * from supported_downloads) to 'supported-downloads.csv';
copy (select * from pivot_downloads) to 'pivot_downloads.csv';
```
