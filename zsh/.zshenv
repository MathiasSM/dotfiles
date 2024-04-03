#!/usr/bin/env zsh

# =============================================================================
# In order (always /etc/<file> before each):
#
# > $ZDOTDIR/.zshenv
# - $ZDOTDIR/.zprofile  (if login shell)
# - $ZDOTDIR/.zshrc     (if interactive)
# - $ZDOTDIR/.zpreztorc (zprezto)
# - $ZDOTDIR/.zlogin    (if login shell)
# - $ZDOTDIR/.zlogout   (if exiting a login shell)
# =============================================================================

# Setup
# =============================================================================
# Get the OS shortname for future reference
case "`uname -s`" in
    Linux*)     export OS=linux;;
    Darwin*)    export OS=macos;;
    CYGWIN*)    export OS=windows;;
    MINGW*)     export OS=windows;;
    *)          export OS="${unameOut}"
esac



# Platform specific
# =============================================================================
# macOS-only additions (mostly homebrew's <something>)
if [ $OS = "macos" ]; then
    # gnu-utils manual pages
    export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
    # Python
    export PATH="/usr/local/opt/python/libexec/bin:$PATH"
    # sbin
    export PATH="/usr/local/sbin:$PATH"
    # Java
    export JAVA_HOME="/Library/Java/Home"
    export PATH="$PATH:$JAVA_HOME/bin"
    # Postgres
    export PATH="/usr/local/opt/postgresql@16/bin:$PATH"
fi



# XDG
# ==============================================================================
# XDG folders
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Android
export ANDROID_USER_HOME="$XDG_DATA_HOME/android"
# AWS
export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME/aws/credentials"
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME/aws/config"
# Cargo (Rust)
export CARGO_HOME="$XDG_DATA_HOME/cargo"
# Gems (Ruby)
export GEM_HOME="$XDG_DATA_HOME/gem"
export GEM_SPEC_CACHE="$XDG_CACHE_HOME/gem"
# Haskell
export GHCUP_USE_XDG_DIRS=true
# GnuPG (Careful if changing default)
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
# Less
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
# Terminfo
export TERMINFO_DIRS="$XDG_DATA_HOME/terminfo:/usr/share/terminfo"
# Node REPL
export NODE_REPL_HISTORY="$XDG_DATA_HOME/node_repl_history"
# Nodenv (Node)
export NODENV_ROOT="$XDG_DATA_HOME/nodenv"
# Npm
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
# Plenv (Perl)
export PLENV_ROOT="$XDG_DATA_HOME/plenv"
# Python
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc.py"
touch -a "$XDG_STATE_HOME/python_history"
# Pyenv (Python)
export PYENV_ROOT="$XDG_DATA_HOME/pyenv"
# Stack (Haskell)
export STACK_XDG=true
# Wget
alias wget=wget --hsts-file="$XDG_DATA_HOME/wget-hsts"
# Zsh
export HISTFILE="$XDG_STATE_HOME/zsh/history"



# Shell configuration
# =============================================================================
# PATHs
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export MANPATH="/usr/local/man:$MANPATH"

# Editors
export LANG='en_US.UTF-8'
if which nvim > /dev/null; then
    export EDITOR='nvim'
    export VISUAL='nvim'
else
    echo "NeoVim ('nvim') not present, using vim as EDITOR"
    export EDITOR='vim'
    export VISUAL='vim'
fi

# Open externally
if [ $OS = "macos" ]; then export BROWSER='open'
else export BROWSER='xdg-open'; fi

# Pager
export PAGER='less'
export LESS='-g -i -M -R -F -S -w -X -z-4'
if [[ -z "$LESSOPEN" ]] && (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi

# `time` builtin
export TIMEFMT=$'-\n%J\nuser\t%U\nsystem\t%S\nreal\t%E\ncpu\t%P\nmem\t%MK'
# ls -l (at least): YYYY-MM-DD
export TIME_STYLE="+%Y-%m-%d"
# The following affects man, not sure what else
export LESS_TERMCAP_mb=$(tput bold; tput setaf 2) # green
export LESS_TERMCAP_md=$(tput bold; tput setaf 1) # red
export LESS_TERMCAP_me=$(tput sgr0)
export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4) # yellow on blue
export LESS_TERMCAP_se=$(tput rmso; tput sgr0)
export LESS_TERMCAP_us=$(tput bold; tput setaf 4) # white
export LESS_TERMCAP_ue=$(tput rmul; tput sgr0)
export LESS_TERMCAP_mr=$(tput rev)
export LESS_TERMCAP_mh=$(tput dim)
export LESS_TERMCAP_ZN=$(tput ssubm)
export LESS_TERMCAP_ZV=$(tput rsubm)
export LESS_TERMCAP_ZO=$(tput ssupm)
export LESS_TERMCAP_ZW=$(tput rsupm)



# Languages and environments
# =============================================================================

# Python
export PATH="$PYENV_ROOT/bin:$PATH"
if which pyenv > /dev/null; then
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
else
  echo "Missing 'pyenv', skipping its config"
fi

# Node
export PATH="$NODENV_ROOT/bin:$PATH"
if which nodenv > /dev/null; then eval "$(nodenv init -)"
else echo "Missing 'nodenv', skipping its config"; fi

# Perl
export PATH="$HOME/.plenv/bin:$PATH"
if which plenv > /dev/null; then eval "$(plenv init - zsh)"
else echo "Missing 'plenv', skipping its config"; fi



# Some aliases
# ==============================================================================
alias ls="ls --color=auto"

local tab="%x09"
local a_date="%C(blue)%ad"
local s_hash="%C(yellow)(%h)"
local refs="%C(red)%d" # Try %D
local a_subject="%C(reset)%<|(100) %s"
local c_name="%C(blue) [%cn]"
export GIT_ALIAS_LOGG="$tab$a_date $s_hash$refs $a_subject$c_name"
export GIT_ALIAS_LOGGA="$tab$a_date $s_hash$refs $a_subject$c_name"
export GIT_ALIAS_LOGGA_GPG="$tab$a_date $s_hash$refs $a_subject$c_name %G? %GK"



# Finally...
# =============================================================================
# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN ) && -s "$HOME/.zprofile" ]]; then
  source "$HOME/.zprofile"
fi
