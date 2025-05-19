#!/usr/bin/env zsh

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

