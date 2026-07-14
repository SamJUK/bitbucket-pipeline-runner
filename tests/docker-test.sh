#!/usr/bin/env bash
set -uo pipefail

IMAGE="${1:-bitbucket-runner:test}"
fail=0

check() {
    local desc="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        echo "[PASS] $desc"
    else
        echo "[FAIL] $desc"
        fail=1
    fi
}

check "jq present in image" docker run --rm --entrypoint jq "$IMAGE" --version
check "uuidgen present in image" docker run --rm --entrypoint uuidgen "$IMAGE"

out=$(docker run --rm "$IMAGE" 2>&1)
if [[ "$out" == *"Missing WORKSPACE"* ]]; then
    echo "[PASS] missing WORKSPACE fails fast"
else
    echo "[FAIL] missing WORKSPACE fails fast"
    fail=1
fi

out=$(docker run --rm -e WORKSPACE=test "$IMAGE" 2>&1)
if [[ "$out" == *"Invalid authentication configuration"* ]]; then
    echo "[PASS] missing auth config fails fast"
else
    echo "[FAIL] missing auth config fails fast"
    fail=1
fi

exit $fail
