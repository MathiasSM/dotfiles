<!--vim: textwidth=80-->

(Mathias') Dotfiles
===============================================================================

This repository contains my configuration files for multiple tools I use in my
day to day (work or not). Job-specific files (like stuff for Amazon) is left
out of the public repo for legal reasons.

I organized these so I can use GNU's `stow` to install them as symlinks in the
appropriate locations. A simple `install.sh` is included to automate the
process.


How to install?
-------------------------------------------------------------------------------

```sh
export DOTFILES=/location/of/this/script
git clone $thisrepogiturl $DOTFILES
cd $DOTFILES
./install_apt.sh  # Only debian
./install_brew.sh # Only macOS
./install_yum.sh  # Only redhat
./install_opt.sh  # Extra software for /opt
./link_home.sh    # Links main files (_home)
./link_xdg.sh     # Links all the rest
```

### Flags and environment variables

Env Var         | Flag   | Effect / Meaning
--------------- | ------ | ----------------------------------------------------
`DOTFILES`      | N/A    | **Required**. Tells the script where it's located.
`DEBUG`         | `-d`   | Enable extra/verbose output.
`DRY_RUN`       | `-n`   | Log actions instead of executing.
`FORCE_INSTALL` | `-f`   | [Only for `install_x` scripts] Self-explanatory
N/A             | `-S`   | Stow flag to stow files. **Default behavior.**
N/A             | `-D`   | Stow flag to de-stow files. Use this to "uninstall" the dotfiles.
N/A             | `-R`   | Stow flag to re-stow files. Same as destowing and stowing again.


What's included?
-------------------------------------------------------------------------------

Each directory is a `stow` "package", which is to be "stowed" (its files
symlinked) into a specific directory on my machine. Read the `man stow` pages
for more information.

I have the following within `_home`, which is linked directly in `$HOME`:

- `.profile`: Common entry for shells to read common variables, aliases, etc.
- `.config/`
    - `shell/`
        - `profile.d/*`: Files read in order by `.profile`.
        - `vars`: Shell environment variables.
- `.local/`: Executable shell scripts. Set as part of `$PATH`.
    - `bin`: Executable shell scripts. Set as part of `$PATH`.
- `.ssh`: Does not and will likely never support XDG standard.
- `.xsession`: Sets up my X session.

I have the following `_packages/*`, which are linked into `$XDG_CONFIG_HOME`
(`~/.config`):

- `alacritty`: My current terminal emulator.
- `amethyst`: Tiling window manager, similar to xmonad. [macos-only]
- `autorandr`: Nice little auto-setup for monitors. [linux-only]
- `dunst`: Simple notifications. [linux-only]
- `ghc`: The (Glorious) Glasgow **Haskell** Compiler and REPL.
- `ghcup`: The main installer for GHC/all haskell things.
- `git`: My personal **Git** configuration, aliases and global ignore file.
- `gnupg`: Personal config for **GPG**. I don't use it very often.
- `irb`: Ruby REPL things.
- `karabiner`: Configuration for **Karabiner Elements**. [macos-only]
- `mise`: **mise-in-place** configuration files.
- `npm`: **Node** package manager.
- `pgcli`: Fancier postgres REPL.
- `picom`: Compositor for X. [linux-only]
- `psql`: Configurations for the standard/default REPL for **Postgres**.
- `python`: The snake, not the language.
- `rofi`: App launcher and dynamic text menu. [linux-only]
- `tmux`: I mostly do everything on the terminal, mostly in a remote machine.
- `variety`: Auto-change wallpapers, from different sources. [linux-only]
- `xmobar`: Status bar made for use with Xmonad.
- `xmonad`: Tiling window manager. [linux-only]
- `zsh`: The shell I use. I guess. 

**Note:** I keep configuration files for **NeoVim** in a separate
repo: [MathiasSM/init.lua](https://github.com/MathiasSM/init.lua).

### Some things I'm missing

- More dotfiles:
    - `eslint` (better defaults)
    - `bash` (for when I jump from zsh)
    - `mutt` (if I ever get to properly configure it)
    - terminfo files for italics
    - personal scripts

- Too personal:
    - `gmailctl`: API keys, personal info and so on
    - `hledger`: Bad finance organization

- Some from debian days (from old dotfiles repo)
    - `libinput` config for trackpad

My X configuration (linux)
-------------------------------------------------------------------------------

Feature              | Provided by...         | Notes
-------------------- | ---------------------- | -------------------------------
Application launcher | rofi (on-demand)       | Could be dmenu.
Audio control        | ?                      | 
Backlight control    | xfce4-power-manager    | Simpler than managing it myself.
Compositor           | picom (on-demand)      | Off by default, but hotkey-ed.
Default applications | -                      | Maybe setting defaults is useful.
Display manager      | lightdm                | Small-ish and simple.
Logout dialogue      | N/A                    | Could be a rofi/dmenu script.
Media control        | N/A                    | No need, I think.
Notifications        | dunst                  | 
Polkit agent         | ?                      | 
Power management     | xfce4-power-manager    |
Screen capture       | scrot                  | Could be maim.
Screen lock          | xss-lock + xsecurelock | Annoying to figure out!
Screen temperature   | N/A                    | Used to use redshift.
Task/Status bar      | xmobar                 | Plays nice with xmonad
Wallpaper setter     | variety                | Uses feh under the hood
Window manager       | xmonad                 | Tiling tiles.

- autorandr
- libinput
