#!/usr/bin/env zsh

# ZSH Shell options
# -----------------------------------------------------------------------------
# Changing Directories
setopt AUTO_CD           # If it's unambiguosly a path, no need for cd.
setopt AUTO_PUSHD        # Push the old directory onto the stack on cd.
setopt CDABLE_VARS       # Change directory to a path stored in a variable.
setopt CHASE_LINKS       # Resolves symlinks on cd and expanding
setopt PUSHD_IGNORE_DUPS # Do not store duplicates in the stack.
setopt PUSHD_SILENT      # Do not print the stack after pushd or popd.
setopt PUSHD_TO_HOME     # Push to home directory when no argument is given.

# Completion
# -> Handled by zprezto's completion module

# Expansion and globbing
setopt EXTENDED_GLOB     # Use extended globbing syntax.

# History
setopt APPEND_HISTORY         # Sessions append to, rather than replace file.
setopt BANG_HIST              # Treat '!' specially during expansion.
setopt EXTENDED_HISTORY       # Write in ':start:elapsed;command' format.
setopt HIST_BEEP              # Beep when accessing non-existent history.
setopt HIST_EXPIRE_DUPS_FIRST # Expire a duplicate event first when trimming.
setopt HIST_FCNTL_LOCK        # Better file locking on modern OS.
setopt HIST_FIND_NO_DUPS      # Do not display a previously found event.
setopt HIST_IGNORE_ALL_DUPS   # Delete older duplicate (if any) before adding.
setopt HIST_IGNORE_DUPS       # Do not record an event that was just recorded.
setopt HIST_IGNORE_SPACE      # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS      # Do not write duplicates.
setopt HIST_VERIFY            # Do not execute immediately upon expansion.
setopt SHARE_HISTORY          # Share history between all sessions.

# Input / Output
unsetopt CLOBBER            # Use >! and >>! to overwrite file.
setopt INTERACTIVE_COMMENTS # Enable comments in interactive shell.
setopt RC_QUOTES            # Allow 'Henry''s' instead of 'Henry'\''s'.

# Jobs
setopt LONG_LIST_JOBS       # List jobs in the long format by default.
setopt NOTIFY               # Report status of background jobs immediately.
unsetopt BG_NICE            # Don't run all background jobs at a lower priority.
unsetopt HUP                # Don't kill jobs on shell exit.

# Scripts and Functions
setopt C_PRECEDENCES        # For arithmetics!
setopt MULTIOS              # Implicit tees or cats when multiple redirections

# Shell Emulation
setopt APPEND_CREATE        # Do not yell when a file doesn't exist at append

# ZLE
setopt COMBINING_CHARS      # Assume display correctly combines characters.
unsetopt BEEP               # Don't beep on errors
