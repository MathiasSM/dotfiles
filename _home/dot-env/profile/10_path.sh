#!/usr/bin/env bash


# Paths configuration extracted here, since
# macOS runs a path_helper that reorders the PATH, and I hate that. As such...
#
# This file is to be sourced AFTER:
# - Bash (interactive login): /etc/profile
#   therefore, source from: ~/.profile
# - Zsh (any): /etc/zprofile (which implies /etc/zshenv and ~/.zshenv)
#   therefore, source from: ~/.zprofile
#
# So: source from .profile, and source that from .zprofile
#
# NOTE: PATH is being set. Be aware of what's available as needed.


# macOS
# =============================================================================
# macOS-only additions (mostly homebrew's <something>)
if [ "$OS" = "macos" ]; then
    # Put brew paths
    if [ "$ARCH" = "x86_64" ]; then
        brew_binary="/usr/local/bin/brew"
        [ -f "$brew_binary" ] && eval "$($brew_binary shellenv "$USING_SHELL")"
        unset brew_binary
    elif [ "$ARCH" = "arm64" ]; then
        apple_brew="/opt/homebrew/bin/brew"
        [ -f "$apple_brew" ] && eval "$($apple_brew shellenv "$USING_SHELL")"
        unset apple_brew
    else
        echo "Could not find brew for $ARCH, to run brew shellenv" 1>&2
    fi

    # Check homebrew caveats (helper exists in this repo) to see these:
    
    # GNU binaries
    export PATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"
    export PATH="$HOMEBREW_PREFIX/opt/gawk/libexec/gnubin:$PATH"
    export PATH="$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin:$PATH"
    export PATH="$HOMEBREW_PREFIX/opt/gnu-tar/libexec/gnubin:$PATH"
    export PATH="$HOMEBREW_PREFIX/opt/gnu-which/libexec/gnubin:$PATH"
    export PATH="$HOMEBREW_PREFIX/opt/grep/libexec/gnubin:$PATH"
    export PATH="$HOMEBREW_PREFIX/opt/libtool/libexec/gnubin:$PATH"

    # Ruby gem binaries
    export PATH="$HOMEBREW_PREFIX/lib/ruby/gems/3.4.0/bin:$PATH"

    # Postgres
    export PATH="$HOMEBREW_PREFIX/opt/postgresql@16/bin:$PATH"

    # MANPATH is automatically updated without touching the variable
fi

export PATH="$XDG_BIN_HOME:$PATH"
