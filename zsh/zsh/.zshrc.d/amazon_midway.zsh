#!/usr/bin/env zsh

function midway_expiration_raw() {
    local midway_header="HttpOnly_midway-auth.amazon.com"
    local midway_cookie="$HOME/.midway/cookie"
    grep $midway_header $midway_cookie | cut -d $'\t' -f 5
}
function midway_expiration_date() {
    midway_expiration_raw | date
}

function midway_expired() {
    [ $(midway_expiration_raw) -lt $(date +%s) ]
}

