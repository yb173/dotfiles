# git の補助。名前は g で始め、oh-my-zsh の git のエイリアスに合わせる（gst・ga・gd・gco・gcp・grbi など）
# 選ぶところは fzf を使う（Tab で複数選べるものもある）。引数はそのまま git に渡す
# ファイルの一覧は NUL 区切りで受け渡す（git は -z、fzf は --read0 --print0）。
# -z なら、git は日本語や空白の入った名前を引用符で囲まずに出す

# 状態を見る
gst() {
  git status "$@"
}

# コミットを選んで、ハッシュを出す。引数は git log に渡す（ブランチなど）
ghash() {
  git log --oneline --color=always "$@" |
    fzf --ansi --no-sort --preview 'git show --color=always {1}' |
    awk '{print $1}'
}

# 差分を見る。-s で変更したファイルを選ぶ（パスはクリップボードにも入れる）
gd() {
  if [[ $1 == -s ]]; then
    # :/ を付けて、今いるディレクトリの外も含め、リポジトリ全体から選ぶ（ga -s・grst -s と同じ）。
    # git ls-files のパスは今いるディレクトリから数える（外のファイルは ../ で始まる）。最後の NUL を取る
    local file=${"$(git ls-files -m -z -- :/ | fzf --read0 --print0 --preview 'git diff --color=always -- {}')"%$'\0'}
    [[ -n $file ]] || return 1
    print -rn -- "$file" | pbcopy
    git diff -- "$file"
  else
    git diff "$@"
  fi
}

