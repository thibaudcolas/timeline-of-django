# Rails downloads

Data of [BestGems by xmisao](https://bestgems.org/about), see [BestGems API v1 Specification](https://github.com/xmisao/bestgems.org/wiki/BestGems-API-v1-Specification)

```bash
curl https://bestgems.org/api/v1/gems/rails/daily_downloads.json
cat rails_daily_downloads.json  | jq '.[] | "\(.date),\(.daily_downloads)"' > rails_daily_downloads.csv
```
