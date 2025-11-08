#!/usr/bin/env sh

echo "Updating git submodules..."
git submodule update --init --recursive --remote
echo "Git submodules updated."