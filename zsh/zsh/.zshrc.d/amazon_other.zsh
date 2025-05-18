#!/usr/bin/env zsh

export PATH="$HOME/.toolbox/bin:$PATH"

# if you wish to use IMDS set AWS_EC2_METADATA_DISABLED=false
export AWS_EC2_METADATA_DISABLED=true

alias sam="brazil-build-tool-exec sam"

# Java Home
export JAVA_HOME="$(dirname $(dirname $(realpath /usr/bin/java)))"

# Ensure correct git email
export GIT_AUTHOR_EMAIL="enlovson@amazon.com"

