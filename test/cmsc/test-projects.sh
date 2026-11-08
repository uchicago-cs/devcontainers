#!/usr/bin/env bash

# Checks that the cmsc dev container can build the starter code of projects
# used in UChicago CS courses, following the instructions on
# https://uchicago-cs.github.io/. The starter code does not pass its own
# tests, so we only check that the tests can run.
#
# Run inside the container, from the workspace folder (test/run.sh takes care
# of this). Requires network access to clone the projects from GitHub.

# shellcheck source=test/lib.sh
source "$(dirname "$0")/lib.sh"

clone_and_build() {
    local project="$1"
    git clone -q --depth 1 "https://github.com/uchicago-cs/$project.git" "$TMP/$project" \
        && cmake -S "$TMP/$project" -B "$TMP/$project/build" \
        && make -C "$TMP/$project/build" -j "$(nproc)"
}

for project in chirc chitcp chirouter; do
    check "$project builds" clone_and_build "$project"
done

# chirc's tests use pytest and require the chirc executable
chirc_tests_run() {
    cd "$TMP/chirc/build" \
        && pytest --collect-only -q --chirc-exe=./chirc \
            --chirc-rubric ../tests/rubrics/assignment-1.json ../tests
}
check "chirc tests can be collected by pytest" chirc_tests_run

# With Ubuntu's Criterion 2.4.1, test-tcp crashes before running any tests
chitcp_tests_run() {
    local output
    cd "$TMP/chitcp/build" || return 1
    ./test-buffer || return 1
    output=$(timeout 300 ./test-tcp --filter "conn_init/*" 2>&1)
    echo "$output"
    grep -q "Synthesis: Tested: 2 " <<< "$output" \
        && ! grep -q "Re-entering criterion" <<< "$output"
}
check "chitcp tests run with Criterion" chitcp_tests_run

finish
