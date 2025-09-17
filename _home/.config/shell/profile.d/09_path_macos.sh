#!/usr/bin/env sh

# =============================================================================
# To be sourced from .profile ONLY
# =============================================================================

# NOTE: PATH is being set. Be aware of what's available as needed.

# macOS-only additions (mostly homebrew's <something>)
# macOS runs a path_helper that reorders the PATH, and I hate that.

if [ "$OS" = "macos" ]; then
    # Put brew paths
    brew_binary=
    case "$ARCH" in
        x86_64) brew_binary="/usr/local/bin/brew";;
        arm64)  brew_binary="/opt/homebrew/bin/brew";;
        *)      echo "Could not find brew for $ARCH, to run shellenv" 1>&2;;
    esac
    [ -f "$brew_binary" ] && eval "$($brew_binary shellenv "$USING_SHELL")"
    unset brew_binary

    # NOTE: Check homebrew caveats to update this
    
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

