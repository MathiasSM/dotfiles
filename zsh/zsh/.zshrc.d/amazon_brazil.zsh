#!/usr/bin/env zsh

export BRAZIL_WORKSPACE_DEFAULT_LAYOUT=short

# Attempt to filter out noisy logs
function clean_brazil() {
    local grep_args=("--line-buffered" "--color=always" "-E")
    eval "$@" \
        2>&1 | grep ${grep_args[@]} -v "^WARNING: Duplicate key.*Replacing" \
        2>&1 | grep ${grep_args[@]} -v "....-..-.. ..:..:.. INFO Caching" \
        2>&1 | grep ${grep_args[@]} -v "\s*\[echo\]\s*Replacing.*dependency" \
        2>&1 | grep ${grep_args[@]} -v "\s*Replacing.*dependency" \
        2>&1 | grep ${grep_args[@]} -v "\s*\[echo\]\s*Removing.*dependency" \
        2>&1 | grep ${grep_args[@]} -v "\s*Removing.*dependency" \
        2>&1 | grep ${grep_args[@]} -v "\s*\[copy\]\s*Copying" \
        2>&1 | grep ${grep_args[@]} -v "\s*Copying" \
        2>&1 | grep ${grep_args[@]} -v "\s*\[echo\]\s*Copying" \
        2>&1 | grep ${grep_args[@]} -v "\s*Copying" \
        2>&1 | grep ${grep_args[@]} -v "\s*\[delete\]\s" \
        2>&1 | grep ${grep_args[@]} -v "\s*\[mkdir\]\s" \
        2>&1 | grep ${grep_args[@]} -v "WARNING: Duplicate key" \
        2>&1 | sed '/^\s*$/N;/^\n$/D';
    local result="${pipestatus[1]}";
    return result

}

# brazil-build
function bb() {
    NPM_CONFIG_COLOR=always FORCE_COLOR=true "brazil-build" "$@"
}
function bbc() {
    NPM_CONFIG_COLOR=always FORCE_COLOR=true clean_brazil "brazil-build" "$@"
}


# brazil-runtime-exec
function bre() { clean_brazil "brazil-runtime-exec $@" }

# brazil-recursive-cmd
function bball {
    local row1=$(printf "%*s\n" "${COLUMNS:-$(tput cols)}" '' | tr ' ' =)
    local row2=$(printf "%*s\n" "${COLUMNS:-$(tput cols)}" '' | tr ' ' -)
    local cmd_list=(
        'cd "%s"'
        '&& echo'
        '&& echo "$(tput setaf 117)$(tput bold)'$row1'"'
        '&& echo "$(basename $PWD) (RECURSIVE CMD \"%s\")"'
        '&& echo "'$row2'$(tput sgr0)"'
        '&& (NPM_CONFIG_COLOR=always FORCE_COLOR=true %s)'
    )
    local cmds=`echo "$cmd_list"`
    local brc_cmd;
    printf -v brc_cmd "$cmds" '$sourcePath' "$*" "$*"
    clean_brazil "brazil-recursive-cmd --allPackages '$brc_cmd'"
}                    
function bblist {
    printf -v brc_cmd 'echo $(basename %s)' '$sourcePath'
    brazil-recursive-cmd --allPackages "$brc_cmd"
}

# ?
function cdb() {
    local THERE=$PWD
    local PKG_INFO_FILE='packageInfo'

    while [ "$THERE" != "/" ]; do
        [[ -e $THERE/$PKG_INFO_FILE ]] && { break; }
        THERE=$(dirname $THERE)
    done
    [[ -e $THERE/$PKG_INFO_FILE ]] && { echo $THERE; cd $THERE; }
}

