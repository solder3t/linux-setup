#!/usr/bin/env bash
# ~/.bashrc — rotating theme prompts (TokyoNight, Nord, Dracula, Catppuccin) + fzf + fastfetch

# Bail if shell is not interactive bash
if [ -n "$ZSH_VERSION" ] || [ -n "$FISH_VERSION" ] || [[ $- != *i* ]]; then
    return
fi

export PATH="$HOME/.local/bin:$HOME/bin:$HOME/.cargo/bin:$HOME/anaconda3/bin:$HOME/.nvm/versions/node/current/bin:$PATH"

############################################################
# ========== RANDOM THEME ROTATION ON EACH TERMINAL ==========
############################################################
ESC="\e"

pick_theme() {
    local themes=(tokyonight nord dracula catppuccin)
    theme_index=$((RANDOM % ${#themes[@]}))

    case "${themes[$theme_index]}" in
        tokyonight)
            PROMPT_DECO_COLOR="\[${ESC}[38;2;86;95;137m\]"
            USER_COLOR="\[${ESC}[1;38;2;122;162;247m\]"
            HOST_COLOR="\[${ESC}[38;2;125;207;255m\]"
            PATH_COLOR="\[${ESC}[38;2;169;177;214m\]"
            GIT_COLOR="\[${ESC}[38;2;224;175;104m\]"
            ;;

        nord)
            PROMPT_DECO_COLOR="\[${ESC}[38;2;46;52;64m\]"
            USER_COLOR="\[${ESC}[1;38;2;129;161;193m\]"
            HOST_COLOR="\[${ESC}[38;2;136;192;208m\]"
            PATH_COLOR="\[${ESC}[38;2;143;188;187m\]"
            GIT_COLOR="\[${ESC}[38;2;235;203;139m\]"
            ;;

        dracula)
            PROMPT_DECO_COLOR="\[${ESC}[38;2;139;233;253m\]"
            USER_COLOR="\[${ESC}[1;38;2;255;121;198m\]"
            HOST_COLOR="\[${ESC}[38;2;189;147;249m\]"
            PATH_COLOR="\[${ESC}[38;2;248;248;242m\]"
            GIT_COLOR="\[${ESC}[38;2;241;250;140m\]"
            ;;

        catppuccin)
            PROMPT_DECO_COLOR="\[${ESC}[38;2;203;166;247m\]"
            USER_COLOR="\[${ESC}[1;38;2;137;180;250m\]"
            HOST_COLOR="\[${ESC}[38;2;245;194;231m\]"
            PATH_COLOR="\[${ESC}[38;2;137;220;235m\]"
            GIT_COLOR="\[${ESC}[38;2;249;226;175m\]"
            ;;
    esac

    RESET_COLOR="\[${ESC}[0m\]"
}

pick_theme  # 🎨 APPLY RANDOM THEME EACH SHELL
###############################################################


###############################################################
# =============== PROMPT (uses applied theme) =================
###############################################################
git_branch() { git rev-parse --abbrev-ref HEAD 2>/dev/null || return 1; }

git_dirty_flags() {
    local s out; s=$(git status --porcelain 2>/dev/null) || return 0
    out=""; [[ $(echo "$s" | grep -c '^\?\?') -gt 0 ]] && out+="?"
           [[ $(echo "$s" | grep -c '^ M')   -gt 0 ]] && out+="*"
           [[ $(echo "$s" | grep -E '^A |^M |^R |^C |^U') -gt 0 ]] && out+="+"
           [[ $(echo "$s" | grep -c '^ D')   -gt 0 ]] && out+="-"
    printf "%s" "$out"
}

git_segment() {
    local br=$(git_branch) || return 0
    local flags=$(git_dirty_flags)
    printf " ⎇ %s%s" "$br" "$flags"
}

__prompt_command() {
    local EXIT=$?
    local GIT=""
    git rev-parse --is-inside-work-tree &>/dev/null && GIT="${GIT_COLOR}$(git_segment)${RESET_COLOR}"
    PS1="${USER_COLOR}\u${RESET_COLOR}@${HOST_COLOR}\h ${PROMPT_DECO_COLOR}▸${PATH_COLOR} \w${RESET_COLOR}${GIT} "
    [[ $EXIT -ne 0 ]] && PS1+=" ${PROMPT_DECO_COLOR}⚡${RESET_COLOR} " || PS1+=" ${PROMPT_DECO_COLOR}>${RESET_COLOR} "
}
PROMPT_COMMAND=__prompt_command


###############################################################
# =============== ALIASES + QUALITY OF LIFE ==================
###############################################################
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -i'
alias mkdir='mkdir -pv'
alias ..='cd ..'
alias ...='cd ../..'
alias reload='source ~/.bashrc'

command -v exa >/dev/null && {
    alias ls='exa --color=always'
    alias ll='exa -lhgF --git --color=always'
} || {
    alias ls='ls --color=auto'
    alias ll='ls -lh'
}

alias df='df -h'
alias free='free -h'
alias top='htop'


###############################################################
# ================= ENV + UTILS + .ENV ========================
###############################################################
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


###############################################################
# ===================== FASTFETCH =============================
###############################################################
command -v fastfetch >/dev/null && [[ ${SHLVL:-1} -eq 1 ]] && fastfetch


###############################################################
# ======================= FZF + KEYS ==========================
###############################################################
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

# FZF tab-style completion on Ctrl+]
fzf_complete() {
    local L="${READLINE_LINE:0:READLINE_POINT}"
    local R="${READLINE_LINE:READLINE_POINT}"
    local W="${L##* }"
    local C=$(compgen -c | grep "^$W"; find . -type f -maxdepth 3 | sed 's|^\./||' | grep "^$W")
    local P=$(printf "%s\n" $C | fzf) || return
    L="${L%$W}$P"; READLINE_LINE="$L$R"; READLINE_POINT=${#L}
}
bind -x '"\C-]": fzf_complete'


###############################################################
# ====================== ZOXIDE ===============================
###############################################################
command -v zoxide >/dev/null && eval "$(zoxide init bash)"
