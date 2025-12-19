# Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
ENABLE_CORRECTION="true"

plugins=(git z extract zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

export USE_CCACHE=1
export CCACHE_DIR="$HOME/.cache/ccache"
export MAX_SOONG_JOBS=4
export JOBS=12

ulimit -n 1048576
ulimit -u unlimited

alias ls='lsd'
alias ll='lsd -l'
alias la='lsd -a'
alias lla='lsd -la'
alias lt='lsd --tree'

command -v fastfetch >/dev/null && fastfetch
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
