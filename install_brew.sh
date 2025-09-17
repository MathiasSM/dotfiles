#!/usr/bin/env bash

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

source "$DOTFILES/utils.sh"

# ==============================================================================

BREW_BASIC=("bash" "curl" "git" "less" "openssh" "ssh-copy-id" "stow" "vim")

BREW_GNU=("coreutils" "gawk" "gcc" "gnu-sed" "gnu-tar" "gnu-which" "grep")

# ------------------------------------------------------------------------------

BREW_BETTER=(
    "htop"                # Improved top
    "pstree"              # Show ps output as a tree
    "ripgrep"             # Faster grep
    "rsync"               # Better cp
    "the_silver_searcher" # Better grep
    "tree"                # Display directories as trees
    "mistertea/et/et"     # Remote terminal with IP roaming
    "zsh"                 # Better shell than bash
    "tmux"                # Terminal multiplexer
    "lynx"                # Text-based web browser
    "mas"                 # Mac App Store command-line interface
    "wget"                # Download stuff
    "neomutt"             # CLI email
)

BREW_DEVELOPMENT=(
    # Languages/runtimes
    # ------------------------------------- 
    "go"               # Go go power ra...
    "openjdk"          # Java... yeah...
    "luarocks"         # Package manager for the Lua programming language
    "pyenv-virtualenv" # Pyenv plugin to manage virtualenv

    # Markup and plaintext
    # -------------------------------------
    "doxygen"          # Generate html documentation from commented code
    "graphviz"         # Generate graphs from plain-text definitions
    "pandoc"           # Markup A to markup B to C to Z
    "plantuml"         # Draw UML diagrams

    # Data and databases
    # -------------------------------------
    "postgresql@16"    # The RDBS
    "pgcli"            # The better REPL to Postgres
    "postgrest"        # Generate a REST service from postgres schemas
    "jq"               # JSON swiss army
)

BREW_OTHER=(
    # Binaries manipulation
    # ------------------------------------- 
    "ffmpeg"         # Play, record, convert, and stream audio and video
    "imagemagick"    # Tools and libraries to manipulate images in many formats

    # Fun
    # ------------------------------------- 
    "fortune" # Infamous electronic fortune-cookie generator
    "catimg"  # Insanely fast image printing in your terminal

    # CLI Apps
    # ------------------------------------- 
    "awscli"        # Official Amazon AWS command-line interface
    "asciinema"     # Record and share terminal sessions
    "hub"           # Add GitHub support to git on the command-line
    "bitwarden-cli" # Secure and free password manager for all of your devices
    "hledger"       # Plain text accounting
    "lnav"          # Curses-based tool for viewing and analyzing log files

    # Other
    # ------------------------------------- 
    "shared-mime-info"           # Database of common MIME types
    "gmailctl"                   # Declarative configuration for Gmail filters
)

# ==============================================================================

CASK_BASIC=(
    "aldente"            # Limit maximum charging percentage
    "bartender"          # Menu bar icon organiser
    "amethyst"           # Closest to xmonad I could find
    "karabiner-elements" # Keyboard customiser
    "monitorcontrol"     # Control external monitor brightness & volume
    "scroll-reverser"    # Tool to reverse the direction of scrolling
    "ukelele"            # Unicode keyboard layout editor
    "xbar"               # View output from scripts in the menu bar
)

CASK_DEVELOPMENT=(
    # Development
    # ------------------------------------- 
    "android-studio" # Tools for building Android applications
    "godot"          # Game development engine

    # Games
    # ------------------------------------- 
    "epic-games"     # Launcher for *Epic Games* games
    "openemu"        # Retro video game emulation
    "steam"          # Video game digital distribution service

    # Art
    # ------------------------------------- 
    "gimp"           # Free and open-source image editor
    "inkscape"       # Vector graphics editor
    "krita"          # Free and open-source painting and sketching program
)

CASK_OTHERS=(
    "amazon-photos"          # Photo storage and sharing service
    "android-file-transfer"  # Transfer files from and to an Android smartphone
    "android-platform-tools" # Android SDK component
    "calibre"                # E-books management software
    "handbrake"              # Open-source video transcoder
    "horos"                  # Medical image viewer
    "keycastr"               # Open-source keystroke visualiser
    "libreoffice"            # Free cross-platform office suite, fresh version
    "macfuse"                # File system integration
    "obs"                    # Live streaming and screen recording
    "spotify"                # Music streaming service
    "telegram"               # Messaging app with a focus on speed and security
    "thunderbird"            # Customizable email client
)

CASK_FONTS=(
    "font-computer-modern"
    "font-courier-new"
    "font-fira-sans"
    "font-hack"
    "font-inconsolata"
    "font-lato"
    "font-liberation"
    "font-noto-mono"
    "font-noto-sans"
    "font-noto-serif"
    "font-open-sans"
    "font-pt-mono"
    "font-pt-sans"
    "font-pt-serif"
    "font-roboto"
    "font-roboto-mono"
    "font-roboto-serif"
    "font-roboto-slab"
    "font-sauce-code-pro-nerd-font"
    "font-source-code-pro"
    "font-ubuntu"
)

CASK_QUICKLOOK=(
    "qlcolorcode"    # Source code with syntax highlighting
    "qlimagesize"    # Image info for unsupported formats
    "qlmarkdown"     # Markdown files
    "qlstephen"      # Plaintext files without an extension
    "quicklook-json" # JSON files
    "quicklookase"   # Adobe Swatch Exchange files
    "webpquicklook"  # Webp files
)

# ------------------------------------------------------------------------------

GITHUB_USER_CONTENT="https://raw.githubusercontent.com"
HOMEBREW_URL="$GITHUB_USER_CONTENT/Homebrew/install/HEAD/install.sh"

parse_common_args

echo "Installing homebrew..."
tmpdir=$(mktemp -p "$TMPDIR" -d "$MKTEMP_TEMPLATE")
dry_run curl "$CURL_FLAGS" "$HOMEBREW_URL" -o "$tmpdir/brew.sh"
dry_run bash "$tmpdir/brew.sh"

echo "Installing brew packages..."
dry_run brew install "${BREW_BASIC[@]}"
dry_run brew install "${BREW_GNU[@]}"
dry_run brew install "${BREW_BETTER[@]}"
dry_run brew install "${BREW_DEVELOPMENT[@]}"
dry_run brew install "${BREW_OTHER[@]}"

echo "Installing casks..."
dry_run brew install "${CASK_BASIC[@]}"
dry_run brew install "${CASK_DEVELOPMENT[@]}"
dry_run brew install "${CASK_FONTS[@]}"
dry_run brew install "${CASK_OTHERS[@]}"
dry_run brew install "${CASK_QUICKLOOK[@]}"

echo "DONE!"
