#!/usr/bin/env zsh



# Completions setup
# -----------------------------------------------------------------------------
if type brew &>/dev/null; then
  fpath=("$(brew --prefix)/share/zsh-completions" $fpath)
fi
# Zprezto completions module handles the rest


# Zprezto
# -----------------------------------------------------------------------------
source "$ZDOTDIR/zprezto/init.zsh" # This loads .zpreztorc


# Prompt (Mostly configured by zprezto's pure theme)
# -----------------------------------------------------------------------------

export PROMPT='%F{gray}%* %f'$PROMPT
export PROMPT='%F{$prompt_pure_colors[suspended_jobs]}%(1j.[%j] .)%f'$PROMPT

# Show red exit code on right, with timestamp
precmd_pipestatus() {
  local cmd_pipestatus=($pipestatus) # First line!
  local display_timestamp='%F{white}[%*]'
  RPROMPT=$display_timestamp 
  if [[ "${cmd_pipestatus[-1]}" != 0 ]]; then
    local format_error='\$prompt_pure_colors[prompt:error]'
    local display_code="%F{$format_error}[${(j:|:)cmd_pipestatus}]%f"
    export RPROMPT=$display_code' '$RPROMPT
  fi
  export RPROMPT='%F{gray}# '$RPROMPT'%f'
}
add-zsh-hook precmd precmd_pipestatus

