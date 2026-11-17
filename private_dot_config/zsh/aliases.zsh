# エイリアス。コマンドと同じ名前にするのは、オプションを足すだけのもの（ls・grep・mkdir・rm・mv・ln）
# git の補助は functions/git.zsh に、エイリアスを挟まず関数で書く

alias g=git
alias ls='ls -G'                # 色を付ける
alias ll='ls -lh'
alias la='ll -A'
alias grep='grep --color=auto'
alias mkdir='mkdir -p'
# 設定を読み直す。source ~/.zshrc だと、消した設定が残ったり PATH が重なったりするので、起動し直す
alias reload='exec zsh'

# 消す・上書きする前に聞く。Claude Code のシェル（CLAUDECODE=1）では付けない。
# Claude Code は対話のシェルのエイリアスを写し取って使うが、聞かれても答えられないため
if [[ -z $CLAUDECODE ]]; then
  alias rm='rm -i'
  alias mv='mv -i'
  alias ln='ln -i'
fi
