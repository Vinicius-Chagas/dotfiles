#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
DOTFILES_REPO_URL="https://github.com/Vinicius-Chagas/dotfiles.git" # Using HTTPS is generally easier for initial clone
# DOTFILES_REPO_URL="git@github.com:Vinicius-Chagas/dotfiles.git" # Or use SSH if key is set up
DOTFILES_DIR="$HOME/dotfiles" # Consistent location for dotfiles
REPO_PACKAGES_FILE="essential_packages/packages_repo.txt" # Relative to DOTFILES_DIR
AUR_PACKAGES_FILE="essential_packages/packages_aur.txt"   # Relative to DOTFILES_DIR

echo "Starting dotfiles setup and package installation..."

# --- Installing git ---
echo "Ensuring git is installed..."
# Use --needed for idempotency
sudo pacman -S --needed --noconfirm git || { echo "Error: Failed to install git."; exit 1; }
echo "Git installation finished."

echo "" # Add a newline

# --- Clone or Update dotfiles ---
echo "Cloning or updating dotfiles..."
if [ -d "$DOTFILES_DIR" ]; then
    echo "Dotfiles directory '$DOTFILES_DIR' already exists. Attempting to update..."
    cd "$DOTFILES_DIR" || { echo "Error: Could not change directory to $DOTFILES_DIR"; exit 1; }
    git pull origin main || git pull origin master # Or your main branch name
    # Add basic check if pull succeeded? git status?
    echo "Dotfiles update finished."
else
    echo "Cloning dotfiles into '$DOTFILES_DIR'..."
    # Requires git to be installed (usually is on Arch ISO, or install with pacman -S git)
    git clone "$DOTFILES_REPO_URL" "$DOTFILES_DIR" || { echo "Error: Git clone failed."; exit 1; }
    cd "$DOTFILES_DIR" || { echo "Error: Could not change directory to $DOTFILES_DIR"; exit 1; }
    echo "Dotfiles cloned successfully."
fi

echo "" # Add a newline

# --- Install Official Repository Packages ---
if [ -f "$REPO_PACKAGES_FILE" ]; then
    echo "Installing official repository packages from '$REPO_PACKAGES_FILE'..."
    # It's good practice to update system first
    sudo pacman -Syu --noconfirm || { echo "Error: System update failed."; } # Update system, allow failure but report

    # Use --needed to skip packages already installed
    # Use --noconfirm to avoid interactive prompts (use with caution!)
    # Add any other pacman flags you might need, like --cachedir or --clean
    # Using xargs is slightly safer than $(cat ...) for very long lists
    xargs sudo pacman -S --needed --noconfirm < "$REPO_PACKAGES_FILE" || { echo "Error: Failed to install repo packages."; }
    echo "Official repository package installation finished."
else
    echo "Warning: '$REPO_PACKAGES_FILE' not found in '$DOTFILES_DIR'. Skipping official repository package installation."
fi

echo "" # Add a newline

# --- Ensure base-devel is installed (needed for yay/AUR) ---
echo "Ensuring base-devel is installed..."
sudo pacman -S --needed --noconfirm base-devel || { echo "Error: Failed to install base-devel."; }
echo "base-devel check finished."

echo "" # Add a newline

# --- Install yay if not present ---
echo "Checking for yay..."
if ! command -v yay &> /dev/null; then
    echo "yay not found. Installing yay..."
    YAY_TEMP_DIR="/tmp/yay_build" # Use a temp directory outside dotfiles

    # Clean up previous build attempt if it exists
    if [ -d "$YAY_TEMP_DIR" ]; then
        echo "Removing existing temporary yay build directory..."
        rm -rf "$YAY_TEMP_DIR"
    fi

    # Build and install yay
    git clone https://aur.archlinux.org/yay.git "$YAY_TEMP_DIR" || { echo "Error: Git clone for yay failed."; exit 1; }
    cd "$YAY_TEMP_DIR" || { echo "Error: Could not change directory to $YAY_TEMP_DIR."; exit 1; }
    makepkg -si --noconfirm --skippgpcheck || { echo "Error: makepkg for yay failed."; exit 1; } # Added --skippgpcheck as keys can be an issue on fresh installs
    cd "$DOTFILES_DIR" || { echo "Error: Could not return to dotfiles directory after yay build."; exit 1; } # Return to dotfiles dir
    rm -rf "$YAY_TEMP_DIR" # Clean up temporary directory

    echo "yay installation finished."
else
    echo "yay is already installed."
fi

echo "" # Add a newline

# --- Install AUR Packages (using yay) ---
if [ -f "$AUR_PACKAGES_FILE" ]; then
    echo "Installing AUR packages from '$AUR_PACKAGES_FILE' using yay..."
    # Ensure yay is in PATH (sometimes needed in scripts immediately after install)
    export PATH="$PATH:/usr/bin" # yay is usually installed here

    # Use --needed and --noconfirm similar to pacman
    # --sudoloop keeps sudo credentials cached during builds
    # Using xargs for large lists
    xargs yay -S --needed --noconfirm --sudoloop < "$AUR_PACKAGES_FILE" || { echo "Error: Failed to install AUR packages."; }
    echo "AUR package installation finished."
else
    echo "Warning: '$AUR_PACKAGES_FILE' not found in '$DOTFILES_DIR'. Skipping AUR package installation."
fi

echo "" # Add a newline

# --- Stow setup ---
echo "Initializing stow..."
# Ensure we are in the dotfiles directory before running stow
if [ ! -d "$DOTFILES_DIR" ] || [ "$(pwd)" != "$DOTFILES_DIR" ]; then
    echo "Error: Not in the dotfiles directory '$DOTFILES_DIR'. Cannot run stow."
    exit 1
fi

# This assumes stow is installed (it should be if it was in packages_repo.txt
# or a dependency, but add a check for robustness)
if ! command -v stow &> /dev/null; then
    echo "Warning: stow command not found. Please install stow manually if needed (e.g., sudo pacman -S stow)."
    echo "Skipping stow setup."
else
    # Define the list of dotfiles directories to symlink (these are the 'packages' for stow)
    # !! IMPORTANT !! Update this list if you add new dotfiles directories in your repo
    STOW_PACKAGES="configs bash" # <--- **Customize this list with your actual package directory names**

    echo "Running stow for packages: $STOW_PACKAGES"
    # Run stow from the dotfiles directory ($DOTFILES_DIR), targeting the home directory ($HOME)
    # --adopt handles existing files by moving them into the repo first before linking
    # --verbose shows more output
    stow -v -t "$HOME" --adopt $STOW_PACKAGES || { echo "Warning: Stow failed. Check output for conflicts."; } # Allow failure but report
    echo "Stow initialization finished. Please check output for conflicts (e.g., files already exist)."
fi

echo "" # Add a newline

# --- Change remote origin to SSH ---
echo "Changing remote origin to ssh..."
# Ensure we are in the dotfiles directory to modify the git remote
if [ ! -d "$DOTFILES_DIR" ] || [ "$(pwd)" != "$DOTFILES_DIR" ]; then
    echo "Error: Not in the dotfiles directory '$DOTFILES_DIR'. Cannot change git remote."
    # This might be a fatal error depending on desired strictness
    exit 1
fi
git remote set-url origin "$SSH_REPO_URL" || { echo "Warning: Failed to change remote origin URL."; } # Allow failure but report
echo "Remote origin changed to $SSH_REPO_URL."

echo "" # Add a newline

echo "Setup script finished."
echo "Please review the output for any errors or warnings above."
echo "Manual steps may still be required, especially if warnings occurred."