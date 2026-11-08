#!/usr/bin/env bash

# Builds a dev container from a template in src/ and runs one of that
# template's test scripts (test/<template>/<test-script>) inside it.
#
# Usage: test/run.sh <template-id> [<test-script>]
#
# <test-script> defaults to test.sh
#
# Uses the devcontainer CLI if it is on the PATH, or runs it with npx otherwise.
#
# To use a BuildKit layer cache when building the image, set
# DEVCONTAINER_CACHE_FROM and/or DEVCONTAINER_CACHE_TO, which are passed to
# the devcontainer CLI's --cache-from and --cache-to options. For example,
# "type=gha,scope=cmsc" and "type=gha,scope=cmsc,mode=max" in GitHub Actions.
# Exporting a cache requires a buildx builder that supports it, such as one
# using the docker-container driver.

set -euo pipefail

TEMPLATE="${1:?usage: $0 <template-id> [<test-script>]}"
TEST_SCRIPT="${2:-test.sh}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC_DIR="$REPO_ROOT/src/$TEMPLATE"
TEST_DIR="$REPO_ROOT/test/$TEMPLATE"

if [ ! -d "$SRC_DIR/.devcontainer" ] || [ ! -f "$TEST_DIR/$TEST_SCRIPT" ]; then
    echo "error: expected $SRC_DIR/.devcontainer and $TEST_DIR/$TEST_SCRIPT" >&2
    exit 1
fi

dc() {
    if command -v devcontainer >/dev/null; then
        devcontainer "$@"
    else
        npx -y @devcontainers/cli "$@"
    fi
}

# The workspace folder name deliberately contains a space, as students'
# folders often do.
WORK_DIR="$(mktemp -d)"
WORKSPACE="$WORK_DIR/test project"
mkdir -p "$WORKSPACE"

cleanup() {
    docker ps -aq --filter "label=devcontainer.local_folder=$WORKSPACE" \
        | xargs -r docker rm -f >/dev/null
    rm -rf "$WORK_DIR"
}
trap cleanup EXIT

# Apply the template the way a student would. The template has no options,
# so this amounts to copying the .devcontainer directory.
cp -r "$SRC_DIR/.devcontainer" "$WORKSPACE/"

# VS Code drops the execute bit on template files when applying a template,
# so make sure the container does not depend on it.
find "$WORKSPACE/.devcontainer" -type f -exec chmod a-x {} +

cp -r "$TEST_DIR" "$WORKSPACE/.test"
cp "$REPO_ROOT/test/lib.sh" "$WORKSPACE/.test/"

CACHE_ARGS=()
if [ -n "${DEVCONTAINER_CACHE_FROM:-}" ]; then
    CACHE_ARGS+=(--cache-from "$DEVCONTAINER_CACHE_FROM")
fi
if [ -n "${DEVCONTAINER_CACHE_TO:-}" ]; then
    CACHE_ARGS+=(--cache-to "$DEVCONTAINER_CACHE_TO")
fi
if [ ${#CACHE_ARGS[@]} -gt 0 ]; then
    # On Linux, the CLI runs a second "docker build" to change the remote
    # user's UID to match the host user's. That build goes through the same
    # cache-capable (docker-container) builder, which cannot see the image
    # loaded by the first build, so it fails. Skip it, as Docker Desktop on
    # macOS and Windows does.
    CACHE_ARGS+=(--update-remote-user-uid-default never)
fi

echo "=== Building and starting the '$TEMPLATE' dev container"
dc up --workspace-folder "$WORKSPACE" ${CACHE_ARGS[@]+"${CACHE_ARGS[@]}"}

echo "=== Running $TEST_SCRIPT inside the container"
dc exec --workspace-folder "$WORKSPACE" bash ".test/$TEST_SCRIPT"
