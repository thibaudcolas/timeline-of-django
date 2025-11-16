#!/usr/bin/env bash
repo=$1
file=$2

pager=cat
echo "number,title,author,mergedBy"
while IFS= read -r pr; do
  line=$(gh pr view "$pr" --repo $repo \
    --json number,title,author,mergedBy \
    --jq '[.number, .title, .author.login, .mergedBy.login] | @csv')
  echo $line
done < <(tail -n +2 $2)
