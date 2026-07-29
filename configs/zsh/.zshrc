# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

ENABLE_CORRECTION="true"

plugins=(
  git
  z
  extract
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Android build environment
#export USE_CCACHE=1
#export CCACHE_DIR="$HOME/.cache/ccache"
#export MAX_SOONG_JOBS=4
#export JOBS=12
#ulimit -n 1048576
#ulimit -u unlimited

# Icons & aliases
alias sudo='sudo '
alias apt='nala'

# ls replacement (eza > lsd > ls)
if command -v eza >/dev/null; then
  alias ls='eza --icons'
  alias ll='eza --icons -l'
  alias la='eza --icons -la'
  alias lt='eza --icons --tree'
elif command -v lsd >/dev/null; then
  alias ls='lsd'
  alias ll='lsd -l'
  alias la='lsd -a'
  alias lla='lsd -la'
  alias lt='lsd --tree'
else
  alias ll='ls -l'
  alias la='ls -a'
fi

# cat -> bat
if command -v bat >/dev/null; then
  alias cat='bat --style=plain'
  alias catt='bat' # with header/grid
fi

# vim -> nvim
if command -v nvim >/dev/null; then
  alias vim='nvim'
  alias vi='nvim'
fi

# df -> duf
command -v duf >/dev/null && alias df='duf'

# lazygit
command -v lazygit >/dev/null && alias lg='lazygit'

# TheFuck
#eval $(thefuck --alias)
#eval $(thefuck --alias tf)

# zoxide (z / zi)
if command -v zoxide >/dev/null; then
  eval "$(zoxide init zsh --cmd cd)"
fi
  alias python="python3"

# Powerlevel10k config
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# fastfetch
if command -v fastfetch >/dev/null; then
  fastfetch
fi
