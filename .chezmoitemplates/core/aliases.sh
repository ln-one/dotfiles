# ========================================
# 别名配置模板
# ========================================
# 现代化的命令别名，支持图标和颜色

# 使用 Homebrew 安装的现代化工具
{{- if or (stat "/opt/homebrew") (stat "/home/linuxbrew/.linuxbrew") }}
# 使用 eza (通过 Homebrew 安装)
alias ls='$HOMEBREW_PREFIX/bin/eza --color=auto --icons'
alias ll='$HOMEBREW_PREFIX/bin/eza -alF --color=auto --icons --git'
alias la='$HOMEBREW_PREFIX/bin/eza -a --color=auto --icons'
alias l='$HOMEBREW_PREFIX/bin/eza -F --color=auto --icons'
alias tree='$HOMEBREW_PREFIX/bin/eza --tree --color=auto --icons'
{{- else }}
# 检查可用的 ls 替代工具
if command -v eza &> /dev/null; then
    # 使用 eza (exa 的现代替代品)
    alias ls='eza --color=auto --icons'
    alias ll='eza -alF --color=auto --icons --git'
    alias la='eza -a --color=auto --icons'
    alias l='eza -F --color=auto --icons'
    alias tree='eza --tree --color=auto --icons'
elif command -v exa &> /dev/null; then
    # 使用 exa
    alias ls='exa --color=auto --icons'
    alias ll='exa -alF --color=auto --icons --git'
    alias la='exa -a --color=auto --icons'
    alias l='exa -F --color=auto --icons'
    alias tree='exa --tree --color=auto --icons'
else
    # 回退到传统 ls
    alias ls='ls --color=auto'
    alias ll='ls -alF --color=auto'
    alias la='ls -A --color=auto'
    alias l='ls -CF --color=auto'
fi
{{- end }}

# 目录导航
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git 别名
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'

# 实用工具 - 使用 Homebrew 标准命令名
{{- if or (stat "/opt/homebrew") (stat "/home/linuxbrew/.linuxbrew") }}
# 使用 Homebrew 安装的现代化工具
alias cat='$HOMEBREW_PREFIX/bin/bat'
alias find='$HOMEBREW_PREFIX/bin/fd'
alias grep='$HOMEBREW_PREFIX/bin/rg'
{{- end }}
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'

# 安全别名
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

{{- if .features.enable_zoxide }}
# Zoxide 别名 - 仅在zoxide已安装时启用
if command -v zoxide >/dev/null 2>&1; then
    alias cd='z'
fi
{{- end }}