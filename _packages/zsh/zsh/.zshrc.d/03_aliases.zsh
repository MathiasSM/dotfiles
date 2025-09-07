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

# git log aliases
function f() {
    local tab="%x09"
    local a_date="%C(blue)%ad"
    local s_hash="%C(yellow)(%h)"
    local refs="%C(red)%(decorate:prefix=  ,suffix=)" # Try %D
    local a_subject="%C(reset)%<|(100) %s"
    local a_name="%C(blue) [%al]"
    export GIT_ALIAS_LOGG="$tab$a_date $s_hash$refs $a_subject$a_name"
    export GIT_ALIAS_LOGGA="$GIT_ALIAS_LOGG"
    export GIT_ALIAS_LOGGA_GPG="$GIT_ALIAS_LOGGA %G? %GK"
    # Default:
    export GIT_ALIAS_LOG="$GIT_ALIAS_LOGG"
}; f; unset -f f;

function git-graphviz() {
    date=$(date);
    # Start the graph 
    echo "digraph GIT {"
    echo "fontname=\"Helvetica\";"
    echo "label=\"$0 $@\n$PWD\n$date\";"
    # Print node links
    # how to skip the '*' character?
    for branchname in `git for-each-ref --format="%(refname)" --sort=committerdate refs/heads`; do
      cleanName=`echo $branchname | sed 's/\//_/g'`
      branchLabelName=`echo $branchname | sed 's/refs\/[A-Za-z]*\///'`
      # Get the output from git log
      log=$(git log "$branchname" --pretty="%H -> %P ;" "$@" 2> /dev/null);
      # If $log is non-empty...
      if [[ $log ]]; then
        # Create write out a cluster with all links in it.
        echo "	subgraph cluster_$cleanName {";
        echo "    label=\"$branchLabelName\";";
        echo "    fontsize=24;";
        echo "    color=blue;";
        echo "    style=dotted;";
        echo $log | \
    # This will work for commits with two parents; but not an 'octopus merge' with 3.
          sed 's/\( *[0-9a-f]\{40\} *-> *\)\([0-9a-f]\{40\}\) *\([0-9a-f]\{40\}\)/\1\2\;\1\3/g' | \
    # This will work for commits with three parents e.g. an octopus merge .
          sed 's/\( *[0-9a-f]\{40\} *-> *\)\([0-9a-f]\{40\}\) *\([0-9a-f]\{40\}\) *\([0-9a-f]\{40\}\)/\1\2\;\1\3;\1\4/g' | \
    # Ensures that the root commit has something to link to.
          sed 's/-> *;/-> \"root\";/' |\
    # Set direction to back
          sed 's/;/\[dir=back\];/g' |\
    # puts quotes around all commit hashes
          sed 's/[0-9a-f]\{40\}/\"&\"/g' |\
    # Split any merge commits over multiple lines
          sed 's/\[dir=back\];/&\'$'\n/g'
        echo "  }";
      fi;
    done;

    # Write out all of the nodes with an appropriate label.
    echo \# Node list
    git log --decorate=full --all --boundary --pretty="  __HASH__%H [label=__DOUBLE_QUOTE__%d__NEW_LINE__%s__NEW_LINE__%cr__DOUBLE_QUOTE__,shape=__SHAPE__,style=__STYLE__,color=__COLOR__,fillcolor=__FILLCOLOR__]" "$@"|
    # Escape all escape chars
      sed 's/\\/\\\\/g' |
    # Escape all quote marks
      sed 's/\"/\\\"/g' |
    # Replaces newlines immediately following the label tag
      sed 's/__DOUBLE_QUOTE____NEW_LINE__/__DOUBLE_QUOTE__/g' |
    # Replace __DOUBLE_QUOTE__ with an escapes "
      sed 's/__DOUBLE_QUOTE__/\"/g' |
    # Replace __NEW_LINE__ with newline character
      sed 's/__NEW_LINE__/\\n/g' |
    # puts quotes around all commit hashes 
      sed 's/__HASH__\([0-9a-f]\{40\}\)/\"\1\"/g' |
    # Change the style of nodes that are head refs
      sed '/(.*\/heads\/.*)/s/__STYLE__/filled/' |
      sed '/(.*\/heads\/.*)/s/__SHAPE__/tripleoctagon/' |
      sed '/(.*\/heads\/.*)/s/__FILLCOLOR__/salmon/' |
    # Change the style of nodes that are tag refs
      sed '/(.*\/tags\/.*)/s/__STYLE__/filled/' |
      sed '/(.*\/tags\/.*)/s/__SHAPE__/box/' |
      sed '/(.*\/tags\/.*)/s/__FILLCOLOR__/palegreen1/' |
    # Change the style of all remaining nodes
      sed 's/__SHAPE__/box/' |
      sed 's/__STYLE__/filled/' |
      sed 's/__FILLCOLOR__/white/' |
      sed 's/__COLOR__/black/'

    # End the graph 
    echo "}"
}

# Go to git repo's top-level directory
alias cg='cd `git rev-parse --show-toplevel`'

