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
alias ~='cd ~'
alias -- -='cd -'

# 创建父目录
alias mkdir='mkdir -pv'

# 安全操作
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# 磁盘使用
alias du='du -h'
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

# Git 简化
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'
alias glog='git log --oneline --graph --decorate'

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

# ========================================
# 目录跳转增强 (基于功能标志)
# ========================================

{{- if .features.enable_zoxide }}
# Zoxide 目录跳转别名 (静态配置)
alias j='z'
alias ji='zi'
{{- end }}

# ========================================
# 有用的函数
# ========================================

# 创建并进入目录
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# 提取各种压缩文件
extract() {
    if [ -f "$1" ]; then
        case $1 in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' 无法提取" ;;
        esac
    else
        echo "'$1' 不是有效文件"
    fi
}

# 查找文件
ff() {
    find . -name "*$1*" 2>/dev/null
}

# 备份文件
backup() {
    cp "$1"{,.bak}
}

# 端口占用查看
port() {
    if [ $# -eq 0 ]; then
        echo "用法: port <端口号>"
        return 1
    fi
    {{- if eq .chezmoi.os "linux" }}
    lsof -i :$1
    {{- else if eq .chezmoi.os "darwin" }}
    lsof -i :$1
    {{- end }}
}
