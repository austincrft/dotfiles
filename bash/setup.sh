#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
PARENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

declare -A DOTFILES_SYMLINK=(
    ["$SCRIPT_DIR/bashrc"]="$HOME/.bashrc"
    ["$SCRIPT_DIR/bash_aliases"]="$HOME/.bash_aliases"
    ["$SCRIPT_DIR/bash_prompt"]="$HOME/.bash_prompt"

    ["$PARENT_DIR/nvim"]="$HOME/.config/nvim"
    ["$PARENT_DIR/nvim/nvim-lite.lua"]="$HOME/.config/nvim-lite.lua"
)

declare -A DOTFILES_TEMPLATE=(
    ["$PARENT_DIR/git/gitconfig"]="$HOME/.gitconfig"
)

echo "Starting dotfiles symlink setup..."

for SRC in "${!DOTFILES_SYMLINK[@]}"; do
    DEST="${DOTFILES_SYMLINK[$SRC]}"

    # Ensure parent dir exists
    mkdir -p "$(dirname "$DEST")"

    # Idempotency Check
    if [ -L "$DEST" ]; then
        # If it's already a symlink pointing to the right place, skip it
        if [ "$(readlink "$DEST")" = "$SRC" ]; then
            echo "✓ $DEST is already correctly linked."
            continue
        fi
        echo "Updating old symlink at $DEST"
        rm "$DEST"

    elif [ -e "$DEST" ]; then
        # Back up a real file/folder if it blocks the symlink
        BACKUP="$DEST.bak.$(date +%Y%m%d_%H%M%S)"
        echo "⚠ Warning: Real file/folder exists at $DEST. Backing up to $BACKUP"
        mv "$DEST" "$BACKUP"
    fi

    # Create the symlink
    echo "Creating symlink: $DEST -> $SRC"
    ln -sfn "$SRC" "$DEST"
done

echo "Starting dotfiles template setup..."

for SRC in "${!DOTFILES_TEMPLATE[@]}"; do
    DEST="${DOTFILES_TEMPLATE[$SRC]}"

    # Ensure parent dir exists
    mkdir -p "$(dirname "$DEST")"

    # Only copy if the file completely does not exist
    if [ ! -e "$DEST" ] && [ ! -L "$DEST" ]; then
        echo "Creating initial local copy: $DEST"
        cp "$SRC" "$DEST"
    else
        echo "✓ $DEST already exists, leaving untouched."
    fi

done

echo "✓ Dotfiles setup complete!"

echo "✓ Dotfiles setup complete!"

