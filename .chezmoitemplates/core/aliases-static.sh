# ========================================
# 通用别名定义 (完全静态版本)
# ========================================
# 基于功能标志的静态别名，无运行时检测

# ========================================
# 文件和目录操作 (基于功能标志和工具偏好)
# ========================================

{{- $ls_tool := .preferences.ls_tool | default "ls" }}
{{- if eq $ls_tool "eza" }}
# Eza 别名 (静态配置)
alias ls='eza --color=auto --icons'
alias ll='eza -alF --color=auto --icons --git'
alias la='eza -a --color=auto --icons'
alias l='eza -F --color=auto --icons'
alias tree='eza --tree --color=auto --icons'
{{- else if eq $ls_tool "exa" }}
# Exa 别名 (静态配置)
alias ls='exa --color=auto --icons'
alias ll='exa -alF --color=auto --icons --git'
alias la='exa -a --color=auto --icons'
alias l='exa -F --color=auto --icons'
alias tree='exa --tree --color=auto --icons'
{{- else }}
# 传统 ls 别名
{{- if eq .chezmoi.os "linux" }}
alias ls='ls --color=auto'
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
{{- else if eq .chezmoi.os "darwin" }}
alias ls='ls -G'
alias ll='ls -alFG'
alias la='ls -AG'
alias l='ls -CFG'
{{- end }}
{{- end }}

# 目录操作
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# 创建父目录
alias mkdir='mkdir -pv'

# 安全操作
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# 磁盘使用
alias df='df -h'

# 进程查看
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias psgrep='ps aux | grep -v grep | grep'

# ========================================
# 网络和系统
# ========================================

# 网络
alias ping='ping -c 5'
alias ports='netstat -tulanp'

# 系统信息
{{- if eq .chezmoi.os "linux" }}
alias meminfo='free -m -l -t'
alias cpuinfo='lscpu'
{{- else if eq .chezmoi.os "darwin" }}
alias meminfo='vm_stat'
alias cpuinfo='sysctl -n machdep.cpu.brand_string'
{{- end }}

# ========================================
# 开发相关
# ========================================


# Docker 简化 (基于功能标志)
{{- if eq .environment "desktop" }}
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs -f'
{{- end }}

# ========================================
# 快捷操作
# ========================================

# 快速编辑常用文件
alias zshrc='$EDITOR ~/.zshrc'
alias bashrc='$EDITOR ~/.bashrc'
alias vimrc='$EDITOR ~/.vimrc'

# 重新加载配置
alias reload='source ~/.zshrc'
alias src='source ~/.zshrc'

# 清屏
alias c='clear'
alias cls='clear'

# 历史查找
alias h='history'
alias hg='history | grep'

# ========================================
# 平台特定别名
# ========================================

{{- if eq .chezmoi.os "darwin" }}
# macOS 特定别名
alias finder='open -a Finder .'
alias preview='open -a Preview'
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'

{{- else if eq .chezmoi.os "linux" }}
# Linux 特定别名
alias apt-update='sudo apt update && sudo apt upgrade'
alias apt-install='sudo apt install'
alias apt-search='apt search'
alias service='sudo systemctl'
alias journal='sudo journalctl'
{{- end }}