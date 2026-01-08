# -------------------------------------------------
# Powerlevel10k instant prompt (MUST BE AT TOP)
# -------------------------------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# -------------------------------------------------
# Oh My Zsh
# -------------------------------------------------
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

# -------------------------------------------------
# Android build environment
# -------------------------------------------------
#export USE_CCACHE=1
#export CCACHE_DIR="$HOME/.cache/ccache"

#export MAX_SOONG_JOBS=4
#export JOBS=12

#ulimit -n 1048576
#ulimit -u unlimited

# -------------------------------------------------
# Icons & aliases
# -------------------------------------------------
# -------------------------------------------------
# Icons & aliases
# -------------------------------------------------

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

# zoxide (z / zi)
if command -v zoxide >/dev/null; then
  eval "$(zoxide init zsh)"
fi

# -------------------------------------------------
# Powerlevel10k config
# -------------------------------------------------
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# --------------------------------------------------
# Post-init console output (safe for p10k)
# --------------------------------------------------
autoload -Uz add-zsh-hook
add-zsh-hook precmd () {
  # Run once per session
  if [[ -z "$_FASTFETCH_SHOWN" ]]; then
    export _FASTFETCH_SHOWN=1
    command -v fastfetch >/dev/null && fastfetch
  fi
}
