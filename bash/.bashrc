#
# ~/.bashrc
#
# This file is sourced by bash for interactive shells.
# It's a good place to set aliases, functions, and environment variables.

# --- Initial Setup / Boilerplate ---
# If not running interactively, don't do anything.
# This prevents the script from causing issues for non-interactive bash processes.
[[ $- != *i* ]] && return

# Check if we are in a terminal to decide on color prompts later
if [[ -t 1 ]]; then  # Check if stdout is a terminal
  color_prompt=yes
else
  color_prompt=no
fi

# --- Aliases ---
# Define common aliases for frequently used commands.
alias ls='ls --color=auto'
alias grep='grep --color=auto'
# Add more aliases here as needed.

# --- Environment Variables ---
# Set general environment variables.

# Example: Set a path for Edge/Vivaldi if needed (Note: Hardcoded path might need review)
export EDGE_PATH="/usr/bin/vivaldi"

# Export global bin
export PATH="/usr/bin:$PATH"

#Export local time
export LC_TIME="pt_BR.UTF-8"
export LANG="pt_BR.UTF-8"

# --- Path Modifications ---
# Add specific directories to the PATH environment variable.
# Order matters: paths earlier in the list are searched first.
# Appending to $PATH is generally safer for user-installed tools.

# Add Yarn global bin directory to PATH
# Check if yarn command exists before trying to add its bin path
if command -v yarn > /dev/null 2>&1; then
  export PATH="$PATH:`yarn global bin`"
fi

# Add a specific .NET runtime path to PATH
# !! NOTE: This path contains a version number (9.0.4).
# !! You will need to update this line if you install a different runtime version.
export PATH="$PATH:/home/vinicius/.config/Code/User/globalStorage/ms-dotnettools.vscode-dotnet-runtime/.dotnet/9.0.4~x64~aspnetcore"

# --- Tool-Specific Setup ---
# Initialize or configure specific development tools and version managers.

# Android SDK
# Check if the SDK directory exists before setting variables and modifying PATH
if [ -d "$HOME/Android/Sdk" ]; then
  export ANDROID_HOME="$HOME/Android/Sdk" # Use $HOME instead of /home/username
  export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"
fi

# NVM (Node Version Manager)
# Ensure NVM_DIR is set and source the nvm.sh and bash_completion scripts
# The standard installation script sources these into ~/.nvm
export NVM_DIR="$HOME/.nvm"
# Check if the nvm.sh script file exists before sourcing it
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"       # This loads nvm
# Check if the bash_completion script file exists before sourcing it
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# !! Removed redundant NVM sourcing line: source /usr/share/nvm/init-nvm.sh
# !! This file is usually for package-managed NVM, which conflicts with user install in ~/.nvm

# Pyenv (Python Version Manager)
# Ensure PYENV_ROOT is set and initialize pyenv
export PYENV_ROOT="$HOME/.pyenv"
# Add pyenv bin to PATH if the directory exists
if [ -d "$PYENV_ROOT/bin" ]; then
  export PATH="$PYENV_ROOT/bin:$PATH" # Pyenv often prepends its bin to ensure its shims are found first
  # Initialize pyenv
  eval "$(pyenv init - bash)"
  # Initialize pyenv-virtualenv (if installed)
  eval "$(pyenv virtualenv-init -)"
fi

# Keychain (SSH Key Management)
# Add your SSH keys to the keychain agent and source its output
# Ensure the keychain command exists before using it
if command -v keychain > /dev/null 2>&1; then
  # Add your SSH key files here. Example: ~/.ssh/id_rsa, ~/.ssh/my_other_key
  /usr/bin/keychain ~/.ssh/bitbucketKey # Add all your keys here, separated by spaces
  # Check if the keychain output file exists before sourcing it
  if [ -f "$HOME/.keychain/$HOSTNAME-sh" ]; then
    source "$HOME/.keychain/$HOSTNAME-sh"
  fi
fi

# --- Git Completion ---
# Source the official bash completion script for Git commands.
# Check if the file exists before sourcing it
if [ -f "/usr/share/bash-completion/completions/git" ]; then
  source /usr/share/bash-completion/completions/git
fi


# --- Prompt Customization (PS1) ---
# Define the bash prompt appearance.

# Function to parse the current Git branch
parse_git_branch() {
  # Redirect stderr to /dev/null for quiet operation when not in a git repo
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# Set PS1 based on whether colors are enabled
if [[ "$color_prompt" == "yes" ]]; then
 # Colorized prompt: user@host:working_dir(git_branch)$
 PS1='\[\e[01;32m\]\u@\h\[\e[00m\]:\[\e[01;34m\]\w\[\e[33m\]$(parse_git_branch)\[\e[00m\]\$ '
else
 # Standard prompt: user@host:working_dir(git_branch)$
 PS1='\[\u@\h:\w\]$(parse_git_branch)\$ '
fi

# --- End of ~/.bashrc ---