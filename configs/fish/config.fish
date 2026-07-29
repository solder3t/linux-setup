set -g fish_greeting

# =============================================================================
# Icons & Aliases
# =============================================================================
alias apt='nala'
alias python="python3"

# ls replacement (eza > lsd > ls)
# 'command -v' translates to 'type -q' (quiet) in fish
if type -q eza
    alias ls='eza --icons'
    alias ll='eza --icons -l'
    alias la='eza --icons -la'
    alias lt='eza --icons --tree'
else if type -q lsd
    alias ls='lsd'
    alias ll='lsd -l'
    alias la='lsd -a'
    alias lla='lsd -la'
    alias lt='lsd --tree'
else
    alias ll='ls -l'
    alias la='ls -a'
end

# df -> duf
if type -q duf
    alias df='duf'
end

# lazygit
if type -q lazygit
    alias lg='lazygit'
end

# =============================================================================
# Git Aliases
# =============================================================================
alias gc='git clone'
alias ga='git add'
alias gac='git add . && git commit -m "update"'
alias gb='git branch'
alias gcd='git checkout develop'
alias gck='git checkout'
alias gcm='git checkout master'
alias gd='git diff'
alias gds='git diff --staged'
alias gdw='git diff --word-diff'
alias gdws='git diff --word-diff --staged'
alias gsh='git show'
alias gst='git status'

# =============================================================================
# Tool Integrations
# =============================================================================

# zoxide (z / zi)
if type -q zoxide
    zoxide init fish --cmd cd | source
end

# =============================================================================
# Interactive Session Initialization
# =============================================================================
if status is-interactive
    if type -q fastfetch
        fastfetch
    end

    # Starship
    if type -q starship
        starship init fish | source
    end
end
