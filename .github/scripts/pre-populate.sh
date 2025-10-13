#!/usr/bin/env bash
RUNNER_VERSIONS=$(curl -s https://product-downloads.atlassian.com/software/bitbucket/pipelines/CHANGELOG.md | grep -E "^## " | sed 's/^## //g' | sort -V)
EXISTING_TAGS=$(git ls-remote --tags origin | awk -F'/' '{print $3}' | sed 's/\^{}//g' | sort -V)
MISSING_TAGS=$(grep -vxf <(echo -e "$EXISTING_TAGS") <(echo -e "$RUNNER_VERSIONS"))

for TAG in $MISSING_TAGS; do
  echo "Dispatching release workflow for version: $TAG"
  gh workflow run release.yaml -f version="$TAG"
  sleep 30
done
