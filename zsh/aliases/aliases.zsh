#
# Aliases & Functions
#

# z.lua aliases
alias zz='z -c'      # restrict matches to subdirs of $PWD
alias zi='z -I'      # use fzf to select in multiple matches
alias zb='z -b'      # quickly cd to the parent directory
alias zbi='z -b -I'  # use fzf to select in multiple parent directories

# exa versions of some ls aliases.
alias ls='exa'
# Lists in one column, hidden files.
alias l='exa -1a'
# Lists human readable sizes.
alias ll='exa -lh --git'
# Lists human readable sizes, recursively.
alias lr='ll -R'
# Lists human readable sizes, hidden files.
alias la='ll -a'
# Lists sorted by extension (GNU only).
alias lx='ll -s extension'
# Lists sorted by size, largest last.
alias lk='ll -s size'
# Lists sorted by date, most recent last.
alias lt='ll -s oldest'
# Lists sorted by date, most recent last, shows change time.
alias lc='lt -t created'
# Lists sorted by date, most recent last, shows access time.
alias lu='lt -t accessed'

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en1"
alias ips="ifconfig -a | grep -o 'inet6\? \(\([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\)\|[a-fA-F0-9:]\+\)' | sed -e 's/inet6* //'"

# Use glances instead of top/htop
alias top='glances'
alias htop='glances'

# Use trash instead of rm
alias rm='trash'

# Use delta instead of diff
alias diff='delta'

# Use bat instead of cat
alias cat='bat'

# Use fd instead of find
alias find='fd'

# Use dust instead of du
alias du='dust'

# Use duf isntead of df
alias df='duf'

# Use tldr instead of help
alias help='tldr'

# Use broot instead of tree
alias tree='broot'

# Use fnm instead of nvm
alias nvm='fnm'

# Change dir fast
alias d='dirs -v'
for index ({1..9}) alias "$index"="cd +${index}"; unset index

# rage quit!!!
function fuck() {
  if killall -9 "$2"; then
    echo ; echo " (╯°□°）╯︵$(echo "$2"|toilet -f term -F rotate)"; echo
  fi
}
# alias rage quit for current user
alias fu='fuck you'

# Print some stats about zsh usage. Lifted from https://github.com/robbyrussell/oh-my-zsh/blob/20f536c06432a5cda86fc9b5bdf73fd1115cb84d/lib/functions.zsh
function zsh_stats() {
  fc -l 1 | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n20
}

#
# vim aliases
#
if [[ $+commands[lvim] ]]; then
  alias vi='lvim'
  alias vim='lvim'
  alias nvim='lvim'
  alias vimdiff='lnvim -d'
elif [[ $+commands[nvim] ]]; then
  alias vi='nvim'
  alias vim='nvim'
  alias vimdiff='nvim -d'
fi
