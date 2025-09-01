#!/usr/bin/env bash

# NOTE: Consider mise: https://mise.jdx.dev/dev-tools/

_config_warnings=()

# Python
# -----------------------------------------------------------------------------
if [[ -x "$(command -v pyenv)" ]]; then
    eval "$(pyenv init - "$USING_SHELL")"
    # eval "$(pyenv virtualenv-init -)" # Makes prompt SLOW
    export PATH="$PYENV_ROOT/bin:$PATH"
else
    _config_warnings+=pyenv
fi


# Node
# -----------------------------------------------------------------------------
if [[ -x "$(command -v nodenv)" ]]; then 
    export PATH="$NODENV_ROOT/bin:$PATH"
    eval "$(nodenv init -)"
else 
    _config_warnings+=nodenv
fi

if [ -s "$NVM_DIR/nvm.sh" ]; then 
    . "$NVM_DIR/nvm.sh"
else 
    _config_warnings+=nvm
fi


# Perl
# -----------------------------------------------------------------------------
if [[ -x "$(command -v plenv)" ]]; then 
    export PATH="$PLENV_ROOT/bin:$PATH"
    eval "$(plenv init - zsh)"
else 
    _config_warnings+=plenv
fi


# Rust (Cargo)
# -----------------------------------------------------------------------------
if [ -s "$CARGO_HOME/env" ]; then
    source "$CARGO_HOME/env"
else
    _config_warnings+=cargo
fi


# Finally: log warnings
# =============================================================================
YELLOW='\033[0;33m'
YELLOW_BOLD='\033[1;33m'
NC='\033[0m' # No Color
printf -v _config_warnings "<%s>," "${_config_warnings[@]}"
echo -en "${YELLOW_BOLD}Warning! Skipped configurations: " 1>&2
echo -e "${YELLOW}Missing ${_config_warnings%,}.${NC}\n" 1>&2
