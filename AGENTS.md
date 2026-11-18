# このリポジトリで作業するとき

ホームディレクトリの設定を [chezmoi](https://www.chezmoi.io/) で `~` に置くリポジトリ。人向けの手順は `README.md`、設計と決めたことは issue #1 にある。

## ファイルの直し方

- 直すのは、このリポジトリのファイル。`~` のファイルを直接直さない（次の `chezmoi apply` で上書きされる）
  - アプリが `~` のファイルを書き換えたとき（Karabiner の画面、Neovim のプラグインの更新など）は、`chezmoi re-add` でリポジトリに戻す
- ファイル名は chezmoi の決まりに従う: `dot_`（先頭の `.`）、`private_`（自分だけが読める権限）、`run_onchange_`（中身が変わったときに `chezmoi apply` が実行するスクリプト）
  - `~/.config` は `700` なので、その下に置くものは `private_dot_config/` に入れる
  - スクリプトを、ほかのファイルが変わったときに実行させるには、`.tmpl` にして `{{ include "<ファイル>" | sha256sum }}` をコメントに書く（`run_onchange_before_brew-bundle.sh.tmpl` など）。`before_` は `~` を書き換える前、`after_` は後に実行する
- リポジトリにだけ置き、`~` に置かないファイル（`README.md`・`Brewfile`・このファイルなど）は `.chezmoiignore` に書く
  - 理由: 書き忘れると `~` に置かれる。`~/CLAUDE.md` ができると、ホームの下のすべてのプロジェクトで Claude Code が読んでしまう
- 外から取ってくるもの（zsh のプラグイン）は `.chezmoiexternal.toml` に、版を固定した URL で書く
  - URL は `https://github.com/<owner>/<repo>/archive/refs/tags/<タグ>.tar.gz` の形にする。Renovate は、この形の URL を正規表現で見つけて版を上げる（`.github/renovate.json5` の `matchStrings`）。形を変えるときは、`matchStrings` も直す

## 置く前と後に確かめる

- `chezmoi apply` は、この Mac の設定をその場で書き換え、`run_onchange_` のスクリプトも実行する（Brewfile が変わっていれば `brew bundle` で入れ、macOS の設定のスクリプトは Dock と Finder を再起動する）。置く前に `chezmoi diff` で差分を見る。`~/.zshenv` や macOS の設定のように影響が大きいものは、利用者に伝えてから置く
- ファイルの種類ごとの確かめ方
  - zsh: `zsh -n <ファイル>` で構文を見る。`~/.zshenv` を替える前に `ZDOTDIR=~/.config/zsh zsh -il` で試す（今のシェルは変わらない）
  - シェルスクリプト: `sh -n`
  - Ghostty: `/Applications/Ghostty.app/Contents/MacOS/ghostty +validate-config`。フォントがどれで描かれるかは `+show-face --string=…`
  - Karabiner: ルールを `{"title": …, "rules": […]}` の形に取り出して `karabiner_cli --lint-complex-modifications`
  - Neovim: `nvim --headless +qa` で、起動のときにエラーが出ないこと
  - Brewfile: `brew bundle check --file Brewfile`
- 置いたあとは、`chezmoi status` が空になることを確かめる

## zsh の書き方（Claude Code のシェルで壊さない）

Claude Code は、対話のシェルの関数・エイリアス・オプションを写し取り（`~/.claude/shell-snapshots/`）、対話でないシェルで読み込んで使う。

- 関数の名前を `_` で始めない
  - 理由: `_` で始まる関数は写し取られないので、それを呼ぶ関数やフックが `command not found` になる（前の設定では `cd` のたびにこれが出ていた）
- フックは `add-zsh-hook` で足し、フックの関数の中で `[[ -o interactive ]] || return 0` を確かめる。`chpwd()` などを直接上書きしない
- コマンドと同じ名前のエイリアスは、オプションを足すだけのものにする（`ls -G` など）。確認を聞くもの（`rm -i` など）は `[[ -z $CLAUDECODE ]]` のときだけ作る
  - 理由: Claude Code のシェルでは、聞かれても答えられない
- 新しい名前を付ける前に、`whence -wa <名前>` が `none` になること（コマンドや zsh の組み込みとぶつからないこと）を確かめる。git の補助は `g` で始める（`private_dot_config/zsh/functions/git.zsh`）

## 入れないもの

- 秘密情報（トークン、`~/.config/gh/hosts.yml`、`~/.codex/auth.json` など）。public のリポジトリなので、誰でも読める
- この Mac だけの設定（GCP の SDK の場所など）。環境変数・PATH は `~/.config/zsh/local.zprofile`、補完・エイリアスなどは `~/.config/zsh/local.zsh`、git の名前とメールは `~/.config/git/config.local` に書き、リポジトリに入れない（`.chezmoiignore` に書いてある）。中身を読むときは、値を出さない（秘密情報が入っていることがある）
- アプリが書く状態（Claude Code の `~/.claude/projects/`、Codex の `~/.codex/config.toml` など）

## 変更の出し方

- main に直接 push しない。issue に問題と方針を書き、PR の本文の先頭に `Closes #番号` を書く。issue は #1 のサブ issue にする
  - main はルールセットで守っている（PR を通さない push・force push・削除を止める）。リポジトリの管理者は止めない設定なので、利用者の認証で動くエージェントは push できてしまう。できても push しない
- 版を上げる PR は bot も作る: GitHub Actions は Dependabot、zsh のプラグインは Renovate。どちらも自動ではマージしない
- PR では GitHub Actions が gitleaks で秘密情報を調べる。public のリポジトリなので、見つかったら PR をマージせず、秘密情報を無効にしてから直す
- ワークフロー（`.github/workflows/`）を変えたら、`gh actions-lock` で `actions.lock` を更新する（PR で `verify-lockfile` が確かめる）。Action は版のタグで書く
- issue・PR・コミットメッセージ・コメントは日本語で書く
- issue・PR・コミットメッセージにも、手元の絶対パス・private のリポジトリ名・メールアドレスを書かない
  - 理由: public なので誰でも読める。issue や PR の本文は、あとで直しても前の版が残り、誰でも見られる（前の版は、GitHub の画面からしか消せない）
