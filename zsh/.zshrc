#!/usr/bin/env zsh
#
# Executes commands at the start of an interactive session.
#

#
# Autoload
#

# Set the Zsh functions to load (man zshcontrib).
autoload -Uz "zargs"
autoload -Uz "zmv"
autoload run-help

#
# Completions
#

autoload compinit
compinit

#
# Options
#

setopt AUTO_CD              # Auto changes to a directory without typing cd.
setopt AUTO_PUSHD           # Push the old directory onto the stack on cd.
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.
setopt PUSHD_TO_HOME        # Push to home directory when no argument is given.
setopt CDABLE_VARS          # Change directory to a path stored in a variable.
setopt MULTIOS              # Write to multiple descriptors.
setopt EXTENDED_GLOB        # Use extended globbing syntax.
setopt NO_BANG_HIST         # Let ! be !
unsetopt CLOBBER            # Do not overwrite existing files with > and >>.
                            # Use >! and >>! to bypass.
unsetopt NOMATCH            # Allow ^ to be used unescaped in args.
                            # See https://github.com/ohmyzsh/ohmyzsh/issues/449#issuecomment-6973425

# fzf
export FZF_DEFAULT_OPTS="--layout reverse --info inline --height 40%"
export FZF_CTRL_T_OPTS="--preview \"bat --style=numbers --color=always --line-range :500 {}\""
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'
export FZF_CTRL_T_OPTS="--preview \"bat --style=numbers --color=always --line-range :500 {}\""
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# preview directory's content with exa when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf --preview 'exa -1 --color=always $realpath'
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'
# give a preview of commandline arguments when completing `kill`
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf --preview \
  '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap

# nvm
export NVM_AUTO_USE=true

# Initialize sheldon
eval "$(sheldon source)"

# Initialize starship
eval "$(starship init zsh)"

