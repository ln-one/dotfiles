# ========================================
# Basic Utility Functions
# ========================================
# 基础实用函数模块

# 创建目录并进入
mkcd() {
    if [[ -z "$1" ]]; then
        echo "用法: mkcd <目录名>"
        return 1
    fi
    mkdir -p "$1" && cd "$1"
    echo "✅ 创建并进入目录: $1"
}

# 提取各种压缩文件 - 使用现有工具
{{- if .features.enable_atool }}
# 使用atool - 专业的压缩文件处理工具
alias extract='atool --extract --subdir'
alias compress='apack'
{{- else }}
# 备用的简单提取函数
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
{{- end }}

# 系统信息 (简化版) - 仅在非远程环境中定义
{{- if ne .environment "remote" }}
sysinfo() {
    echo "=== System Information ==="
    echo "OS: {{ .chezmoi.os }}"
    echo "Architecture: {{ .chezmoi.arch }}"
    echo "Hostname: {{ .chezmoi.hostname }}"
    echo "Shell: $SHELL"
    echo "User: $USER"
    echo "Home: $HOME"
    echo "PWD: $PWD"
    echo "=========================="
}
{{- end }}