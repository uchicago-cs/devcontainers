#!/usr/bin/env bash

# Post-installation steps for the devcontainer
# This script is run as the ubuntu user after the container is created.
# Usage: setup-extra.sh <workspace-folder>

# Exit on any error
set -e

# Ensure this directory exists, as some tools expect it
mkdir -p ~/.local/share/

# Tell git to trust the workspace folder. On some hosts (e.g., Windows), the
# workspace appears inside the container as owned by root, and git refuses
# to work in repositories owned by another user ("dubious ownership").
# See https://github.com/uchicago-cs/devcontainers/issues/3
WORKSPACE="${1:-}"
if [ -n "$WORKSPACE" ]; then
    if ! git config --global --get-all safe.directory 2>/dev/null | grep -qxF "$WORKSPACE"; then
        git config --global --add safe.directory "$WORKSPACE"
    fi
else
    echo "Warning: no workspace folder given; skipping git safe.directory setup" >&2
fi

