#!/usr/bin/env bash

# Post-installation steps for the devcontainer
# This script is run as the ubuntu user after the Dockerfile is built

# Exit on any error
set -e

# Ensure this directory exists, as some tools expect it
mkdir -p ~/.local/share/

# Fix workspace ownership if needed (especially important on Windows/macOS)
# On Linux with matching UIDs, this is unnecessary and could cause issues
if [ -d /workspaces ] && [ "$(ls -A /workspaces 2>/dev/null)" ]; then
    WORKSPACE_OWNER=$(stat -c '%U' /workspaces/* 2>/dev/null | head -1 || echo "")
    if [ "$WORKSPACE_OWNER" = "root" ]; then
        echo "Fixing workspace ownership (owned by root, changing to ubuntu)..."
        sudo chown -R ubuntu:ubuntu /workspaces/* 2>/dev/null || true
    fi
fi

