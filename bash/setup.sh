#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
PARENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

declare -A DOTFILES=(
    ["$SCRIPT_DIR/bashrc"]="$HOME/.bashrc"
    ["$SCRIPT_DIR/bash_aliases"]="$HOME/.bash_aliases"
    ["$SCRIPT_DIR/bash_prompt"]="$HOME/.bash_prompt"

    ["$PARENT_DIR/git/gitconfig"]="$HOME/.gitconfig"

    ["$PARENT_DIR/nvim"]="$HOME/.config/nvim"
    ["$PARENT_DIR/nvim/nvim-lite.lua"]="$HOME/.config/nvim-lite.lua"
)

echo "Starting dotfiles symlink setup..."

for SRC in "${!DOTFILES[@]}"; do
    DEST="${DOTFILES[$SRC]}"

    # Ensure the destination's parent folder exists (e.g., ~/.config)
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

echo "✓ Dotfiles setup complete!"

