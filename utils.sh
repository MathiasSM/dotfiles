#!/usr/bin/env sh

# =============================================================================
# To be sourced from scripts and used there
# =============================================================================

# tmpdir=$(mktemp -p "$TMPDIR" -d "$MKTEMP_TEMPLATE")
TMPDIR="${TMPDIR:-/tmp}"
MKTEMP_TEMPLATE_PREFIX="dotfiles-install"
MKTEMP_TEMPLATE="$MKTEMP_TEMPLATE_PREFIX.XXXX"

CURL_FLAGS_VERBOSE="-Lf"
CURL_FLAGS_SILENT="-LSsf" # It does show errors
CURL_FLAGS="$CURL_FLAGS_SILENT"

GIT_FLAGS_VERBOSE=""
GIT_FLAGS_SILENT="--quiet"
GIT_FLAGS="$GIT_FLAGS_SILENT"

APT_FLAGS_VERBOSE="-q"
APT_FLAGS_SILENT="-qq"
APT_FLAGS="$APT_FLAGS_SILENT"

FLATPAK_INSTALL_FLAGS_VERBOSE="--verbose"
FLATPAK_INSTALL_FLAGS_SILENT="--assumeyes --noninteractive"
FLATPAK_FLAGS="$FLATPAK_INSTALL_FLAGS_SILENT"
FLATPAK_INSTALL_FLAGS="$FLATPAK_INSTALL_FLAGS_SILENT"

STOW_FLAGS="--dotfiles"

# -----------------------------------------------------------------------------
# Parse common arguments

DRY_RUN="${DRY_RUN:-false}"
FORCE_INSTALL="${FORCE_INSTALL:-false}"
DEBUG="${DEBUG:-false}"
ARGS="$@"
parse_common_args() {
    for arg in ${ARGS[@]}; do
        case $arg in
            -f) FORCE_INSTALL=true;;
            -n) DRY_RUN=true;;
            -d) DEBUG=true;;
        esac
    done
}

# -----------------------------------------------------------------------------
# Lines, like the separators in this file

bigline(){
    local terminal_width=$(tput cols)
    printf '%*s\n' "$terminal_width" '' | tr ' ' '='
}
line(){
    local terminal_width=$(tput cols)
    printf '%*s\n' "$terminal_width" '' | tr ' ' '-'
}

# -----------------------------------------------------------------------------
# Nested logging

LOG_GROUP_SEP="  " # Meant to be constant
LOG_PREFIX=""      # Meant to hold the state
start_log_group(){
    echo "$LOG_PREFIX$1"
    LOG_PREFIX="$LOG_PREFIX$LOG_GROUP_SEP"
}
end_log_group(){
    LOG_PREFIX="${LOG_PREFIX%$LOG_GROUP_SEP}" 
}

# -----------------------------------------------------------------------------
# Debug / dryrun

NC='\e[0m' # No Color
debug() {
    local purple='\e[0;35m'
    [[ "$DEBUG" == "true" ]] && echo -e "${purple}[DEBUG] $@${NC}" || true
}

dry_run() {
    local orange="\e[0;33m"
    if [[ $DRY_RUN == "true" ]]; then
        echo -e "${orange}[dryrun] ${@}${NC}"
        return
    fi
    debug "Running: $@"
    "$@"
    return $?
}

# -----------------------------------------------------------------------------
# Traps

clean_temp() {
    # Usage:
    # trap clean_temp SIGHUP SIGQUIT SIGABRT SIGTERM
    local result="$?"
    echo "WAIT! Got a $1"
    echo "Cleaning up before exit..."
    local to_remove="$TMPDIR/$MKTEMP_TEMPLATE_PREFIX*"
    echo "- Removing lefover files ($to_remove)..."
    rm -rf "$to_remove"
    echo "Done cleaning!"
    exit $result
}

# -----------------------------------------------------------------------------
# "Setters"

set_dry_run() {
    DRY_RUN=true
    echo "Dry run active. Will print, but not execute destructive commands."
}
set_debug() {
    CURL_FLAGS="$CURL_FLAGS_VERBOSE"
    GIT_FLAGS="$GIT_FLAGS_VERBOSE"
    APT_FLAGS="$APT_FLAGS_VERBOSE"
    FLATPAK_INSTALL_FLAGS="$FLATPAK_INSTALL_FLAGS_VERBOSE"
    echo "Debug logging active. Some commands used will also be noisier."
}

