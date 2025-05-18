#!/usr/bin/env zsh

export ANT_ARGS='-logger org.apache.tools.ant.listener.AnsiColorLogger'
export ANT_OPTS="-Dant.logger.defaults=$XDG_CONFIG_DIR/ant/AnsiColorLogger"

