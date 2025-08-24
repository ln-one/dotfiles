# ========================================
# Simplified Aliases Template
# ========================================
# Chezmoi-managed aliases with only essential functionality

# ========================================
# Essential File Operations (ls/ll/la only)
# ========================================

{{- if lookPath "eza" }}
# Use eza as modern ls replacement
alias ls='eza --icons'
alias ll='eza --icons -l'
alias la='eza --icons -la'
{{- else if lookPath "exa" }}
# Use exa as ls replacement
alias ls='exa --icons'
alias ll='exa --icons -l'
alias la='exa --icons -la'
{{- else }}
# Use system default ls with colors
{{- if eq .chezmoi.os "linux" }}
alias ls='ls --color=auto'
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
{{- else if eq .chezmoi.os "darwin" }}
alias ls='ls -G'
alias ll='ls -alF -G'
alias la='ls -A -G'
{{- end }}
{{- end }}

# ========================================
# Quick Navigation
# ========================================

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# ========================================
# Safe File Operations
# ========================================

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias mkdir='mkdir -p'