# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


##############################################################################
# GCP
##############################################################################
# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/yb173/Work/gcp/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/yb173/Work/gcp/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/yb173/Work/gcp/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/yb173/Work/gcp/google-cloud-sdk/completion.zsh.inc'; fi


##############################################################################
# 個人用の設定ファイル読み込み
##############################################################################
[ -f ${HOME}/.zshrc.mine ] && source ${HOME}/.zshrc.mine