# ステージする。-s でファイルを選ぶ（ほかの引数は git add に渡す。ga -s -p など）
ga() {
  if [[ $1 == -s ]]; then
    shift
    # git status のパスは今いるディレクトリではなくリポジトリのいちばん上から数える。
    # そのため、:/（いちばん上から数えるという意味）を付けて渡す。--no-renames で名前を変えたファイルを 1 行にしない
    local files=(${(0)"$(git status --porcelain -z --no-renames |
      fzf -m --read0 --print0 --preview 'f={}; git diff --color=always -- ":/${f:3}"')"})
    (( $#files )) || return 1
    # 各行の先頭 3 文字（状態の 2 文字と空白）を :/ に置き換える
    git add "$@" -- ${files/#???/:/}
  else
    git add "$@"
  fi
}

# ステージを取り消す（git restore --staged）。-s でファイルを選ぶ
grst() {
  if [[ $1 == -s ]]; then
    # git diff --name-only のパスもリポジトリのいちばん上から数えるので、:/ を付けて渡す
    local files=(${(0)"$(git diff --staged --name-only -z |
      fzf -m --read0 --print0 --preview 'git diff --staged --color=always -- :/{}')"})
    (( $#files )) || return 1
    git restore --staged -- ${files/#/:/}
  else
    git restore --staged "$@"
  fi
}

# 作業中の変更を捨てる（戻せない）。-s でファイルを選ぶ。捨てる前に聞く
gdiscard() {
  local files
  if [[ $1 == -s ]]; then
    # gd -s と同じく、リポジトリ全体から選ぶ。パスは今いるディレクトリから数える
    files=(${(0)"$(git ls-files -m -z -- :/ | fzf -m --read0 --print0 --preview 'git diff --color=always -- {}')"})
  else
    files=("$@")
  fi
  if (( ! $#files )); then
    print -u2 'gdiscard: ファイルを指定するか、-s で選ぶ'
    return 1
  fi
  if ! read -q "?${(j: :)files} の変更を捨てる? [y/N] "; then
    print
    return 1
  fi
  print
  git restore -- $files
}

# ブランチ名をクリップボードに入れる。-r でリモートのブランチから選ぶ
gbc() {
  local branch
  if [[ $1 == -r ]]; then
    branch=$(git branch -r --sort=-authordate --format='%(refname:lstrip=3)' | grep -vx HEAD | fzf)
  else
    branch=$(git branch --format='%(refname:short)' | fzf)
  fi
  [[ -n $branch ]] || return 1
  print -rn -- "$branch" | pbcopy
  print -r -- "copied: $branch"
}

# チェックアウトする。-l でローカル、-r でリモートのブランチ、-h でコミットを選ぶ
# ほかの引数は git checkout に渡す（gco main、gco -b 新しいブランチ など）
gco() {
  local target
  case $1 in
    -l) target=$(git branch --format='%(refname:short)' | fzf) ;;
    -r) target=$(git branch -r --sort=-authordate --format='%(refname:lstrip=3)' | grep -vx HEAD | fzf) ;;
    -h) target=$(ghash) ;;
    *)
      git checkout "$@"
      return
      ;;
  esac
  [[ -n $target ]] || return 1
  git checkout "$target"
}

# 今のブランチを origin に push する。push する前に聞く
gpo() {
  local branch=$(git branch --show-current)
  [[ -n $branch ]] || return 1
  if ! read -q "?origin/$branch に push する? [y/N] "; then
    print
    return 1
  fi
  print
  git push origin "$branch" "$@"
}

# コミットを選んで cherry-pick する。引数は git log に渡す（gcp ほかのブランチ）
# -r で範囲を選ぶ（最初のコミット、最後のコミットの順に選ぶ。両方とも含む）
gcp() {
  if [[ $1 == -r ]]; then
    shift
    local first=$(ghash "$@")
    [[ -n $first ]] || return 1
    local last=$(ghash "$@")
    [[ -n $last ]] || return 1
    git cherry-pick "$first^..$last"
  else
    local commit=$(ghash "$@")
    [[ -n $commit ]] || return 1
    git cherry-pick "$commit"
  fi
}

# コミットを選んで、それより後を rebase -i する
grbi() {
  local commit=$(ghash "$@")
  [[ -n $commit ]] || return 1
  git rebase -i "$commit"
}

# bisect する。-s で悪いコミット、良いコミットの順に選んで始める
# -b で bad、-g で good、-r で reset。ほかの引数は git bisect に渡す
gbs() {
  case $1 in
    -s)
      local bad=$(ghash)
      [[ -n $bad ]] || return 1
      local good=$(ghash)
      [[ -n $good ]] || return 1
      git bisect start "$bad" "$good"
      ;;
    -b) git bisect bad ;;
    -g) git bisect good ;;
    -r) git bisect reset ;;
    *) git bisect "$@" ;;
  esac
}

# origin の既定のブランチ（origin/HEAD）の名前を出す
gdefault() {
  local ref
  if ! ref=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD); then
    print -u2 'origin/HEAD がない。git remote set-head origin --auto で作る'
    return 1
  fi
  print -r -- "${ref#origin/}"
}

# 既定のブランチに移って origin に合わせてから、新しいブランチを作って移る（gnew ブランチ名）
gnew() {
  if (( $# != 1 )); then
    print -u2 'gnew: 新しいブランチの名前を 1 つ渡す'
    return 1
  fi
  # 新しいブランチがもうないかを、既定のブランチに移る前に確かめる（移ってから失敗すると、元のブランチに戻らないため）
  if git show-ref --verify --quiet "refs/heads/$1"; then
    print -u2 "gnew: ブランチ $1 はもうある"
    return 1
  fi
  local default
  default=$(gdefault) || return 1
  git switch "$default" && git fetch origin && git rebase "origin/$default" && git switch -c "$1"
}

# 今のブランチのまま、既定のブランチ（origin/HEAD）を origin に合わせる
# 既定のブランチにいないときは、チェックアウトせずに早送りする。作業中の変更があっても動き、今のブランチは変わらない。
# 既定のブランチにだけあるコミットがあって早送りできないときは、何も変えずに失敗する
gsync() {
  local current=$(git branch --show-current)
  local default
  default=$(gdefault) || return 1
  git fetch origin || return 1
  if [[ $current == $default ]]; then
    git rebase "origin/$default"
  else
    git fetch . "origin/$default:$default"
  fi
}
