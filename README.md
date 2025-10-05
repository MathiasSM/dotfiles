<!--vim: textwidth=80-->

(Mathias') Dotfiles
===============================================================================

This repository contains my configuration files for multiple tools I use in my
day to day (work or not). Job-specific files (like stuff for Amazon) is left
out of the public repo for legal reasons.

I organized these so I can use GNU's `stow` to install them as symlinks in the
appropriate locations. 


How to install?
-------------------------------------------------------------------------------

```sh
export THIS_REPO_URL=https://thisrepourl
export DOTFILES=/location/of/this/script
git clone "$THIS_REPO_URL" "$DOTFILES"
cd "$DOTFILES"

./install_apt.sh  # Only debian
./install_brew.sh # Only macOS
./install_yum.sh  # Only redhat
./install_opt.sh  # Extra software for /opt

./link_home.sh    # Links main files (_home)
./link_xdg.sh     # Links all the rest
```

Note: the "bootstrapping" might not be ready.


### Flags and environment variables

Env Var         | Flag   | Effect / Meaning
--------------- | ------ | ----------------------------------------------------
`DOTFILES`      | N/A    | **Required**. Tells the script where it's located.
`DEBUG`         | `-d`   | Enable extra/verbose output.
`DRY_RUN`       | `-n`   | Log actions instead of executing.
`FORCE_INSTALL` | `-f`   | \[Only for `install_x` scripts] Self-explanatory
N/A             | `-S`   | **Default behavior**. Stow flag to stow files.
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

- **Common**
    - `alacritty`: My current terminal emulator.
    - `ghc`: The (Glorious) Glasgow **Haskell** Compiler and REPL.
    - `ghcup`: The main installer for GHC/all haskell things.
    - `git`: My personal **Git** configuration, aliases and global ignore file.
    - `gnupg`: Personal config for **GPG**. I don't use it very often.
    - `irb`: Ruby REPL things.
    - `mise`: **mise-in-place** configuration files.
    - `npm`: **Node** package manager.
    - `pgcli`: Fancier postgres REPL.
    - `psql`: Configurations for the standard/default REPL for **Postgres**.
    - `python`: The snake, not the language.
    - `tmux`: I mostly do everything on the terminal, mostly in a remote machine.
    - `zsh`: The shell I use. I guess. 
- **Linux-only**
    - `autorandr`: Nice little auto-setup for monitors.
    - `dunst`: Pretty plain notifications.
    - `picom`: Compositor for X.
    - `rofi`: App launcher and dynamic text menu.
    - `variety`: Auto-change wallpapers, from different sources.
    - `xmobar`: Status bar made for use with Xmonad.
    - `xmonad`: Tiling window manager.
- **macOS-only**
    - `amethyst`: Tiling window manager, similar to xmonad.
    - `karabiner`: Configuration for **Karabiner Elements**.
      - I hate using <kbd>cmd</kbd> for everything; I prefer linux keybindings.


**Note:** I keep configuration files for **NeoVim** in a separate repo:
[MathiasSM/init.lua]. I used to link it here via git submodules but was a bit
of a pain to maintain.


My X configuration (linux)
-------------------------------------------------------------------------------

Some time ago I decided even `xfce` or `lxde` was too much bloat.

1. **Display Server**: Xorg. I have not gotten around to move to Wayland, as I
   don't have proper incentive to do so yet.
    - `autorandr` is in charge of saving/applying monitor configurations.
    - `arandr` can be used to setup a configuration for new monitors via GUI.
1. **Display Manager** (Login Manager): `lightdm`. It works with many/any
desktop environment (useful if I change that, or experiment).
    - `xsecurelock` with `xss-lock` for automatic locking.
1. **Power Manager**: `xfce4-power-manager`. Using also...
    - `acpid` to listen to events.
    - `laptop-mode-tools`, which supposedly sets up good settings.
    - `powertop`, to figure out who's draining my stuff.
1. **Input devices**: `libinput`.
1. **Network Manager**: The one with the same name.
    - `dnsmasq` for local DNS caching.
    - `blueman` for GUI frontend for bluetooth (through `bluez`)
      - Include `blueman-applet`
1. **Sound System**: `PulseAudio`
    - `pavucontrol` as GUI.
1. Xsession (started by the display manager) sets up:
    1. **Window Manager**: `xmonad`.
        1. `xmobar` called per-monitor as status bar.
    1. **Compositor**: `picom` is used as compositor, toggled with keybind.
    1. **Application launcher**: `rofi`.
    1. **Notifications**: `dunst`.
    1. **Tray**: `trayer`. Moving stuff to xmobar where possible.
    1. **Wallpapers**: `variety`.
    1. **Screenshots**: `scrot`.


TODO
-------------------------------------------------------------------------------

- [ ] **Reorganize**: I want to extract the xsession setup to its own section.
This is because its not only dotfiles but requires some manual changes like
copying files into `/etc/` or else. Plus it's something I want to keep more
stable than the rest.
- [ ] `lightdm`: Try _not_ using it. If actually needed, document it here.
    - [ ] `emptty`: Try using it instead of `lightdm`.
- [ ] `xsecure`, `xfce4-power-manager`: Race condition on lid close.
- [ ] `libinput`: is currently not picking up default keyboard settings.
- [ ] `libinput`: might not be picking up trackpad settings.
- [ ] `stalonegray`: Get rid of this, by adding bluetooth and variety menus on xmobar.
- [ ] `nvim`: Add script to install nvim dotfiles from [MathiasSM/init.lua].
- [ ] `rofi`: Add scripts for
  - [ ] Power management (shutdown, restart, suspend)


<!--References---------------------------------------------------------------->

[MathiasSM/init.lua]: https://github.com/MathiasSM/init.lua
