#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'

export ANDROID_HOME=~/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
export EDGE_PATH=/usr/bin/vivaldi  
export PATH="$PATH:/home/vinicius/.config/Code/User/globalStorage/ms-dotnettools.vscode-dotnet-runtime/.dotnet/9.0.4~x64~aspnetcore"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="$PATH:`yarn global bin`"
/usr/bin/keychain ~/.ssh/bitbucketKey # Add all your keys here
source ~/.keychain/$HOSTNAME-sh
source /usr/share/bash-completion/completions/git

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"
eval "$(pyenv virtualenv-init -)"

parse_git_branch() {
git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
# Check if running interactively (for non-login shells like terminal emulators)
if [[ $- == *i* ]]; then
  # Check if we have a tty (to determine if we should use colors)
  if [[ -t 1 ]]; then  # Check if stdout is a terminal
    color_prompt=yes
  else
    color_prompt=no
  fi

  # Set PS1 based on color_prompt
  if [[ "$color_prompt" == "yes" ]]; then
    PS1='\[\e[01;32m\]\u@\h\[\e[00m\]:\[\e[01;34m\]\w\[\e[33m\]$(parse_git_branch)\[\e[00m\]\$ '
  else
    PS1='\[\u@\h:\w\]$(parse_git_branch)\$ '
  fi
fi
source /usr/share/nvm/init-nvm.sh
