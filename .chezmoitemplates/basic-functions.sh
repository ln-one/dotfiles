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

# 系统信息 (简化版)
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