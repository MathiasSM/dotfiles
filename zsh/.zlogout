#!/usr/bin/env zsh

# =============================================================================
# In order (always /etc/<file> before each):
#
# - $ZDOTDIR/.zshenv
# - $ZDOTDIR/.zprofile  (if login shell)
# - $ZDOTDIR/.zshrc     (if interactive)#
# - $ZDOTDIR/.zpreztorc (zprezto)
# - $ZDOTDIR/.zlogin    (if login shell)
# > $ZDOTDIR/.zlogout   (if exiting a login shell)
# =============================================================================

# Kill the session's ssh agent
ssh-agent -k >/dev/null

# Execute code only if STDERR is bound to a TTY.
[[ -o INTERACTIVE && -t 2 ]] && {

SAYINGS=(
    "So long and thanks for all the fish.\n  -- Douglas Adams"
    "Good morning! And in case I don't see ya, good afternoon, good evening and goodnight.\n  --Truman Burbank"
    "They must often change, who would be constant in happiness or wisdom.\n  --Confucius"
    "Every new beginning comes from some other beginning’s end.\n  --Semisonic"
    "Farewell! God knows when we shall meet again.\n  --William Shakespeare"
    "It is so hard to leave—until you leave. And then it is the easiest thing in the world.\n  --John Green"
    "If you’re brave enough to say goodbye, life will reward you with a new hello.\n  --Paulo Coelho"
    "Goodbyes make you think. They make you realize what you’ve had, what you’ve lost, and what you’ve taken for granted.\n  --Ritu Ghatourey"
    "It’s sad, but sometimes moving on with the rest of your life, starts with goodbye.\n  --Carrie Underwood"
    "Don’t cry because it’s over. Smile because it happened.\n  --Dr. Seuss"
    "Goodbyes, they often come in waves.\n  --Jarod Kintz"
    "Goodbye always makes my throat hurt.\n  --Charlie Brown"
    "Nature is written in mathematical language.\n -- Galileo Galilei"
    "The essence of math is not to make simple things complicated, but to make complicated things simple.\n  -- Stan Gudder"
    "There should be no such thing as boring mathematics.\n  -- Edsger Dijkstra"
    "Mathematics is, in its way, the poetry of logical ideas.\n  -- Albert Einstein"
    "Before software should be reusable, it should be usable.\n  -- Ralph Johnson"
    "People think computers will keep them from making mistakes. They're wrong. With computers you make mistakes faster.\n -- Adam Osborne"
    "Software is a gas; it expands to fill its container.\n  -- Nathan Myhrvold"
    "Computer Science is no more about computers than astronomy is about telescopes.\n  -- Edsger W. Dijkstra"
    "If we wish to count lines of code, we should not regard them as ‘lines produced’ but as ‘lines spent’.\n  -- Edsger Dijkstra"
    "If you automate a mess, you get an automated mess.\n  -- Rod Michael"
)

# Print a randomly-chosen message:
echo $SAYINGS[$(($RANDOM % ${#SAYINGS} + 1))]

} >&2
