# Laravel

## Releases

Exact release timestamps from Packagist where possible. End of life dates from [Laravel Versions](https://laravelversions.com/).

| Version | Date                     | End of support |
| ------- | ------------------------ | -------------- |
| v12.0.0 | 2025-02-24T00:00:01.000Z | 2027-02-04     |
| v11.0.0 | 2024-03-12T13:43:31.000Z | 2026-02-03     |
| v10.0.0 | 2023-02-14T15:12:47.000Z | 2025-02-07     |
| v9.0.0  | 2022-02-08T15:48:31.000Z | 2024-02-06     |
| v8.0.0  | 2020-09-08T15:15:32.000Z | 2023-01-24     |
| v7.0.0  | 2020-03-03T13:26:07.000Z | 2021-03-03     |
| v6.0.0  | 2019-09-03T13:09:57.000Z | 2022-09-06     |
| v5.0.0  | 2015-02-04T13:59:07.000Z | 2020-02-26     |
| v4.0.0  | 2013-05-28T14:13:34.000Z |                |
| v3.0.0  | 2012-02-22T00:00:01.000Z |                |
| v2.0.0  | 2011-09-01T00:00:01.000Z |                |
| v1.0.0  | 2011-06-01T00:00:01.000Z |                |

```bash
curl https://packages.ecosyste.ms/api/v1/registries/packagist.org/packages/laravel/framework/versions/\?per_page\=1000 > laravel-versions.json
cat laravel-versions.json  | jq '.[] | "\(.number): \(.published_at)"' > laravel-versions.txt
cat laravel-versions.txt | grep -e '\.0:'> laravel-final-releases.txt
```

## Downloads

From [Packagist Daily installs per version, averaged monthly](https://packagist.org/packages/laravel/framework/stats#major/all).

```bash
curl https://packagist.org/packages/laravel/framework/stats/major/all.json\?average\=monthly\&from\=2013-01-10 > laravel-packagist-version-downloads.json
```
