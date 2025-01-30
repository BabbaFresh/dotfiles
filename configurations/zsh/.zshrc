CONFIG_HOME="$HOME/.config/zsh"
SOURCE_DIR="$CONFIG_HOME/sourcing"

# Make alt + combo work in tmux
bindkey -e

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

export HISTSIZE=50000
export SAVEHIST=50000
export HISTFILE=~/.zsh_history

# INFO:
# Do not write duplicate entries
setopt HIST_IGNORE_ALL_DUPS

# INFO:
# delete duplicates first, when HISTFILE exceeds HISTSIZE
setopt HIST_EXPIRE_DUPS_FIRST

# INFO:
# Even if there are duplicates,
# do not find them when searching history
setopt HIST_FIND_NO_DUPS

# NOTE:
# The following should be turned off,
# if sharing history via setopt SHARE_HISTORY

# INFO:
# It immediately writes the history to the file,
# instead of waiting for the shell to exit
setopt INC_APPEND_HISTORY

# INFO:
# Do not write lines starting
# with space to the history file
setopt HIST_IGNORE_SPACE

# INFO:
# Record time of command in history
setopt EXTENDED_HISTORY

export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
zstyle ':completion:*:git:*' group-order 'main commands' 'alias commands' 'external commands'
source <(carapace _carapace)

# Set the directory where we want to store zinit and the plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download and install zinit if it's not already installed
if [[ ! -d $ZINIT_HOME ]]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "$ZINIT_HOME/zinit.zsh"

# lazy load nvm
export NVM_LAZY_LOAD=true

zinit wait lucid for \
  zdharma-continuum/fast-syntax-highlighting \
  zdharma-continuum/history-search-multi-word \
  blockf \
  zsh-users/zsh-completions \
  atload"bindkey '^n' autosuggest-accept" \
  zsh-users/zsh-autosuggestions \
  lukechilds/zsh-nvm

zstyle :plugin:history-search-multi-word reset-prompt-protect 1

# Install oh-my-posh, if not already installed
if ! command -v oh-my-posh &> /dev/null; then
  curl -s https://ohmyposh.dev/install.sh | sudo bash -s
fi

eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/default.toml)"

# Node Modules
export PATH=$HOME/.node_modules/bin:$PATH

# Cargo path
export PATH=$HOME/.cargo/bin:$PATH

# Go path
export GOPATH=$HOME/go

# Lua Language Server
export PATH=$HOME/.lua-language-server/bin:$PATH

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/.bin:/usr/local/bin:/usr/local/go/bin:$GOPATH/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# bun completions
[ -s "/home/marco/.bun/_bun" ] && source "/home/marco/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

alias ls='eza --icons=always'

# I <3 Neovim
alias vim=nvim
alias vi=nvim

# easier sudo with env
alias 'sudoo'='sudo -E'

alias 'll'='ls -la'
alias '..'='cd ..'
alias 'gopen'='xdg-open'

if command -v batcat &> /dev/null; then
  alias 'bat'='batcat'
fi

if command -v fdfind &> /dev/null; then
  alias 'fd'='fdfind'
fi

# tmux is love, tmux is life
# attach to a new or existing tmux session
# Use default session name (0), if not specified
tmuxa() {
  local session_name="${1:-0}" # Use the first argument, or 0 if none provided
  tmux new-session -A -s "$session_name"
}

,() {
  local fdres=$(fd --type d --hidden --exclude '.git' --exclude '.npm' "$@")
  if [ -z "$fdres" ]; then
    echo "No results $@"
    return
  fi
  local c=$(echo $fdres | wc -l)
  if [ $c -eq 1 ]; then
    cd $fdres
  else
    local r=$(echo $fdres | fzf-tmux -p)
    if [ -z "$r" ]; then
      return
    fi
    cd $r
  fi
}

# https://direnv.net/docs/hook.html#zsh
eval "$(direnv hook zsh)"
