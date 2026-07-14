#!/usr/bin/env bats

setup() {
    source "$BATS_TEST_DIRNAME/../start.sh"
}

@test "build_auth_header uses bearer token when AUTH_TOKEN set" {
    run build_auth_header "mytoken" "" ""
    [ "$status" -eq 0 ]
    [ "$output" = "Bearer mytoken" ]
}

@test "build_auth_header builds basic auth from user/pwd" {
    run build_auth_header "" "user" "pass"
    [ "$status" -eq 0 ]
    [ "$output" = "Basic $(echo -n user:pass | base64 | tr -d '\n')" ]
}

@test "build_auth_header prefers token over user/pwd" {
    run build_auth_header "tok" "user" "pass"
    [ "$output" = "Bearer tok" ]
}

@test "build_auth_header fails with no credentials" {
    run build_auth_header "" "" ""
    [ "$status" -eq 1 ]
}

@test "missing WORKSPACE exits 1 with message" {
    run env -i PATH="$PATH" bash "$BATS_TEST_DIRNAME/../start.sh"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Missing WORKSPACE"* ]]
}

@test "missing auth config exits 1 with message" {
    run env -i PATH="$PATH" WORKSPACE=test bash "$BATS_TEST_DIRNAME/../start.sh"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Invalid authentication configuration"* ]]
}
