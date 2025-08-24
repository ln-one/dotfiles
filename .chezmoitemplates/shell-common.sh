# ========================================
# 共享 Shell 配置模板 (模块化设计)
# ========================================
# 这个文件作为模块加载器，按需加载各个功能模块
# 由 Chezmoi 模板系统管理

{{/* 基础环境变量 */}}
# ========================================
# 基础环境变量
# ========================================
export EDITOR="{{ .preferences.editor | default "vim" }}"
export VISUAL="$EDITOR"
export PAGER="less"

# 颜色支持
export CLICOLOR=1
{{- if eq .chezmoi.os "linux" }}
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
{{- else if eq .chezmoi.os "darwin" }}
export LSCOLORS=ExFxCxDxBxegedabagacad
{{- end }}

# 语言和编码
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

{{/* 模块化加载各个功能 */}}
# ========================================
# 模块化功能加载
# ========================================

# 加载核心别名模块
{{ includeTemplate "aliases.sh" . }}

# 加载基础函数模块
{{ includeTemplate "basic-functions.sh" . }}

# 加载代理管理模块 (仅 Linux 桌面)
{{ includeTemplate "proxy-functions.sh" . }}

# 加载主题管理模块 (仅 Linux 桌面)
{{ includeTemplate "theme-functions.sh" . }}

# ========================================
# 基础实用函数 (保留核心功能)
# ========================================

# 创建目录并进入
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# 系统信息 (简化版)
sysinfo() {
    echo "=== System Information ==="
    echo "OS: {{ .chezmoi.os }}"
    echo "Architecture: {{ .chezmoi.arch }}"
    echo "Hostname: {{ .chezmoi.hostname }}"
    echo "Shell: $SHELL"
    echo "User: $USER"
    echo "=========================="
}
