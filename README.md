# dotfiles

ホームディレクトリの設定。[chezmoi](https://www.chezmoi.io/) で `~` に置く。作り直したときの設計と決めたことは [#1](https://github.com/yb173/dotfiles/issues/1) にある。

## 何がどこに置かれるか

| リポジトリ | `~` | 中身 |
| --- | --- | --- |
| `dot_zshenv` | `~/.zshenv` | zsh の設定の場所（`ZDOTDIR`）を決めるだけ |
| `private_dot_config/zsh/` | `~/.config/zsh/` | zsh（`.zprofile`・`.zshrc`・エイリアス・関数） |
| `.chezmoiexternal.toml` | `~/.local/share/zsh/plugins/` | zsh のプラグイン（chezmoi が GitHub から取ってくる） |
| `private_dot_config/starship.toml` | `~/.config/starship.toml` | starship（プロンプト）。Google Cloud のアカウントとパッケージの版（`package.json` の版など）を出さないことと、記号に Nerd Font の文字を使わないこと（node の記号など）だけで、ほかは既定のまま |
| `private_dot_config/git/` | `~/.config/git/` | git |
| `private_dot_config/nvim/` | `~/.config/nvim/` | Neovim |
| `private_dot_config/ghostty/` | `~/.config/ghostty/` | Ghostty |
| `private_dot_config/private_karabiner/` | `~/.config/karabiner/` | Karabiner-Elements |
| `private_dot_config/mise/` | `~/.config/mise/` | mise（node は LTS の 26 の中で最新、python は最新を使う） |
| `run_onchange_before_brew-bundle.sh.tmpl` | （置かない。chezmoi が実行する） | Brewfile が変わったら、`~` を書き換える前に、足りないものを `brew bundle` で入れる |
| `run_onchange_macos-defaults.sh` | （置かない。chezmoi が実行する） | macOS の設定（`defaults write`） |
| `run_onchange_after_mise-install.sh.tmpl` | （置かない。chezmoi が実行する） | mise の設定が変わったら、置いたあとで `mise install` する |
| `Brewfile` | （置かない） | Homebrew で入れるもの |
| `AGENTS.md`・`CLAUDE.md` | （置かない） | このリポジトリで作業する AI エージェント向けの説明 |
| `.github/` | （置かない） | GitHub Actions（gitleaks で秘密情報を調べる、`actions.lock` を確かめる）、Dependabot（Actions の版を上げる）、Renovate（zsh のプラグインの版を上げる） |
| `.chezmoi.toml.tmpl` | `~/.config/chezmoi/chezmoi.toml` | chezmoi の設定（このリポジトリの場所） |

- `~/.config` は自分だけが読める権限（`700`）なので、リポジトリでは `private_dot_config` と書く
- この Mac だけの設定（GCP の SDK など）は `~/.config/zsh/local.zsh` に書き、リポジトリに入れない。`.zshrc` が、あれば読む
- `run_onchange_` のスクリプトは、中身が前に実行したときと変わると、`chezmoi apply` が実行する。Brewfile と mise のスクリプトには、そのファイルのハッシュが書かれる（`.tmpl` なので、chezmoi が描くときに入れる）ので、そのファイルが変わると実行される

## 新しい Mac で揃える

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

   `chezmoi apply` は、次の順に進む。途中で失敗したら、直してから `chezmoi apply` をもう一度実行する（済んだスクリプトは、もう実行しない）
   1. Brewfile のものを `brew bundle` で入れる。Karabiner-Elements はインストーラーなので、管理者のパスワードを聞かれる。先に入れるので、置いた `.zshrc` が、まだ入っていない mise や starship を呼ぶことはない
   2. `~` に置き、zsh のプラグインを取ってきて、macOS の設定のスクリプトを実行する（Dock と Finder が再起動する）
   3. mise で node と python を入れる

4. 画面で許可を出し、残りを手で済ませる
   - Karabiner-Elements を開き、入力監視と、ドライバー（システム設定 → 一般 → ログイン項目と機能拡張）を許可する
   - Ghostty を開き、アクセシビリティを許可する（Control の 2 回押しで出し入れするホットキーのため）。許可したら Ghostty を終了して開き直す。ログイン項目にも Ghostty を足す（起動していないとホットキーが効かない）
   - gh の拡張を入れる（拡張は gh の設定ファイルに残らない）: `gh extension install github/gh-actions-lock`
   - 一度ログアウトしてログインし直す（キーリピートと外観は、ログインし直すと反映される）
   - Neovim を初めて開くと、配色の iceberg を入れるか聞かれる。入れる版は `nvim-pack-lock.json` に書いてある
   - この Mac だけの設定があれば `~/.config/zsh/local.zsh` に書く

5. Ghostty で新しいタブを開き、エラーが出ずにプロンプトが出ることを確かめる。`chezmoi doctor` と `chezmoi status`（何も出なければ揃っている）でも確かめる

## 普段の直し方

変えたら PR にする（main には直接 push しない）。

| したいこと | すること |
| --- | --- |
| 設定を直す | このリポジトリのファイルを直して `chezmoi apply`（前に `chezmoi diff` で差分を見る） |
| アプリが `~` のファイルを書き換えた（Karabiner の画面で変えた、Neovim のプラグインを更新した など） | `chezmoi re-add` でリポジトリに戻す。ずれは `chezmoi status` でわかる |
| `~` に新しく設定ファイルを足す | `chezmoi add <ファイル>` |
| Homebrew で入れるものを増やす・減らす | `Brewfile` を直して `chezmoi apply`（Brewfile が変わると、足りないものを `brew bundle` で入れる）。Brewfile から消したものは消えないので、`brew bundle cleanup --file Brewfile` で一覧を見て、`--force` を付けて消す |
| macOS の設定を変える | `run_onchange_macos-defaults.sh` を直して `chezmoi apply`（中身が変わると実行される）。設定の名前は、画面で変える前と後の `defaults read` を比べて調べる |
| zsh の設定を読み直す | `reload`（`exec zsh`） |

## ほかの Mac で取り込む

main が更新されたら、ほかの Mac では次のようにする。その Mac のリポジトリは main にいること（ほかのブランチにいると、そのブランチを pull する）。

```sh
chezmoi update --apply=false   # リポジトリを pull するだけ（git pull --autostash --rebase）
chezmoi diff                   # ~ に何が置かれるかを見る
chezmoi apply
```

- `chezmoi update` だけでも、pull と `chezmoi apply` を続けてする。ただ、`chezmoi apply` はその Mac の設定をその場で書き換えるので、先に差分を見る
- その Mac で `~` のファイルを直接直していると、`chezmoi apply` が上書きしてよいか聞く。残したいときは上書きせず、`chezmoi re-add` でリポジトリに戻して PR にする
- `chezmoi apply` は、変わったものに合わせて次もする
  - Brewfile が変わっていれば、`~` を書き換える前に、足りないものを `brew bundle` で入れる（入っているものの版は上げない）
  - zsh のプラグインの版が変わっていれば、取り直す
  - macOS の設定のスクリプトが変わっていれば、実行する（Dock と Finder が再起動する）
  - mise の設定が変わっていれば、置いたあとで `mise install` する

`chezmoi apply` だけでは済まないもの:

| 変わったもの | すること |
| --- | --- |
| Brewfile から消したもの | `brew bundle cleanup --file ~/ghq/github.com/yb173/dotfiles/Brewfile --force` で消す（Brewfile にないものは全部消えるので、先に `--force` なしで一覧を見る） |
| Neovim のプラグイン（`nvim-pack-lock.json`） | Neovim を開き直してから `:lua vim.pack.update(nil, { target = 'lockfile' })`。変わる中身が出るので、よければ `:write` で確定する |
| zsh の設定 | 新しいタブを開くか、`reload` |
| Ghostty の設定 | Ghostty で Cmd+Shift+,（設定を読み直す） |
| Karabiner-Elements の設定 | 要らない（ファイルが変わると、自分で読み直す） |

## 版を上げる

ものによって上げ方が違う。`~` のファイルに版が書いてあるものは、上げたあと `chezmoi re-add` でリポジトリに戻して PR にする。

| もの | 上げ方 | リポジトリ |
| --- | --- | --- |
| Homebrew で入れた CLI とフォント（chezmoi・Neovim なども） | `brew update` のあと `brew upgrade`。上がるものは `brew outdated` で見る | 変わらない（Brewfile は版を書かない） |
| Ghostty・Karabiner-Elements | アプリの中の更新で上がる。cask が「アプリが自分で更新する」（`auto_updates`）なので、`brew upgrade` は飛ばす。Homebrew で上げるなら `brew upgrade --greedy-auto-updates` | 変わらない |
| node・python（mise） | `mise upgrade` で新しい版を入れる（設定は node が `26`、python が `latest`。node は 26 の中で最新になり、27 には上がらない）。新しい版があるかは `mise outdated` で見る。mise は入っている中で最新の版を使うので、`mise upgrade` するまでは今の版のまま。古い版は 1 日後に消える。プロジェクトに `.node-version` などがあれば、そちらの版を使う | 変わらない。node を 26 より上げるときは、`config.toml` の `26` を書き換える |
| zsh のプラグイン | 新しいタグが出て 7 日たつと、Renovate が `.chezmoiexternal.toml` の URL のタグを書き換える PR を作る。差分を見てマージし、`chezmoi apply` で取り直す。Renovate が見つけたプラグインと、待っている版は、issue の「Dependency Dashboard」に出る。手で上げるときは、URL のタグを書き換えて PR にする | PR で変わる |
| Neovim のプラグイン（iceberg） | Neovim で `:lua vim.pack.update()`。変わる中身が出るので、よければ `:write` で確定する。`~/.config/nvim/nvim-pack-lock.json` が書き換わる | `chezmoi re-add` で戻す |

## zsh で使える関数

git の補助は `g` で始まり、選ぶところは fzf を使う。

| 関数 | すること |
| --- | --- |
| `gst` | `git status` |
| `gnew <ブランチ名>` | 既定のブランチを origin に合わせてから、新しいブランチを作って移る |
| `gsync` | 今のブランチのまま、既定のブランチを origin に合わせる |
| `ga` / `ga -s` | `git add`。`-s` でファイルを選ぶ |
| `gd` / `gd -s` | `git diff`。`-s` でファイルを選ぶ（パスはクリップボードにも入る） |
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
