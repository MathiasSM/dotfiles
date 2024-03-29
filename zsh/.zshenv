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
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:=$HOME/.config}"

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



# Shell configuration
# =============================================================================
# PATHs
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export MANPATH="/usr/local/man:$MANPATH"

# Editors
export LANG='en_US.UTF-8'
export EDITOR='nvim'
export VISUAL='nvim'

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



# Languages and environments
# =============================================================================

# Python
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
if which pyenv > /dev/null; then
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
else
  echo "Missing 'pyenv'"
fi

# Node
export NODENV_ROOT="$HOME/.nodenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$NODENV_ROOT/bin:$PATH"
if which nodenv > /dev/null; then eval "$(nodenv init -)"
else echo "Missing 'pyenv'"; fi

# Perl
export PATH="$HOME/.plenv/bin:$PATH"
if which plenv > /dev/null; then eval "$(plenv init - zsh)"
else echo "Missing 'plenv', skipping config"; fi

# Haskell
export GHCUP_USE_XDG_DIRS=true


# Some aliases
# ==============================================================================
alias ls="ls --color=auto"

tab="%x09"
a_date="%C(blue)%ad"
s_hash="%C(yellow)(%h)"
refs="%C(red)%d" # Try %D
a_subject="%C(reset)%<|(100) %s"
c_name="%C(blue) [%cn]"
export GIT_ALIAS_LOGG="$tab$a_date $s_hash$refs $a_subject$c_name"
export GIT_ALIAS_LOGGA="$tab$a_date $s_hash$refs $a_subject$c_name"
export GIT_ALIAS_LOGGA_GPG="$tab$a_date $s_hash$refs $a_subject$c_name %G? %GK"


# Finally...
# =============================================================================
# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN ) && -s "$HOME/.zprofile" ]]; then
  source "$HOME/.zprofile"
fi

