#!/usr/bin/env bash

mode="$1"
delay="$2"

maim_args=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --delay|-d)
            if [[ -z "$2" || "$2" == --* ]]; then
                echo "Error: --delay requires an argument."
                usage
            fi
            maim_args="$maim_args --delay=$delay"
            shift 2
            ;;
        --output|-o)
            if [[ -z "$2" || "$2" == --* ]]; then
                echo "Error: --delay requires an argument."
                usage
            fi
            output_file="$2"
            shift 2
            ;;
        --current*)

            ;;
        current-win*)
            maim_args="$maim_args --window=$(xdotool getactivewindow)"
        ;;
        win*)
            maim_args="$maim_args --tolerance=9999999"
        ;;
        sel*|'')
            maim_args="$maim_args --select"
        ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

if $delay; then
fi

case "$mode" in
esac

output_file="$HOME/Pictures/screenshot-$(date +%s).png"


maim $maim_args \
    | tee "$output_file" \
    | xclip -selection clipboard -t image/png
