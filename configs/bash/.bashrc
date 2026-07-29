#!/usr/bin/env bash
# ~/.bashrc — Starship + fzf + fastfetch + zsh-parity

# Bail if shell is not interactive bash
if [ -n "$ZSH_VERSION" ] || [ -n "$FISH_VERSION" ] || [[ $- != *i* ]]; then
    return
fi

export PATH="$HOME/.local/bin:$HOME/bin:$HOME/.cargo/bin:$HOME/anaconda3/bin:$HOME/.nvm/versions/node/current/bin:$PATH"

# ================= ENV + UTILS + .ENV ====================
export EDITOR='nvim'
export TERM='xterm-256color'
export LANG='en_US.UTF-8'

extract() {
    for f in "$@"; do
        [[ ! -f "$f" ]] && echo "'$f' is not a file" && continue
        case "$f" in *.tar.bz2) tar xvjf "$f";; *.tar.gz) tar xvzf "$f";; *.zip) unzip "$f";; *.7z) 7z x "$f";;
                          *) echo "Unknown archive '$f'";;
        esac
    done
}

load_env() {
    local f="${1:-.env}"; [[ ! -f "$f" ]] && return
    while IFS='=' read -r k v || [[ -n $k ]]; do [[ $k =~ ^# ]]||[[ -z $k ]]&&continue
        v=$(echo "$v"|sed -e 's/^ *//;s/ *$//;s/^"//;s/"$//'); export "$k"="$v"
    done <"$f"
}
[[ -f "$HOME/.env" ]] && load_env "$HOME/.env"


# =============== ALIASES + QUALITY OF LIFE ==================
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -i'
alias mkdir='mkdir -pv'
alias ..='cd ..'
alias ...='cd ../..'
alias reload='source ~/.bashrc'

alias df='df -h'
alias free='free -h'
alias top='htop'

# Icons & aliases (ls replacement)
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
if command -v thefuck >/dev/null; then
  eval $(thefuck --alias)
  eval $(thefuck --alias fk)
fi

# ===================== TOOLS & PROMPT ========================

# Fastfetch
command -v fastfetch >/dev/null && [[ ${SHLVL:-1} -eq 1 ]] && [[ -z "$_FASTFETCH_SHOWN" ]] && {
    export _FASTFETCH_SHOWN=1
    fastfetch
}

# FZF
[[ -f "$HOME/.fzf.bash" ]] && source "$HOME/.fzf.bash"

command -v rg >/dev/null \
    && export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git/*" 2>/dev/null' \
    || export FZF_DEFAULT_COMMAND='find . -type f 2>/dev/null'

command -v bat >/dev/null \
    && export FZF_DEFAULT_OPTS="--preview 'bat --style=numbers --color=always --line-range :200 {}'" \
    || export FZF_DEFAULT_OPTS="--preview 'sed -n 1,200p {}'"

fzf_cd() { cd "$(fd -t d . 2>/dev/null || find . -type d | fzf)" || return; }
bind -x '"\C-o": fzf_cd'

_fzf_history_search() {
    local s=$(history | sed 's/^[ ]*[0-9]\+[ ]*//' | fzf --tac)
    [[ $s ]] && READLINE_LINE="$s" && READLINE_POINT=${#s}
}
bind -x '"\C-r": _fzf_history_search'

fzf_complete() {
    local L="${READLINE_LINE:0:READLINE_POINT}"
    local R="${READLINE_LINE:READLINE_POINT}"
    local W="${L##* }"
    local C=$(compgen -c | grep "^$W"; find . -type f -maxdepth 3 | sed 's|^\./||' | grep "^$W")
    local P=$(printf "%s\n" $C | fzf) || return
    L="${L%$W}$P"; READLINE_LINE="$L$R"; READLINE_POINT=${#L}
}
bind -x '"\C-]": fzf_complete'


# Starship (Must be at end)
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
if command -v starship >/dev/null; then
    eval "$(starship init bash)"
fi

# Zoxide (with cd replacement)
if command -v zoxide >/dev/null; then
    eval "$(zoxide init bash --cmd cd)"
fi
