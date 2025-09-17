#!/usr/bin/env sh

profile_d="$XDG_CONFIG_HOME/shell/profile.d"

if [ ! -d "$XDG_CONFIG_HOME" ]; then 
    echo "Please source XDG configuration before ~/.profile" 1>&2
    echo "-> profile.d/* files not loaded" 1>&2
fi

for f in $( ls $profile_d ); do
   . "$profile_d/$f"
done

unset profile_d
