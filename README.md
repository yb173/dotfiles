# dotfiles
⚙ ホームディレクトリの設定ファイル

## 使い方
1. ホームディレクトリで `git clone` する．
1. 元の `.zshrc` などをバックアップする．
1. シンボリックリンクを貼る
```sh
$ ln -s ~/dotfiles/zsh/.zshrc.mine ~
$ ln -s ~/dotfiles/zsh/.zshrc.mine.aliases ~
$ ln -s ~/dotfiles/zsh/.zshrc.mine.functions ~
```

## 参考文献
- [ようこそdotfilesの世界へ](https://qiita.com/yutkat/items/c6c7584d9795799ee164)
- [Git の効率を爆上げするスクリプト集](https://zenn.dev/tick_taku/articles/d26ee3da94cb14)
