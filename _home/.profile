#!/usr/bin/env sh

# =============================================================================
# To be sourced from .zprofile (or .bash_profile if needed)
# =============================================================================
#
# Must set PATH
#
# -----------------------------------------------------------------------------

if [ "$IS_BASE_CONFIGURED" != "true" ]; then 
    echo "Please source BASE config from .zshenv" 1>&2
fi

for f in $HOME/.env/profile/*; do
   . "$f"
done
