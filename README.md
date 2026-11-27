# dotfiles

ホームディレクトリの設定。[chezmoi](https://www.chezmoi.io/) で `~` に置く。作り直したときの設計と決めたことは [#1](https://github.com/yb173/dotfiles/issues/1) にある。

## 何がどこに置かれるか

| リポジトリ | `~` | 中身 |
| --- | --- | --- |
| `dot_zshenv` | `~/.zshenv` | zsh の設定の場所（`ZDOTDIR`）を決めるだけ |
| `private_dot_config/zsh/` | `~/.config/zsh/` | zsh（`.zprofile`・`.zshrc`・エイリアス・関数） |
| `.chezmoiexternal.toml` | `~/.local/share/zsh/plugins/`・`~/.agents/skills/yomiyasu/` | zsh のプラグインと、AI エージェントのスキル [yomiyasu](https://github.com/nanaism/yomiyasu)（AI が書いた日本語を推敲する。Codex は `~/.agents/skills` を読む）。chezmoi が GitHub から取ってくる |
| `private_dot_claude/skills/symlink_yomiyasu` | `~/.claude/skills/yomiyasu` | `~/.agents/skills/yomiyasu` へのシンボリックリンク。Claude Code も同じ yomiyasu を読む |
| `private_dot_config/starship.toml` | `~/.config/starship.toml` | starship（プロンプト）。既定から変えたのは、コマンドを待つ時間の上限を 1 秒に上げたこと（Mac が混んでいても node の版を出せるように）、Google Cloud のアカウント、パッケージの版（`package.json` の版など）、AWS のリージョンを出さないことと、記号に Nerd Font の文字を使わないこと（node の記号など）だけ |
| `private_dot_config/git/` | `~/.config/git/` | git |
| `private_dot_config/nvim/` | `~/.config/nvim/` | Neovim |
| `private_dot_config/ghostty/` | `~/.config/ghostty/` | Ghostty（`apps` のときだけ） |
| `private_dot_config/private_karabiner/` | `~/.config/karabiner/` | Karabiner-Elements（`apps` のときだけ） |
| `private_dot_config/mise/` | `~/.config/mise/` | mise（node は LTS の 26 の中で最新、python は最新を使う。`apps` のときだけ） |
| `run_onchange_before_brew-bundle.sh.tmpl` | （置かない。chezmoi が実行する） | `Brewfile` が変わったら、`~` を書き換える前に、足りないものを `brew bundle` で入れる |
| `run_onchange_before_brew-bundle-apps.sh.tmpl` | （置かない。chezmoi が実行する） | `Brewfile.apps` について同じことをする（`apps` のときだけ） |
| `run_onchange_macos-defaults.sh.tmpl` | （置かない。chezmoi が実行する） | macOS の設定（`defaults write`。`macos` のときだけ） |
| `run_onchange_after_mise-install.sh.tmpl` | （置かない。chezmoi が実行する） | mise の設定が変わったら、置いたあとで `mise install` する（`apps` のときだけ） |
| `run_onchange_after_karabiner-keyboard-check.sh.tmpl` | （置かない。chezmoi が実行する） | US 配列でないキーボードがあれば、警告を出す（`apps` のときだけ。Karabiner-Elements の設定を初めて置いたときと、変わったとき） |
| `Brewfile` | （置かない） | Homebrew で入れるもの（シェルと、シェルから使う CLI。どの Mac にも入れる） |
| `Brewfile.apps` | （置かない） | Homebrew で入れるもの（GUI のアプリと好みのツール。`apps` のときだけ） |
| `AGENTS.md`・`CLAUDE.md` | （置かない） | このリポジトリで作業する AI エージェント向けの説明 |
| `.github/` | （置かない） | GitHub Actions（gitleaks で秘密情報を調べる、`actions.lock` を確かめる）、Dependabot（Actions の版を上げる）、Renovate（zsh のプラグインと yomiyasu の版を上げる） |
| `.chezmoi.toml.tmpl` | `~/.config/chezmoi/chezmoi.toml` | chezmoi の設定（このリポジトリの場所と、Mac ごとに選んだもの） |

- `~/.config` は自分だけが読める権限（`700`）なので、リポジトリでは `private_dot_config` と書く
- この Mac だけの設定と秘密情報は、次のファイルに書き、リポジトリに入れない（`.chezmoiignore` に書いてあるので、`chezmoi add` でも入らない）。秘密情報を書くなら `chmod 600` にするか、macOS のキーチェーンから取り出す（`security find-generic-password -s <名前> -w`）
  - `~/.config/zsh/local.zprofile`: 環境変数・PATH・秘密情報の `export`（GCP の SDK の PATH など）。あれば、`.zprofile` が最後に読む。ログインシェルなら、対話でなくても（`zsh -l -c`）読まれる
  - `~/.config/zsh/local.zsh`: 補完・エイリアス・関数（GCP の SDK の補完など）。あれば、`.zshrc` が最後に読む
  - `~/.config/git/config.local`: git の名前とメール（`[user]`）など。あれば、`~/.config/git/config` が最後に読む（`[include]`）。名前とメールがないと、コミットのときに「Please tell me who you are」で止まる（`user.useConfigOnly`。Mac の名前から作ったメールでコミットしないように）
    - 書くときは `git config --file ~/.config/git/config.local …` を使う。git が勧める `git config --global` は、`~/.gitconfig` がないと chezmoi が置いた `~/.config/git/config` に書く
  - `.zshenv` 用の `local` のファイルは作らない。`.zshenv` はスクリプトの zsh も含めてすべての zsh が読み、macOS では後から `/etc/zprofile` の `path_helper` が PATH を並べ直すため
- yomiyasu は名前を出して頼んだとき（`/yomiyasu`、「yomiyasu で直して」など）だけ使われる。いつも使わせる 1 行（yomiyasu の README の「毎回 yomiyasu を使いたいとき」）は、`CLAUDE.md`・`AGENTS.md` に書いていない
- `run_onchange_` のスクリプトは、中身が前に実行したときと変わると、`chezmoi apply` が実行する。Brewfile の 2 つ・mise・Karabiner-Elements のスクリプトには、それぞれ `Brewfile`・`Brewfile.apps`・mise の設定・`karabiner.json` のハッシュが書かれる（`.tmpl` なので、chezmoi が描くときに入れる）ので、そのファイルが変わると実行される。空に描かれたスクリプトは実行しない

### Mac ごとに選ぶもの

`chezmoi init` のときに 2 つ聞かれる。既定は「入れない」で、シェル（zsh・git・Neovim・starship）の設定だけを置く。

| 名前 | 聞くこと | 「入れる」と答えた Mac だけですること |
| --- | --- | --- |
| `macos` | macOS の設定を変えるか | macOS の設定のスクリプトを実行する（外観・Finder・Dock・キーリピート・トラックパッド。Dock と Finder が再起動する） |
| `apps` | GUI のアプリ、好みのツール、mise の設定を入れるか | `Brewfile.apps` のもの（Ghostty・Karabiner-Elements・フォント・ffmpeg・yt-dlp・webp・libpq・gitleaks）を入れ、Ghostty・Karabiner-Elements・mise の設定を置き、`mise install` する |

- 答えは `~/.config/chezmoi/chezmoi.toml` の `[data]` に残り、次からは聞かれない。変えるときは `chezmoi init --prompt` で聞き直す
- 「入れない」に変えても、置いてあった設定や入っているアプリは消えない。chezmoi が管理しなくなるだけ
- Karabiner-Elements の設定は US 配列のキーボードを前提にしている（仮想キーボードを `ansi` に決め打ち）。JIS や ISO の配列のキーボードがある Mac では、`chezmoi apply` が警告を出す（止めはしない）。そのまま使うと `_` や `¥` などの記号の位置がずれる。ずれて困るなら、その Mac では `apps` を入れないか、Karabiner-Elements の画面で配列を変える（`karabiner.json` が書き換わり、`chezmoi status` に差分として出続ける）

## 新しい Mac で揃える

Apple Silicon の Mac を前提にしている（Homebrew の場所を `/opt/homebrew` と決めて書いている）。

1. Homebrew を入れる（[公式の手順](https://brew.sh/)）。入れたら、今のターミナルでも使えるようにする

   ```sh
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   eval "$(/opt/homebrew/bin/brew shellenv)"
   ```

2. GitHub にログインする。次の clone は SSH でするので、clone より前に要る（リポジトリは public なので、HTTPS なら認証なしでも clone できる。ただ、push するにはやはり要る）。聞かれたら `GitHub.com` → `SSH` を選び、SSH の鍵を作って登録する

   ```sh
   brew install gh chezmoi
   gh auth login
   ```

3. このリポジトリを ghq の場所に clone し、`~` に置く。初めて github.com に SSH でつなぐので、ホストの確認には `yes` と答える

   ```sh
   chezmoi init --apply --source ~/ghq/github.com/yb173/dotfiles git@github.com:yb173/dotfiles.git
   ```

   `--source` に渡した場所が chezmoi の設定（`sourceDir`）に入る。fork したときは、URL と `--source` を自分のリポジトリのものにする

   はじめに、`macos` と `apps` を入れるかを聞かれる（上の「Mac ごとに選ぶもの」）。この Mac と同じにするなら、どちらも `y`

   `chezmoi apply` は次の順に進む。途中で失敗したら、直してから `chezmoi apply` をもう一度実行する（済んだスクリプトはもう実行しない）
   1. `Brewfile`（`apps` なら `Brewfile.apps` も）のものを `brew bundle` で入れる。Karabiner-Elements はインストーラーなので、管理者のパスワードを聞かれる。先に入れるので、置いた `.zshrc` が、まだ入っていない mise や starship を呼ぶことはない
   2. `~` に置き、zsh のプラグインと yomiyasu を取ってくる。`macos` なら macOS の設定のスクリプトを実行する（Dock と Finder が再起動する）
   3. `apps` なら、mise で node と python を入れる

4. 画面で許可を出し、残りを手で済ませる
   - git の名前とメールを `~/.config/git/config.local` に書く: `git config --file ~/.config/git/config.local user.name <名前>` と `git config --file ~/.config/git/config.local user.email <メール>`
   - （`apps`）Karabiner-Elements を開き、入力監視と、ドライバー（システム設定 → 一般 → ログイン項目と機能拡張）を許可する
   - （`apps`）Ghostty を開き、アクセシビリティを許可する（Control の 2 回押しで出し入れするホットキーのため）。許可したら Ghostty を終了して開き直す。ログイン項目にも Ghostty を足す（起動していないとホットキーが効かない）
   - gh の拡張を入れる（拡張は gh の設定ファイルに残らない）: `gh extension install github/gh-actions-lock`
   - （`macos`）一度ログアウトしてログインし直す（キーリピートと外観はログインし直すと反映される）
   - Neovim を初めて開くと、配色の iceberg を入れるか聞かれる。入れる版は `nvim-pack-lock.json` に書いてある
   - この Mac だけの設定があれば、`~/.config/zsh/local.zprofile`（環境変数・PATH）と `~/.config/zsh/local.zsh`（補完・エイリアスなど）に書く

5. 新しいタブ（`apps` なら Ghostty で）を開き、エラーが出ずにプロンプトが出ることを確かめる。`chezmoi doctor` と `chezmoi status`（何も出なければ揃っている）でも確かめる

## すでに zsh の設定がある Mac から移る

すでに `~/.zshrc` などがある Mac に入れるときは、先に控えを取り、残したい設定を `local` のファイルに移してから置く。

- chezmoi は自分が置いたことのないファイルを、聞かずに上書きする。上書きされるのは `~/.zshenv`、`~/.config/zsh/`、`~/.config/git/` の `config` と `ignore`、`~/.config/nvim/`、`~/.config/starship.toml`、`~/.agents/skills/yomiyasu/`、`~/.claude/skills/yomiyasu`（`apps` なら Ghostty・Karabiner-Elements・mise の設定も）
- 置いたあとは、zsh は `~/.zshrc`・`~/.zprofile` を読まない。置かれた `~/.zshenv` が zsh の設定の場所（`ZDOTDIR`）を `~/.config/zsh` に変えるため
- 反対に、置いたあとも `~/.gitconfig` と Ghostty の `~/Library/Application Support/com.mitchellh.ghostty/` の設定は読まれ、同じ項目はこのリポジトリの設定より優先される（6・7 で片付ける）

1. 「新しい Mac で揃える」の 1 と 2（Homebrew を入れる、GitHub にログインする）を済ませる

2. 上書きされるかもしれないファイルの控えを取る。あるものだけをパスごとホームの tar.gz に入れる

   ```zsh
   cd ~
   files=()
   for f in .zshenv .zprofile .zshrc .zlogin .zsh_history .gitconfig .config/git .config/nvim .config/starship.toml .config/mise .config/ghostty .config/karabiner 'Library/Application Support/com.mitchellh.ghostty'; do
     [[ -e $f ]] && files+=("$f")
   done
   tar -czf ~/dotfiles-backup-$(date +%F).tar.gz $files
   ```

3. このリポジトリを clone し、chezmoi の設定を作る。まだ置かない（`--apply` を付けない）。聞かれる 2 つ（「Mac ごとに選ぶもの」）は、この Mac の macOS の設定やアプリを変えたくなければ、どちらも Enter（入れない）

   ```sh
   chezmoi init --source ~/ghq/github.com/yb173/dotfiles git@github.com:yb173/dotfiles.git
   ```

4. `Brewfile` のものを版も上げて入れる。`chezmoi apply` は足りないものを入れるだけで、入っているものの版は上げない。古い版のままだと、Neovim（0.12 より前は `vim.pack` がない）や fzf（古いと `fzf --zsh` がない）が、置いた設定を読むときに失敗する。上がるのは `Brewfile` にあるものだけ

   ```sh
   brew update
   brew bundle --file "$(chezmoi source-path)/Brewfile"
   ```

   `apps` と答えたなら、`Brewfile.apps` も同じようにする（`--file "$(chezmoi source-path)/Brewfile.apps"`）

5. 今の zsh の設定にあって、残したいものを移す。見るのは `~/.zshenv`・`~/.zprofile`・`~/.zshrc`・`~/.zlogin` と、そこから `source`（か `.`）で読んでいるファイル。インストーラーやアプリが書き足した行（Rancher Desktop・Docker Desktop・gcloud など）は、たいてい `~/.zshrc`・`~/.zprofile` にある。prezto では、`~/.zshrc` などは `~/.zprezto/runcoms/` のファイルへのリンク（`~/.zshrc` を開けば中身が見える）

   ```zsh
   cd ~
   # source か . で読んでいるファイルを出す（関係のない行も少し出る）
   grep -HnE '(^|[[:space:];&|{])(source|\.)[[:space:]]' .zshenv .zprofile .zshrc .zlogin 2>/dev/null
   ```

   | 中身 | 移す先 |
   | --- | --- |
   | 環境変数・PATH（`~/.zshenv` にあるものも。Rancher Desktop の `~/.rd/bin`、gcloud の `path.zsh.inc` など） | `~/.config/zsh/local.zprofile` |
   | 補完・エイリアス・関数（gcloud の `completion.zsh.inc` など） | `~/.config/zsh/local.zsh` |

   - oh-my-zsh の `$ZSH_CUSTOM`（既定は `~/.oh-my-zsh/custom`）にある `.zsh` のファイルは、`source` を書かなくても読まれていた。自分で書いたものがあれば、それも移す
   - `fpath` に足して `compinit` で読ませている補完（Docker Desktop の `~/.docker/completions` など）は、`local.zsh` で `compdef` を使って足す。`local.zsh` は `compinit` のあとに読むので、`fpath` に足すだけでは効かない

     ```zsh
     fpath+=(~/.docker/completions)
     autoload -Uz _docker && compdef _docker docker
     ```

   - プロンプトやプラグインの設定（oh-my-zsh・prezto・Powerlevel10k など。`source` している `oh-my-zsh.sh`・`~/.zprezto/init.zsh` も）は移さない。このリポジトリの設定（starship など）を使う
   - `~/.local/bin` はもう PATH に入っている。`~/bin` は入らない。prezto は `~/bin`・`~/sbin` を入れていた（`zprofile` の `$HOME/{,s}bin(N)`）ので、使っていれば `local.zprofile` に書く

     ```zsh
     path=($HOME/bin(N-/) $path)
     ```

6. git の設定を `~/.config/git/config.local` に移す。`chezmoi apply` の前なので `~/.config/git` がまだないことがあり、先に `mkdir -p ~/.config/git` で作る。`~/.gitconfig` がなければ、名前とメールを書くだけ（書き方は「何がどこに置かれるか」）。`~/.gitconfig` があれば、中身を全部見て、残すものを `config.local` に移してから、`~/.gitconfig` を消す（控えは 2 で取ってある）

   ```zsh
   mkdir -p ~/.config/git                   # chezmoi apply の前なので、まだないことがある
   git config --file ~/.gitconfig --list    # 書いてあるものを全部見る
   git config --file ~/.config/git/config.local user.name "$(git config --file ~/.gitconfig user.name)"
   git config --file ~/.config/git/config.local user.email "$(git config --file ~/.gitconfig user.email)"
   ```

   - 名前とメールのほかに残すものは、エディターで節（`[alias]`・`[url "…"]` など）ごと `~/.gitconfig` から `config.local` に写す。見落としやすいのは次のもの。
     - `url.<base>.insteadOf`: clone・push する先の URL を書き換える（`https://github.com/` を `git@github.com:` に、など）。消すと、つなぎ方が変わり、push できなくなることがある
     - `credential.*`: push のときの認証をどこから取るか（`gh auth setup-git` が書く `gh auth git-credential` など）。消すと、HTTPS の push で認証を聞かれる
     - `include.path`・`includeIf.*.path`: ほかのファイルを読ませている（会社のリポジトリだけ別のメールにする、など）。`--list` には、読ませているファイルの中身は出ない
   - 移さないもの: このリポジトリの設定と同じ項目（`init.defaultBranch`・`ghq.root` など）と、`core.excludesfile`（あると、このリポジトリの `~/.config/git/ignore` が読まれなくなる）。`config.local` は最後に読まれ、同じ項目はそちらが勝つので、移すとこのリポジトリの設定が効かなくなる

   移したら消す。git は `~/.config/git/config` のあとに `~/.gitconfig` を読み、同じ項目は `~/.gitconfig` のほうが勝つので、残っていると、このリポジトリの設定が効かない

   ```zsh
   trash ~/.gitconfig
   ```

7. （`apps`）Ghostty の設定が `~/Library/Application Support/com.mitchellh.ghostty/` にあれば（`config.ghostty` か、古い Ghostty では `config`）、残したい項目がない限り消す（控えは 2 で取ってある）。Ghostty はそこと `~/.config/ghostty/` の両方を読み、同じ項目は `~/Library/Application Support` のほうが勝つので、残っていると、このリポジトリのフォントやホットキーの設定が効かなくなる

   ```zsh
   ls ~/Library/Application\ Support/com.mitchellh.ghostty/
   trash ~/Library/Application\ Support/com.mitchellh.ghostty/config.ghostty   # あるものを消す
   ```

8. 履歴を新しい場所（`~/.local/state/zsh/history`）にコピーする。新しい履歴がまだないときだけコピーするので、何度実行してもよい

   ```zsh
   mkdir -p ~/.local/state/zsh
   [[ -e ~/.local/state/zsh/history ]] || cp -p ~/.zsh_history ~/.local/state/zsh/history
   ```

9. 差分を見てから置く

   ```sh
   chezmoi diff
   chezmoi apply
   ```

10. 新しいタブを開き、エラーが出ずにプロンプトが出ること、使っていたコマンドが見つかることを確かめる。`chezmoi status` が空になることも確かめる。戻すときは、控えを `tar -xzf ~/dotfiles-backup-<日付>.tar.gz -C ~` で戻す（`~/.zshenv` も戻るので、前の設定を読むようになる）

あとで、インストーラーやアプリが zsh の設定に行を書き足したときは、次のようにする。

- `~/.zshrc` に書き足すものはもう読まれない。必要な行を `local.zprofile`・`local.zsh` に移す
- `ZDOTDIR` を見て `~/.config/zsh/.zshrc` に書き足すものは、`chezmoi status` に出る。書き足された行を `local` のファイルに移し、`chezmoi apply` で `.zshrc` を戻す

## 普段の直し方

変えたら PR にする（main には直接 push しない）。

| したいこと | すること |
| --- | --- |
| 設定を直す | このリポジトリのファイルを直して `chezmoi apply`（前に `chezmoi diff` で差分を見る） |
| アプリが `~` のファイルを書き換えた（Karabiner の画面で変えた、Neovim のプラグインを更新した など） | `chezmoi re-add` でリポジトリに戻す。ずれは `chezmoi status` でわかる |
| `~` に新しく設定ファイルを足す | `chezmoi add <ファイル>` |
| Homebrew で入れるものを増やす・減らす | シェルから使う CLI は `Brewfile`、GUI のアプリと好みのツールは `Brewfile.apps` を直して `chezmoi apply`（変わると、足りないものを `brew bundle` で入れる）。`Brewfile`・`Brewfile.apps` から消したものは `chezmoi apply` では消えないので、下の「ほかの Mac で取り込む」の表のとおり、`brew bundle cleanup` で消す |
| macOS の設定を変える | `run_onchange_macos-defaults.sh.tmpl` を直して `chezmoi apply`（中身が変わると実行される）。設定の名前は、画面で変える前と後の `defaults read` を比べて調べる |
| zsh の設定を読み直す | `.zshrc` とそこから読むもの（エイリアス・関数・`local.zsh`）は `reload`（`exec zsh`）。`.zprofile` と `local.zprofile` は新しいタブを開く（`exec zsh` はログインシェルではないので読み直さない） |

## ほかの Mac で取り込む

main が更新されたら、ほかの Mac では次のようにする。その Mac のリポジトリは main にいること（ほかのブランチにいると、そのブランチを pull する）。

```sh
chezmoi update --apply=false   # リポジトリを pull するだけ（git pull --autostash --rebase）
chezmoi diff                   # ~ に何が置かれるかを見る
chezmoi apply
```

- `chezmoi update` だけでも、pull と `chezmoi apply` を続けてする。ただ、`chezmoi apply` はその Mac の設定をその場で書き換えるので、先に差分を見る
- その Mac で `~` のファイルを直接直していると、`chezmoi apply` が上書きしてよいか聞く。残したいときは上書きせず、`chezmoi re-add` でリポジトリに戻して PR にする
- `chezmoi` が「config file template has changed, run chezmoi init to regenerate config file」と出したら、`chezmoi init` を実行する（新しく聞くことがあれば聞かれる）。しないまま答えを使うテンプレートを描くと、「map has no entry for key "apps"」のように止まる
- その Mac に `~/.config/git/config.local`（git の名前とメール）がなければ、`chezmoi apply` の前に作る（書き方は上の「何がどこに置かれるか」）。git の設定には名前とメールを書いていないので、ないとコミットのときに止まる
- `chezmoi apply` は変わったものに合わせて次もする
  - `Brewfile`（`apps` なら `Brewfile.apps` も）が変わっていれば、`~` を書き換える前に、足りないものを `brew bundle` で入れる（入っているものの版は上げない）
  - zsh のプラグインや yomiyasu の版が変わっていれば、取り直す
  - （`macos`）macOS の設定のスクリプトが変わっていれば、実行する（Dock と Finder が再起動する）
  - （`apps`）mise の設定が変わっていれば、置いたあとで `mise install` する
  - （`apps`）Karabiner-Elements の設定が変わっていれば、置いたあとでキーボードが US 配列かを確かめ、違えば警告を出す（上の「Mac ごとに選ぶもの」）

`chezmoi apply` だけでは済まないものは次のとおり。

| 変わったもの | すること |
| --- | --- |
| `Brewfile`・`Brewfile.apps` から消したもの | `cd "$(chezmoi source-path)" && cat Brewfile Brewfile.apps \| brew bundle cleanup --file=-` で一覧を見て、よければ `--force` を付けて消す。2 つをまとめて渡す（`Brewfile` だけだと、`Brewfile.apps` のものも消す一覧に入る）。2 つにないものは全部消えるので、`apps` でない Mac（Homebrew のものをこのリポジトリで管理していない Mac）では使わない |
| Neovim のプラグイン（`nvim-pack-lock.json`） | Neovim を開き直してから `:lua vim.pack.update(nil, { target = 'lockfile' })`。変わる中身が出るので、よければ `:write` で確定する |
| zsh の設定 | 新しいタブを開く（`.zshrc` 側だけなら `reload` でもよい） |
| Ghostty の設定 | Ghostty で Cmd+Shift+,（設定を読み直す） |
| Karabiner-Elements の設定 | 要らない（ファイルが変わると、自分で読み直す） |

## 版を上げる

ものによって上げ方が違う。`~` のファイルに版が書いてあるものは、上げたあと `chezmoi re-add` でリポジトリに戻して PR にする。

| もの | 上げ方 | リポジトリ |
| --- | --- | --- |
| Homebrew で入れた CLI とフォント（chezmoi・Neovim なども） | `brew update` のあと `brew upgrade`。上がるものは `brew outdated` で見る | 変わらない（Brewfile は版を書かない） |
| Ghostty・Karabiner-Elements | アプリの中の更新で上がる。cask が「アプリが自分で更新する」（`auto_updates`）なので、`brew upgrade` は飛ばす。Homebrew で上げるなら `brew upgrade --greedy-auto-updates` | 変わらない |
| node・python（mise） | `mise upgrade` で新しい版を入れる（設定は node が `26`、python が `latest`。node は 26 の中で最新になり、27 には上がらない）。新しい版があるかは `mise outdated` で見る。mise は入っている中で最新の版を使うので、`mise upgrade` するまでは今の版のまま。古い版は 1 日後に消える。プロジェクトに `.node-version` などがあれば、そちらの版を使う | 変わらない。node を 26 より上げるときは、`config.toml` の `26` を書き換える |
| zsh のプラグイン・yomiyasu | 新しいタグが出て 7 日たつと、Renovate が `.chezmoiexternal.toml` の URL のタグを書き換える PR を作る。差分（yomiyasu はリリースノートも）を見てマージし、`chezmoi apply` で取り直す。yomiyasu は版がよく出るので、PR もよく来る。Renovate が見つけたものと、待っている版は、issue の「Dependency Dashboard」に出る。手で上げるときは、URL のタグを書き換えて PR にする | PR で変わる |
| GitHub Actions（ワークフローの Action） | マイナー版・パッチ版は、Dependabot が週に 1 回 PR を作る。Dependabot は `actions.lock` も一緒に更新する。`verify-lockfile` が失敗したときは、PR のブランチで `actions.lock` を更新して push してからマージする: `gh pr checkout <番号>` → `gh actions-lock` → `git commit -am 'ci: actions.lock を更新する'` → `git push`。メジャー版は PR にならない（使い方が変わることがあるため）。ときどき各 Action のリリース（`gh release list -R actions/checkout` など）を見て、リリースノートを読んでから手で上げる: ワークフローの版を書き換え、`gh actions-lock` を実行して PR にする | PR で変わる |
| gh の拡張（gh-actions-lock） | `gh extension upgrade actions-lock`。`verify-lockfile` が使う版（`github/gh-actions-lock@verify/v*`）は Dependabot が上げるので、手元もときどき上げる | 変わらない |
| Neovim のプラグイン（iceberg） | Neovim で `:lua vim.pack.update()`。変わる中身が出るので、よければ `:write` で確定する。`~/.config/nvim/nvim-pack-lock.json` が書き換わる | `chezmoi re-add` で戻す |

## zsh で使える関数

git の補助の関数は名前が `g` で始まり、選ぶところは fzf を使う。`-s` でファイルを選ぶもの（`ga`・`gd`・`grst`・`gdiscard`）は、今いるディレクトリに関係なく、リポジトリ全体から選ぶ。

| 関数 | すること |
| --- | --- |
| `gst` | `git status` |
| `gnew <ブランチ名>` | 既定のブランチを origin に合わせてから、新しいブランチを作って移る |
| `gsync` | 今のブランチのまま、既定のブランチを origin に合わせる。ほかのブランチにいるときは、チェックアウトせずに早送りする（作業中の変更があっても動く。既定のブランチにだけあるコミットがあると、何も変えずに失敗する） |
| `ga` / `ga -s` | `git add`。`-s` でファイルを選ぶ |
| `gd` / `gd -s` | `git diff`。`-s` でファイルを選ぶ（今いるディレクトリから数えたパスを、クリップボードにも入れる） |
| `grst` / `grst -s` | `git restore --staged`。`-s` でファイルを選ぶ |
| `gdiscard <ファイル>` / `gdiscard -s` | 作業中の変更を捨てる（聞いてから） |
| `gco -l` / `-r` / `-h` | ローカル・リモートのブランチ、コミットを選んでチェックアウトする。ほかの引数は `git checkout` に渡す |
| `gbc` / `gbc -r` | ブランチ名を選んでクリップボードに入れる |
| `gpo` | 今のブランチを origin に push する（聞いてから） |
| `gcp <ブランチ>` / `gcp -r <ブランチ>` | コミットを選んで cherry-pick する。`-r` で範囲（最初と最後を選ぶ。両方含む） |
| `grbi` | コミットを選んで、それより後を `rebase -i` する |
| `gbs -s` / `-b` / `-g` / `-r` | bisect を始める（悪い、良いの順に選ぶ）・bad・good・reset |
| `ghash` | コミットを選んで、ハッシュを出す |

ほかに `mkcd`（作って移る）、`up [n]`（n 個上に移る）、`fkill`（プロセスを選んで kill）がある。キー操作は Ctrl-R（履歴）、Ctrl-T（ファイル）、Alt-C（ディレクトリ）、Ctrl-G（zoxide のよく行くディレクトリ）、Ctrl-]（ghq のリポジトリ）。
