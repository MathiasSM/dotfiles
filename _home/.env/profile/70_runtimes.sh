#!/usr/bin/env bash

# NOTE: Consider mise: https://mise.jdx.dev/dev-tools/


# Python
# -----------------------------------------------------------------------------
if which pyenv > /dev/null; then
    eval "$(pyenv init - "$USING_SHELL")"
    # eval "$(pyenv virtualenv-init -)" # Makes prompt SLOW
    export PATH="$PYENV_ROOT/bin:$PATH"
else
    echo "Missing 'pyenv', skipping its config" 1>&2
fi


# Node
# -----------------------------------------------------------------------------
if which nodenv > /dev/null; then 
    export PATH="$NODENV_ROOT/bin:$PATH"
    eval "$(nodenv init -)"
else 
    echo "Missing 'nodenv', skipping its config" 1>&2
fi

if [ -s "$NVM_DIR/nvm.sh" ]; then 
    . "$NVM_DIR/nvm.sh"
else 
    echo "Missing 'nvm' script, skipping its config" 1>&2
fi


# Perl
# -----------------------------------------------------------------------------
if which plenv > /dev/null; then 
    export PATH="$PLENV_ROOT/bin:$PATH"
    eval "$(plenv init - zsh)"
else 
    echo "Missing 'plenv', skipping its config" 1>&2
fi


# Rust (Cargo)
# -----------------------------------------------------------------------------
if [ -s "$CARGO_HOME/env" ]; then
    source "$CARGO_HOME/env"
else
    echo "Missing 'cargo', skipping its config" 1>&2
fi

