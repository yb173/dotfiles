# git 以外の関数とキー操作。関数の名前は _ で始めない（Claude Code が写し取らないため）

# ディレクトリを作って移る
mkcd() {
  [[ -d $1 ]] && print -r -- "$1 already exists!"
  mkdir -p -- "$1" && cd -- "$1"
}

# 上のディレクトリに移る。up で 1 つ、up 3 で 3 つ上
up() {
  local dir=..
  repeat $(( ${1:-1} - 1 )) dir+=/..
  cd -- "$dir"
}

# プロセスを選んで kill する（Tab で複数）。引数は kill に渡す（fkill -9 など）
fkill() {
  local pids=(${(f)"$(ps -u "$USER" -o pid,%cpu,%mem,command | sed 1d | fzf -m | awk '{print $1}')"})
  (( $#pids )) || return 1
  kill "$@" $pids && print -r -- "killed: $pids"
}

# cd したら ll する。21 行以上あれば、最初と最後だけ出す
ls-after-cd() {
  # 対話のシェルでだけ動かす。Claude Code などが写し取ったシェルで動かないように
  [[ -o interactive ]] || return 0
  local count=$(command ls | wc -l)
  if (( count > 20 )); then
    ll | head -6
    print ' ...'
    ll | tail -5
    print " *** $(( count - 20 )) out of $count files are omitted ***"
  else
    ll
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd ls-after-cd

# Ctrl-]: ghq のリポジトリを選んで移る
fzf-ghq-widget() {
  local repo=$(ghq list | fzf --query "$LBUFFER")
  if [[ -n $repo ]]; then
    BUFFER="cd ${(q)$(ghq list --full-path --exact "$repo")}"
    zle accept-line
  fi
  zle reset-prompt
}
zle -N fzf-ghq-widget
bindkey '^]' fzf-ghq-widget

# Ctrl-G: よく行くディレクトリを zoxide から選び、cd を入力する（Enter で移る）
fzf-zoxide-widget() {
  local dir=$(zoxide query --interactive)
  if [[ -n $dir ]]; then
    BUFFER="cd ${(q)dir}"
    CURSOR=$#BUFFER
  fi
  zle reset-prompt
}
zle -N fzf-zoxide-widget
bindkey '^G' fzf-zoxide-widget
