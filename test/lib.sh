# shellcheck shell=bash

# Helpers shared by the test scripts in test/<template>/. test/run.sh copies
# this file next to the test script, which should source it at the start
# and call finish at the end.

set -u

FAILURES=0

# check <description> <command...>
# Runs the command, and prints its output only if it fails.
check() {
    local desc="$1"
    shift
    local output
    if output=$("$@" 2>&1); then
        echo "PASS: $desc"
    else
        echo "FAIL: $desc"
        while IFS= read -r line; do echo "    $line"; done <<< "$output"
        FAILURES=$((FAILURES + 1))
    fi
}

# Prints a summary, and exits with a non-zero status if any check failed
finish() {
    echo
    if [ "$FAILURES" -gt 0 ]; then
        echo "$FAILURES check(s) failed"
        exit 1
    fi
    echo "All checks passed"
}

# Temporary directory for the checks. Some checks create root-owned files.
TMP="$(mktemp -d)"
trap 'sudo rm -rf "$TMP"' EXIT
