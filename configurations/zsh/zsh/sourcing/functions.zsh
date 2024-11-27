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

,,() {
  local gr
  local dn
  local fn
  local fdres
  local c
  fdres=$(fd --type f --hidden --exclude '.git' --exclude '.npm' "$@")
  if [ -z "$fdres" ]; then
    echo "No results"
    return
  fi
  c=$(echo $fdres | wc -l)
  if [ $c -eq 1 ]; then
    dn=$(dirname $fdres)
    fn=$(realpath -s --relative-to=$dn $fdres)
    cd $dn
    gr=$(git rev-parse --show-toplevel 2> /dev/null)
    if [ -z "$gr" ]; then # no git root detected
      nvim $fn
    else # git root detected, open file relative to git root
      dn="$gr"
      cd $dn
      fdres=$(fd --type f --hidden --exclude '.git' --exclude '.npm' "$@")
      fn=$(realpath -s --relative-to=$dn $fdres)
      nvim $fn
    fi
  else
    local r=$(echo $fdres | fzf-tmux -p)
    if [ -z "$r" ]; then
      return
    fi
    local dn=$(dirname $r)
    local fn=$(realpath -s --relative-to=$dn $r)
    cd $dn
    nvim $fn
  fi
}

source-dotenv() {
  [ ! -f .env ] || export $(grep -v '^#' .env | xargs)
}
