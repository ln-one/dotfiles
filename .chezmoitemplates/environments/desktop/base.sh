# ========================================
# 桌面环境基础设置
# ========================================
# 桌面环境的核心配置和环境变量

# 桌面模式指示器
export DEVELOPMENT_MODE="full"
export GUI_TOOLS_ENABLED="true"

# GUI应用程序偏好设置
export BROWSER="${BROWSER:-firefox}"
export TERMINAL="${TERMINAL:-gnome-terminal}"

{{- if eq .chezmoi.os "linux" }}
# Linux桌面环境变量
export XDG_CURRENT_DESKTOP="${XDG_CURRENT_DESKTOP:-GNOME}"
export XDG_SESSION_DESKTOP="${XDG_SESSION_DESKTOP:-gnome}"
export XDG_SESSION_TYPE="${XDG_SESSION_TYPE:-wayland}"

# 桌面集成路径
export DESKTOP_SESSION="${DESKTOP_SESSION:-gnome}"
export GDMSESSION="${GDMSESSION:-gnome}"

# 应用程序目录
export APPLICATIONS_DIR="$HOME/.local/share/applications"
export DESKTOP_DIR="$HOME/Desktop"

{{- else if eq .chezmoi.os "darwin" }}
# macOS桌面环境变量
export TERM_PROGRAM="${TERM_PROGRAM:-Terminal.app}"

# macOS应用程序路径
export APPLICATIONS_DIR="/Applications"
{{- end }}

# IDE和编辑器偏好（桌面优先级）
if command -v code >/dev/null 2>&1; then
    export EDITOR="code --wait"
    export VISUAL="code --wait"
    export GIT_EDITOR="code --wait"
elif command -v nvim >/dev/null 2>&1; then
    export EDITOR="nvim"
    export VISUAL="nvim"
    export GIT_EDITOR="nvim"
fi

# 开发服务器默认值
export DEV_SERVER_HOST="localhost"
export DEV_SERVER_PORT="3000"
