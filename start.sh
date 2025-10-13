#!/bin/bash

WORKSPACE=$WORKSPACE
AUTH_TOKEN=$AUTH_TOKEN
AUTH_USER=$AUTH_USER
AUTH_PWD=$AUTH_PWD

[ -z "$WORKSPACE" ] && echo "[!] Missing WORKSPACE" && exit 1
if [ -n "$AUTH_TOKEN" ]; then
    AUTH_HEADER="Bearer $AUTH_TOKEN"
elif [ -n "$AUTH_USER" ] && [ -n "$AUTH_PWD" ]; then
    AUTH_HEADER="Basic $(echo -n "${AUTH_USER}:${AUTH_PWD}" | base64 | tr -d '\n')"
else
    echo "[!] Invalid authentication configuration"
    echo "Set either AUTH_TOKEN or AUTH_USER and AUTH_PWD"
    exit 1
fi

ACC_DATA=$(curl -s -H "Authorization: ${AUTH_HEADER}" -H "Content-Type: application/json" "https://api.bitbucket.org/2.0/user")
REG_DATA=$(curl -s -X POST -H "Authorization: ${AUTH_HEADER}" -H "Content-Type: application/json" \
    --data "$(jq -n --arg name "bitbucket-runner-$(uuidgen | cut -c1-8)" '$ARGS.named')" \
    https://api.bitbucket.org/internal/workspaces/$WORKSPACE/pipelines-config/runners)

export ACCOUNT_UUID=$(echo "$ACC_DATA" | jq -r .uuid)
export RUNNER_UUID=$(echo "$REG_DATA" | jq -r .uuid)
export RUNNER_NAME=$(echo "$REG_DATA" | jq -r .name)
export OAUTH_CLIENT_ID=$(echo "$REG_DATA" | jq -r ".oauth_client .id")
export OAUTH_CLIENT_SECRET=$(echo "$REG_DATA" | jq -r ".oauth_client .secret")

echo "==============================="
echo "Registered new Bitbucket Runner"
echo "Account UUID: ${ACCOUNT_UUID}"
echo "Workspace: ${WORKSPACE}"
echo "Runner Name: ${RUNNER_NAME}"
echo "Runner UID: ${RUNNER_UUID}"
echo "Runner OAuth ID: ${OAUTH_CLIENT_ID}"
echo "Runner OAuth Secret: ${OAUTH_CLIENT_SECRET}"
echo "==============================="

cd /opt/atlassian/pipelines/runner

cleanup() {
    echo "Removing runner..."
    curl -sX DELETE -H "Authorization: ${AUTH_HEADER}" -H "Content-Type: application/json" \
        "https://api.bitbucket.org/internal/workspaces/$WORKSPACE/pipelines-config/runners/\{$(echo $RUNNER_UUID | tr -d "{}")\}"
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

/bin/sh -c ./entrypoint.sh & wait $!