#!/usr/bin/env bash

# Post-installation steps for the devcontainer
# This script is run as the ubuntu user after the Dockerfile is built

# Exit on any error
set -e

# Ensure this directory exists, as some tools expect it
mkdir -p ~/.local/share/

