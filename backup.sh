#!/usr/bin/env bash

# Define source and destination
SOURCE="/etc/nixos"
DEST="$HOME/nixos-config"

# Copy all files from /etc/nixos to backup folder
echo "Copying NixOS configuration files..."
cp -r "$SOURCE"/* "$DEST/"

echo "Backup complete! Files copied to $DEST"
ls -la "$DEST"
