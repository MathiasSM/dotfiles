# (Mathias') Dotfiles

This repository contains my configuration files for multiple tools I use in my day to day (work or not). Job-specific files (like stuff for Amazon) is left out of the public repo for legal reasons.

I organized these so I can use GNU's `stow` to install them as symlinks in the appropriate locations. A simple `install.sh` is included to automate the process.


## What's included?

Each directory is a `stow` "package", which is to be "stowed" (its files symlinked) into a specific directory on my machine. Nowadays the target directory is either `$HOME` or `$XDG_CONFIG_HOME` (`~/.config`); you can look at the install script for the actual values for each.

I have the following packages:

- `amethyst`: Only relevant in macOS. Tiling window manager, similar to xmonad.
- `ghc`: The (Glorious) Glasgow **Haskell** Compiler. This includes a global configuration for the REPL.
- `ghcup`: The main installer for GHC/all haskell things.
- `git`: My personal **Git** configuration, aliases and global ignore file. 
- `gnupg`: Personal confg for **GPG**. I don't use it very often. Also, defaults have gotten better lately, so it needs minimal changes.
- `karabiner`: Only relevant in macOS. Configuration for **Karabiner Elements**, to remap my keyboard to have more linux-like behavior.
- `macos`: Only relevant in macOS. **Homebrew** brewfiles for bootstrapping a new mac with the most used software I know I'll need at some point. Worth nothing that many programming-related software (LSPs and such) are handled via my nvim configuration.
- `nvim`: Configuration files for **NeoVim**. I keep this in a separate repo; right now this repo has it as a submodule, but I might consider removing it in favor of cloning the repo from the install script.
- `pgcli`: Configuration for a slightly better REPL I sometimes use for **Postgres** DBs.
- `psql`: Configurations for the standard/default REPL for postgres.
- `ssh`: Configuration for **SSH**. Aliases, keys and so on left out for privacy and security reasons.
- `tmux`: Configuration for **TMUX**. I mostly do everything on the terminal, and lately not even on my local machine, so tmux is a must for me.
- `vim`: I moved recently to neovim, so I will likely archive the **Vim** repo soon; nonetheless I keep it for regression testing of a few... edge cases.
- `zsh`: I'd like to move back to bash someday, but **Zsh** is so comfortable I might never do it. 

I probably will continue to add other tools I use, as long as they are text-based configuration files.


## How to install?

To install, use the `install.sh` script.

```sh
git clone thisrepogiturl location/in/your/computer
cd location/in/your/computer
./install.sh yourtarget
```

Target can be any (only one) of `debian`, `macos`, `redhat`. Mostly because of different package managers and availability (debian use `apt`, macos uses homebrew, ...). The redhat one is meant to work _for me_, and I use a custom redhat-based system, so I don't recommend using that target unless you know what you're doing.

### Flags and environment variables

Get some help about flags and targets

```
./install.sh --help # or -h
```

Get the "version" (I don't really intend to ever update this, I just added it because why not).

```
./install.sh --version # or -v
```

Do a dry-run, skipping any destructive action (like editing files, installing stuff, etc.

```
./install.sh --dry-run <target>
```

While not a flag, feel free to set the `DEBUG` environment varible to print a few more things and be aware of what's the script doing.

```
DEBUG=true ./install.sh <target>
```

### Actions

The default action is to install dependencies (apt packages, brews and casks, etc), and then create the symlinks to the right configuration files using stow.

Other actions modify the `stow` command, and skip the dependencies installations.

```
# Stow:(link) Creates symlinks in the right places
./install.sh <target> -S

# Delete (delink): Remove all the symlinks "owned" by stow from the right places. Basically means to "uninstall" the packages.
./install.sh <target> -D

# Re-stow (relink): Remove, then add the symlinks back
./install.sh <target> -R
```


## How to uninstall?

As stated above, should be as simple as 

```
./install.sh -D <target>
```
