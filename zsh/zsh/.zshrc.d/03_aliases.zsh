#!/usr/bin/env zsh

# Annoying glob (taken from zprezto scripts)
# -----------------------------------------------------------------------------
alias bower='noglob bower'
alias fc='noglob fc'
alias find='noglob find'
alias ftp='noglob ftp'
alias history='noglob history'
alias locate='noglob locate'
alias rake='noglob rake'
alias rsync='noglob rsync'
alias scp='noglob scp'
alias sftp='noglob sftp'

# Interactive modes
# -----------------------------------------------------------------------------
alias cp="${aliases[cp]:-cp} -i"
alias ln="${aliases[ln]:-ln} -i"
alias mv="${aliases[mv]:-mv} -i"
alias rm="${aliases[rm]:-rm} -i"

# ls
# -----------------------------------------------------------------------------
alias ls="${aliases[ls]:-ls} --group-directories-first"
alias l='ls -1A'   # One column + hidden files
alias ll='ls -lh'  # Human readable sizes
alias la='ll -A'   # ll + hidden files
alias lk='la -Sr'  # la + Sort by size (DESC)
alias lt='la -tr'  # la + Sort by modification date (DESC)
alias lu='la -tru' # la + Sort by access date (DESC)
alias lx='la -XB'  # la + Sort by extension (GNU only)

# df
# -----------------------------------------------------------------------------
alias df="${aliases[df]:-df} \
  --exclude-type=tmpfs \
  --exclude-type=devtmpfs \
  --human-readable \
  --block-size=1K \
  --print-type \
  --total"

# du
# -----------------------------------------------------------------------------
alias du="${aliases[du]:-du} \
  --human-readable \
  --block-size=1K \
  --total"

alias dui="du \
  --human-readable \
  --inodes \
  --total"

alias dus="du \
  --human-readable \
  --block-size=1K \
  --summarize"


# Contrib
# -----------------------------------------------------------------------------

# (git)hub
command -v hub >/dev/null && eval "$(hub alias -s)"


# Helpers
# -----------------------------------------------------------------------------

# List most used commands
alias histstat="history 0 \
  | awk '{print \$2}' \
  | sort | uniq -c \
  | sort -n -r | head"

# brew helper to list all caveats for installed programs
function brew_caveats() {
    local outputFormat=''
    outputFormat+='*Formula*: \(.full_name)\n'
    outputFormat+='*Description*: \(.desc)\n'
    outputFormat+='*Homepage*: \(.homepage)\n'
    outputFormat+='*Caveats*:\n'
    outputFormat+='\(.caveats)'
    brew info --installed --json | \
        jq -r "[.[]| select(.caveats != null) | \"$outputFormat\"] \
               | join(\"\n\n-----------------------------------\n\")"
}


# Defaults to 2022 to allow et to pass through
function tunnel() {
    echo "Opening SSH tunnel..."
    local port="${1:-2022}"
    ssh -L "$port":localhost:"$port" -f -NT \
        "-o ServerAliveInterval=5" \
        "-o ServerAliveCountMax=6" \
        "-o ConnectTimeout=30" \
        "-o ExitOnForwardFailure=yes" \
        cloud \
    && echo "Tunnel open!" || echo "Failed to open tunnel!"
}

# git aliases
function set_git_aliases() {
    local tab="%x09"
    local a_date="%C(blue)%ad"
    local s_hash="%C(yellow)(%h)"
    local refs="%C(red)%d" # Try %D
    local a_subject="%C(reset)%<|(100) %s"
    local c_name="%C(blue) [%cn]"
    export GIT_ALIAS_LOGG="$tab$a_date $s_hash$refs $a_subject$c_name"
    export GIT_ALIAS_LOGGA="$GIT_ALIAS_LOGGA"
    export GIT_ALIAS_LOGGA_GPG="$GIT_ALIAS_LOGGA %G? %GK"
}
set_git_aliases

