# ========================================
# 桌面系统集成配置
# ========================================
# 桌面环境的系统级功能和集成

# 剪贴板管理
{{- if eq .chezmoi.os "linux" }}
if command -v xclip >/dev/null 2>&1; then
    alias pbcopy='xclip -selection clipboard'
    alias pbpaste='xclip -selection clipboard -o'
elif command -v xsel >/dev/null 2>&1; then
    alias pbcopy='xsel --clipboard --input'
    alias pbpaste='xsel --clipboard --output'
elif command -v wl-copy >/dev/null 2>&1; then
    # Wayland剪贴板
    alias pbcopy='wl-copy'
    alias pbpaste='wl-paste'
fi
{{- end }}

# 桌面通知
send_notification() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"
    
    {{- if eq .chezmoi.os "linux" }}
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -u "$urgency" "$title" "$message"
    else
        echo "🔔 $title: $message"
    fi
    {{- else if eq .chezmoi.os "darwin" }}
    if command -v osascript >/dev/null 2>&1; then
        osascript -e "display notification \"$message\" with title \"$title\""
    else
        echo "🔔 $title: $message"
    fi
    {{- end }}
}

# 桌面会话管理
{{- if eq .chezmoi.os "linux" }}
# GNOME会话管理
if command -v gnome-session-quit >/dev/null 2>&1; then
    alias logout='gnome-session-quit --logout'
    alias reboot='gnome-session-quit --reboot'
    alias shutdown='gnome-session-quit --power-off'
fi

# 锁屏
if command -v gnome-screensaver-command >/dev/null 2>&1; then
    alias lock='gnome-screensaver-command -l'
elif command -v loginctl >/dev/null 2>&1; then
    alias lock='loginctl lock-session'
fi
{{- end }}

# 快速开发服务器
serve() {
    local port="${1:-8000}"
    local directory="${2:-.}"
    
    if command -v python3 >/dev/null 2>&1; then
        echo "🌐 在端口 $port 启动HTTP服务器..."
        echo "📁 服务目录: $(realpath "$directory")"
        echo "🔗 URL: http://localhost:$port"
        cd "$directory" && python3 -m http.server "$port"
    elif command -v python >/dev/null 2>&1; then
        echo "🌐 在端口 $port 启动HTTP服务器..."
        cd "$directory" && python -m SimpleHTTPServer "$port"
    else
        echo "❌ Python不可用，无法启动HTTP服务器"
        return 1
    fi
}

# 工作区管理
create_workspace() {
    local workspace_name="$1"
    local base_dir="${WORKSPACE_DIR:-$HOME/Workspace}"
    
    if [[ -z "$workspace_name" ]]; then
        echo "用法: create_workspace <名称>"
        return 1
    fi
    
    local workspace_path="$base_dir/$workspace_name"
    
    if [[ -d "$workspace_path" ]]; then
        echo "⚠️ 工作区已存在: $workspace_path"
        open_project "$workspace_path"
        return 0
    fi
    
    mkdir -p "$workspace_path"
    cd "$workspace_path" || return 1
    
    # 初始化基本项目结构
    mkdir -p {src,docs,tests}
    touch README.md
    
    # 如果可用，初始化git
    if command -v git >/dev/null 2>&1; then
        git init
        echo "# $workspace_name" > README.md
        git add README.md
        git commit -m "Initial commit"
    fi
    
    # 在编辑器中打开
    if command -v code >/dev/null 2>&1; then
        code .
    fi
    
    echo "✅ 已创建工作区: $workspace_path"
}

# 桌面环境验证
validate_desktop_environment() {
    echo "🖥️ 桌面环境验证:"
    echo ""
    
    # 显示服务器检查
    if [[ -n "${DISPLAY:-}" ]]; then
        echo "✅ X11 显示: $DISPLAY"
    elif [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
        echo "✅ Wayland 显示: $WAYLAND_DISPLAY"
    {{- if eq .chezmoi.os "darwin" }}
    elif [[ "$(uname -s)" == "Darwin" ]]; then
        echo "✅ macOS 桌面环境"
    {{- end }}
    else
        echo "⚠️ 未检测到显示服务器"
    fi
    
    # GUI工具可用性
    local gui_tools=()
    {{- if eq .chezmoi.os "linux" }}
    gui_tools=("nautilus" "gnome-terminal" "firefox" "code" "git-cola")
    {{- else if eq .chezmoi.os "darwin" }}
    gui_tools=("open" "code" "git")
    {{- end }}
    
    echo ""
    echo "🛠️ GUI工具状态:"
    for tool in "${gui_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "  ✅ $tool"
        else
            echo "  ❌ $tool (未安装)"
        fi
    done
    
    # 开发环境检查
    echo ""
    echo "💻 开发环境:"
    echo "  编辑器: ${EDITOR:-未设置}"
    echo "  浏览器: ${BROWSER:-未设置}"
    echo "  终端: ${TERMINAL:-未设置}"
    
    # 桌面集成功能
    echo ""
    echo "🔧 桌面集成:"
    {{- if eq .chezmoi.os "linux" }}
    if command -v notify-send >/dev/null 2>&1; then
        echo "  ✅ 桌面通知"
    else
        echo "  ❌ 桌面通知 (notify-send不可用)"
    fi
    
    if command -v xclip >/dev/null 2>&1 || command -v xsel >/dev/null 2>&1 || command -v wl-copy >/dev/null 2>&1; then
        echo "  ✅ 剪贴板集成"
    else
        echo "  ❌ 剪贴板集成 (无可用剪贴板工具)"
    fi
    {{- else if eq .chezmoi.os "darwin" }}
    if command -v osascript >/dev/null 2>&1; then
        echo "  ✅ 桌面通知"
        echo "  ✅ 剪贴板集成"
    else
        echo "  ❌ AppleScript不可用"
    fi
    {{- end }}
}

# 别名设置
alias workspace='create_workspace'
alias notify='send_notification'
alias validate-desktop='validate_desktop_environment'
