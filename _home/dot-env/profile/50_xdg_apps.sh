#!/usr/bin/env bash

# This file is to be sourced EARLY. E.g. at or before
# - Bash (interactive login): .bash_profile, .bash_login, .profile (first of)
# - Bash (intera. non-login): .bashrc
# - Zsh (any): .zprofile
# 
# NOTE: MUST ONLY use shell commands/builtins
#       PATH has not been set. Avoid setting aliases and functions as well

if [ "$IS_XDG_CONFIGURED" != "true" ]; then 
    echo "Please source BASE config from .zshenv" 1>&2
fi

# XDG Configuration for things
# =============================================================================

# Android
export ANDROID_USER_HOME="$XDG_DATA_HOME/android"

# AWS
export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME/aws/credentials"
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME/aws/config"

# Cargo (Rust)
export CARGO_HOME="$XDG_DATA_HOME/cargo"

# Docker 
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"

# Elinks
export ELINKS_CONFDIR="$XDG_CONFIG_HOME/elinks"

# Gems (Ruby)
export GEM_HOME="$XDG_DATA_HOME/gem"
export GEM_SPEC_CACHE="$XDG_CACHE_HOME/gem"

# Go
export GOPATH="$XDG_DATA_HOME/go"

# Haskell
export GHCUP_USE_XDG_DIRS=true

# GnuPG (Careful if changing default)
export GNUPGHOME="$XDG_DATA_HOME/gnupg"

# Gradle
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"

# Less
export LESSHISTFILE="$XDG_STATE_HOME/less/history"

# Terminfo
export TERMINFO_DIRS="$XDG_DATA_HOME/terminfo:/usr/share/terminfo"

# Node REPL
export NODE_REPL_HISTORY="$XDG_DATA_HOME/node_repl_history"

# Nodenv (Node)
export NODENV_ROOT="$XDG_DATA_HOME/nodenv"

# Npm
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export NPM_CONFIG_TMP="$XDG_RUNTIME_DIR/npm"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NPM_CONFIG_INIT_MODULE="$XDG_CONFIG_HOME/npm/config/npm-init.js"

# Nvm
export NVM_DIR="$XDG_DATA_HOME/nvm"

# Plenv (Perl)
export PLENV_ROOT="$XDG_DATA_HOME/plenv"

# Python
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc.py"
[ -f "$(dirname "$PYTHONSTARTUP")" ] \
    || mkdir -p "$(dirname "$PYTHONSTARTUP")"
[ -f "$PYTHONSTARTUP" ] \
    || : > "$PYTHONSTARTUP"
[ -f "$XDG_STATE_HOME/python_history" ] \
    || : > "$XDG_STATE_HOME/python_history"

# Pyenv (Python)
export PYENV_ROOT="$XDG_DATA_HOME/pyenv"

# Rustup (Rust)
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"

# Stack (Haskell)
export STACK_XDG=true

# Wget
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
wget() {
    command wget --hsts-file="$XDG_DATA_HOME/wget-hsts"
}

# X
export ICEAUTHORITY="$XDG_CACHE_HOME/ICEauthority"
export ERRFILE="$XDG_CACHE_HOME/X11/xsession-errors"
