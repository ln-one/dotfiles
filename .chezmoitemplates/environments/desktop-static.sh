# ========================================
# 桌面环境静态配置
# ========================================
# 完全静态的桌面环境配置，无运行时检测
# 所有功能由中央功能配置决定

# ========================================
# 桌面环境变量
# ========================================

{{- if eq .chezmoi.os "linux" }}
# Linux 桌面环境变量
export XDG_CURRENT_DESKTOP="${XDG_CURRENT_DESKTOP:-GNOME}"
export XDG_SESSION_DESKTOP="${XDG_SESSION_DESKTOP:-gnome}"
export XDG_SESSION_TYPE="${XDG_SESSION_TYPE:-wayland}"
export DESKTOP_SESSION="${DESKTOP_SESSION:-gnome}"
export GDMSESSION="${GDMSESSION:-gnome}"
export APPLICATIONS_DIR="$HOME/.local/share/applications"
export DESKTOP_DIR="$HOME/Desktop"

{{- else if eq .chezmoi.os "darwin" }}
# macOS 桌面环境变量
export TERM_PROGRAM="${TERM_PROGRAM:-Terminal.app}"
export APPLICATIONS_DIR="/Applications"
{{- end }}

# GUI 应用偏好设置
export BROWSER="${BROWSER:-{{- if eq .chezmoi.os "linux" }}firefox{{- else }}Safari{{- end }}}"
export TERMINAL="${TERMINAL:-{{- if eq .chezmoi.os "linux" }}gnome-terminal{{- else }}Terminal{{- end }}}"

# 开发环境设置
export DEVELOPMENT_MODE="full"
export GUI_TOOLS_ENABLED="true"
export DEV_SERVER_HOST="localhost"
export DEV_SERVER_PORT="3000"

# ========================================
# 静态功能函数
# ========================================
# 基于功能标志的静态函数定义

# 应用启动器 (静态版本)
{{- if eq .chezmoi.os "linux" }}
launch_app() {
    local app="$1"
    nohup "$app" >/dev/null 2>&1 &
    disown
    echo "🚀 已启动: $app"
}
{{- else if eq .chezmoi.os "darwin" }}
launch_app() {
    local app="$1"
    open -a "$app"
    echo "🚀 已启动: $app"
}
{{- end }}

# 项目打开器
open_project() {
    local project_dir="$1"
    
    if [[ -z "$project_dir" ]]; then
        echo "用法: open_project <目录>"
        return 1
    fi
    
    if [[ ! -d "$project_dir" ]]; then
        echo "❌ 目录未找到: $project_dir"
        return 1
    fi
    
    cd "$project_dir" || return 1
    
{{- if or (eq .chezmoi.os "linux") (eq .chezmoi.os "darwin") }}
    # 在VS Code中打开项目 (如果功能启用)
    if [[ "$FEATURE_VSCODE" == "true" ]]; then
        code . &
        echo "📁 在VS Code中打开项目: $project_dir"
    fi
    
    # 打开文件管理器
  {{- if eq .chezmoi.os "linux" }}
    if [[ "$FEATURE_NAUTILUS" == "true" ]]; then
        nautilus . &
    elif [[ "$FEATURE_DOLPHIN" == "true" ]]; then
        dolphin . &
    fi
  {{- else if eq .chezmoi.os "darwin" }}
    open .
  {{- end }}
{{- end }}
}

# 桌面通知
send_notification() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"
    
{{- if eq .chezmoi.os "linux" }}
    if [[ "$FEATURE_NOTIFY" == "true" ]]; then
        notify-send -u "$urgency" "$title" "$message"
    else
        echo "🔔 $title: $message"
    fi
{{- else if eq .chezmoi.os "darwin" }}
    osascript -e "display notification \"$message\" with title \"$title\"" 2>/dev/null || echo "🔔 $title: $message"
{{- end }}
}

# 工作区创建器
create_workspace() {
    local workspace_name="$1"
    local base_dir="${WORKSPACE_DIR:-$HOME/Workspace}"
    
    if [[ -z "$workspace_name" ]]; then
        echo "用法: create_workspace <name>"
        return 1
    fi
    
    local workspace_path="$base_dir/$workspace_name"
    
    if [[ -d "$workspace_path" ]]; then
        echo "⚠️  工作区已存在: $workspace_path"
        open_project "$workspace_path"
        return 0
    fi
    
    mkdir -p "$workspace_path"
    cd "$workspace_path" || return 1
    
    # 初始化基础项目结构
    mkdir -p {src,docs,tests}
    touch README.md
    
    # 初始化git
    git init 2>/dev/null && {
        echo "# $workspace_name" > README.md
        git add README.md
        git commit -m "Initial commit"
    }
    
    # 在编辑器中打开
    if [[ "$FEATURE_VSCODE" == "true" ]]; then
        code .
    fi
    
    echo "✅ 已创建工作区: $workspace_path"
}

# 快速开发服务器
serve() {
    local port="${1:-8000}"
    local directory="${2:-.}"
    
    echo "🌐 在端口 $port 启动HTTP服务器..."
    echo "📁 服务目录: $(realpath "$directory")"
    echo "🔗 URL: http://localhost:$port"
    
    cd "$directory" && python3 -m http.server "$port" 2>/dev/null || {
        python -m SimpleHTTPServer "$port" 2>/dev/null || {
            echo "❌ Python HTTP服务器不可用"
            return 1
        }
    }
}

# ========================================
# 静态别名配置
# ========================================
# 基于功能标志的桌面特定别名

{{- if eq .chezmoi.os "linux" }}
# Linux桌面特定别名
alias sysmon='gnome-system-monitor 2>/dev/null || ksysguard 2>/dev/null || echo "系统监视器不可用"'
alias taskman='gnome-system-monitor 2>/dev/null || ksysguard 2>/dev/null || echo "任务管理器不可用"'
alias screenshot='gnome-screenshot 2>/dev/null || spectacle 2>/dev/null || flameshot gui 2>/dev/null || echo "截图工具不可用"'
alias ss='gnome-screenshot -a 2>/dev/null || spectacle -r 2>/dev/null || flameshot gui 2>/dev/null || echo "区域截图不可用"'
alias lock='gnome-screensaver-command -l 2>/dev/null || loginctl lock-session 2>/dev/null || echo "锁屏不可用"'

{{- else if eq .chezmoi.os "darwin" }}
# macOS桌面特定别名
alias sysmon='open -a "Activity Monitor"'
alias taskman='open -a "Activity Monitor"'
alias screenshot='screencapture'
alias ss='screencapture -s'
{{- end }}

# 通用桌面别名
alias workspace='create_workspace'
alias notify='send_notification'

# ========================================
# 功能函数导出
# ========================================

# 导出桌面函数
export -f open_project 2>/dev/null || true
export -f create_workspace 2>/dev/null || true
export -f send_notification 2>/dev/null || true
export -f serve 2>/dev/null || true
export -f launch_app 2>/dev/null || true
