# My Arch Linux Dotfiles and Setup Script

This repository contains my personal Arch Linux configuration files (dotfiles) and an automated script to help set up a new Arch Linux installation quickly.

The setup script handles installing essential packages from the official repositories and the AUR, cloning the dotfiles, and setting them up using GNU Stow.

## **⚠️ Important Security Notice: SSH Keys**

**DO NOT** store your private SSH keys (`~/.ssh/id_rsa`, etc.) in this or any other Git repository. Private keys must be kept secure and transferred to new machines manually via a secure method (e.g., encrypted USB drive, secure cloud storage).

This script uses the **HTTPS URL** (`https://github.com/Vinicius-Chagas/dotfiles.git`) for the initial clone, which does not require your SSH key. If you change the script to use the SSH URL (`git@github.com:...`), you MUST set up your SSH key *before* running the script.

## Prerequisites

Before running the script, you should have:

1.  A fresh Arch Linux installation.
2.  A non-root user account with `sudo` privileges.
3.  An active internet connection.
4.  Basic access to a terminal on the new system.

## How to Use the Setup Script

The script itself is located within this repository. You need to get the repository cloned onto your new machine first.

1.  Log in to your regular user account on the new Arch system.
2.  Open a terminal.
3.  Clone this dotfiles repository. It's recommended to clone it to a standard location like `~/.dotfiles`. Git is usually available on the Arch install ISO, and the script will ensure it's fully installed later.

    ```bash
    git clone [https://github.com/Vinicius-Chagas/dotfiles.git](https://github.com/Vinicius-Chagas/dotfiles.git) ~/.dotfiles
    ```
    *(If you encounter issues with `git clone`, ensure `git` is installed: `sudo pacman -S git`)*

4.  Navigate into the cloned dotfiles directory:

    ```bash
    cd ~/.dotfiles
    ```

5.  Make the setup script executable:

    ```bash
    chmod +x install_script.sh # Adjust name if yours is different
    ```

6.  Run the script:

    ```bash
    ./install_script.sh
    ```

    The script will ask for your `sudo` password when necessary to install packages.

## What the Script Does

The `install_script.sh` performs the following steps:

1.  **Installs `git`:** Ensures the Git command is available.
2.  **Clones/Updates Dotfiles:** Clones this repository to `~/.dotfiles` if it doesn't exist, or pulls the latest changes if it does.
3.  **Installs Official Packages:** Reads the list of packages from `essential_packages/packages_repo.txt` and installs them using `sudo pacman -S --needed --noconfirm`. It includes a system update (`pacman -Syu`) first.
4.  **Installs `base-devel`:** Ensures the essential build tools required for compiling AUR packages are installed.
5.  **Installs `yay`:** Checks if the `yay` AUR helper is installed. If not, it downloads, builds, and installs it from the AUR.
6.  **Installs AUR Packages:** Reads the list of packages from `essential_packages/packages_aur.txt` and installs them using `yay -S --needed --noconfirm --sudoloop`.
7.  **Initializes Stow:** Runs `stow -t "$HOME" .` from the `~/.dotfiles` directory to create symbolic links for your configuration files in your home directory.

## Important Considerations

* **`--noconfirm`:** The script uses the `--noconfirm` flag for `pacman` and `yay`. This means it will automatically proceed with installations/updates without asking for confirmation. **Review the package lists (`packages_repo.txt`, `packages_aur.txt`) before running the script** to ensure you know what will be installed.
* **`--sudoloop`:** The `yay` command uses `--sudoloop` to keep your sudo credentials cached during AUR builds, reducing password prompts.
* **Stow Conflicts:** When `stow` runs, it might report errors if configuration files it tries to link already exist in your home directory (e.g., default configuration files created by installing packages). You will need to resolve these manually by either deleting or moving the conflicting files before running `stow -t "$HOME" .` again for the specific conflicting packages.
* **Review Output:** Pay attention to the script's output. Look for any errors or warnings, especially during package installations (AUR builds can sometimes fail) or the stow process.
* **Running as User:** The script is designed to be run as your regular user account with `sudo` access.
* **Partial Failures:** The script uses `set -e` for critical failures (like `git clone` or `makepkg` for yay), but allows non-fatal errors (like individual package installs or stow conflicts) to issue a warning and continue. If the script stops due to `set -e`, address the error and re-run the script; the `--needed` flags and existence checks will help it resume.

## Customization

* Modify the package lists (`essential_packages/packages_repo.txt` and `essential_packages/packages_aur.txt`) to include your desired software.
* Modify the `DOTFILES_REPO_URL` variable at the top of the script if you fork this repository or use a different URL.
* Adjust the `DOTFILES_DIR` variable if you prefer to clone your dotfiles to a different location.

## License

[Optional: Add a link to your license file, e.g., MIT License]

---

Enjoy your quickly set up Arch Linux system!
