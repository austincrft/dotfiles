#!/usr/bin/env bash
set -e

script_dir="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
parent_dir="$(cd "$script_dir/.." && pwd)"

declare -A dotfiles_symlink=(
    ["$script_dir/bashrc"]="$HOME/.bashrc"
    ["$script_dir/bash_aliases"]="$HOME/.bash_aliases"
    ["$script_dir/bash_prompt"]="$HOME/.bash_prompt"

    ["$parent_dir/tmux/tmux.conf"]="$HOME/.tmux.conf"

    ["$parent_dir/nvim"]="$HOME/.config/nvim"
    ["$parent_dir/nvim/nvim-lite.lua"]="$HOME/.config/nvim-lite.lua"
)

declare -A dotfiles_template=(
    ["$parent_dir/git/gitconfig"]="$HOME/.gitconfig"
)

echo "Starting dotfiles symlink setup..."

for src in "${!dotfiles_symlink[@]}"; do
    dest="${dotfiles_symlink[$src]}"

    # Ensure parent dir exists
    mkdir -p "$(dirname "$dest")"

    # Idempotency Check
    if [ -L "$dest" ]; then
        # If it's already a symlink pointing to the right place, skip it
        if [ "$(readlink "$dest")" = "$src" ]; then
            echo "✓ $dest is already correctly linked."
            continue
        fi
        echo "Updating old symlink at $dest"
        rm "$dest"

    elif [ -e "$dest" ]; then
        # Back up a real file/folder if it blocks the symlink
        BACKUP="$dest.bak.$(date +%Y%m%d_%H%M%S)"
        echo "⚠ Warning: Real file/folder exists at $dest. Backing up to $BACKUP"
        mv "$dest" "$BACKUP"
    fi

    # Create the symlink
    echo "Creating symlink: $dest -> $src"
    ln -sfn "$src" "$dest"
done

echo "Starting dotfiles template setup..."

for src in "${!dotfiles_template[@]}"; do
    dest="${dotfiles_template[$src]}"

    # Ensure parent dir exists
    mkdir -p "$(dirname "$dest")"

    # Only copy if the file completely does not exist
    if [ ! -e "$dest" ] && [ ! -L "$DEST" ]; then
        echo "Creating initial local copy: $dest"
        cp "$src" "$dest"
    else
        echo "✓ $dest already exists, leaving untouched."
    fi

done

echo "✓ Dotfiles setup complete!"

echo "✓ Dotfiles setup complete!"

