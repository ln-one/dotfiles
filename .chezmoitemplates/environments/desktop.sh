# ========================================
# Desktop Environment Configuration
# ========================================
# Complete desktop environment setup with full GUI tools and development features
# Requirements: 3.1 - Desktop environment with complete development tools and GUI functionality

# ========================================
# Desktop Environment Configuration (Static)
# ========================================
# 桌面环境配置 - 由 chezmoi 静态编译，无运行时检测

# ========================================
# Desktop-Specific Environment Variables
# ========================================

# GUI Application Preferences
export BROWSER="${BROWSER:-firefox}"
export TERMINAL="${TERMINAL:-gnome-terminal}"

{{- if eq .chezmoi.os "linux" }}
# Linux Desktop Environment Variables
export XDG_CURRENT_DESKTOP="${XDG_CURRENT_DESKTOP:-GNOME}"
export XDG_SESSION_DESKTOP="${XDG_SESSION_DESKTOP:-gnome}"
export XDG_SESSION_TYPE="${XDG_SESSION_TYPE:-wayland}"

# Desktop Integration Paths
export DESKTOP_SESSION="${DESKTOP_SESSION:-gnome}"
export GDMSESSION="${GDMSESSION:-gnome}"

# Application Directories
export APPLICATIONS_DIR="$HOME/.local/share/applications"
export DESKTOP_DIR="$HOME/Desktop"

{{- else if eq .chezmoi.os "darwin" }}
# macOS Desktop Environment Variables
export TERM_PROGRAM="${TERM_PROGRAM:-Terminal.app}"

# macOS Application Paths
export APPLICATIONS_DIR="/Applications"
{{- end }}

# ========================================
# Development Tools Configuration
# ========================================

# Enhanced Development Environment
export DEVELOPMENT_MODE="full"
export GUI_TOOLS_ENABLED="true"

# IDE and Editor Preferences (Desktop Priority)
if command -v code >/dev/null 2>&1; then
    export EDITOR="code --wait"
    export VISUAL="code --wait"
    export GIT_EDITOR="code --wait"
elif command -v nvim >/dev/null 2>&1; then
    export EDITOR="nvim"
    export VISUAL="nvim"
    export GIT_EDITOR="nvim"
fi

# Development Server Defaults
export DEV_SERVER_HOST="localhost"
export DEV_SERVER_PORT="3000"

# Docker Desktop Integration
{{- if eq .chezmoi.os "darwin" }}
if [[ -d "/Applications/Docker.app" ]]; then
    export DOCKER_HOST="unix://$HOME/.docker/run/docker.sock"
fi
{{- else if eq .chezmoi.os "linux" }}
# Linux Docker configuration
# Note: Add user to docker group if needed: sudo usermod -aG docker $USER
{{- end }}

# ========================================
# GUI Tool Aliases and Functions
# ========================================

# File Manager Aliases
if command -v nautilus >/dev/null 2>&1; then
    alias fm='nautilus'
    alias files='nautilus'
elif command -v dolphin >/dev/null 2>&1; then
    alias fm='dolphin'
    alias files='dolphin'
{{- if eq .chezmoi.os "darwin" }}
elif command -v open >/dev/null 2>&1; then
    alias fm='open'
    alias files='open'
{{- end }}
fi

# Text Editor Shortcuts
if command -v code >/dev/null 2>&1; then
    alias edit='code'
    alias c='code .'
    alias code.='code .'
fi

# System Monitor Shortcuts
{{- if eq .chezmoi.os "linux" }}
if command -v gnome-system-monitor >/dev/null 2>&1; then
    alias sysmon='gnome-system-monitor'
    alias taskman='gnome-system-monitor'
elif command -v ksysguard >/dev/null 2>&1; then
    alias sysmon='ksysguard'
    alias taskman='ksysguard'
fi
{{- else if eq .chezmoi.os "darwin" }}
alias sysmon='open -a "Activity Monitor"'
alias taskman='open -a "Activity Monitor"'
{{- end }}

# Screenshot Utilities
{{- if eq .chezmoi.os "linux" }}
if command -v gnome-screenshot >/dev/null 2>&1; then
    alias screenshot='gnome-screenshot'
    alias ss='gnome-screenshot -a'  # Area screenshot
elif command -v spectacle >/dev/null 2>&1; then
    alias screenshot='spectacle'
    alias ss='spectacle -r'  # Region screenshot
elif command -v flameshot >/dev/null 2>&1; then
    alias screenshot='flameshot gui'
    alias ss='flameshot gui'
fi
{{- else if eq .chezmoi.os "darwin" }}
alias screenshot='screencapture'
alias ss='screencapture -s'  # Selection screenshot
{{- end }}

# ========================================
# Desktop Application Launchers
# ========================================

# Quick Application Launchers
{{- if eq .chezmoi.os "linux" }}
# Linux Application Launchers
launch_app() {
    local app="$1"
    if command -v "$app" >/dev/null 2>&1; then
        nohup "$app" >/dev/null 2>&1 &
        disown
        echo "🚀 Launched: $app"
    else
        echo "❌ Application not found: $app"
        return 1
    fi
}

# Common Linux Applications
if command -v firefox >/dev/null 2>&1; then
    alias browser='launch_app firefox'
fi

if command -v thunderbird >/dev/null 2>&1; then
    alias mail='launch_app thunderbird'
fi

if command -v libreoffice >/dev/null 2>&1; then
    alias office='launch_app libreoffice'
fi

{{- else if eq .chezmoi.os "darwin" }}
# macOS Application Launchers
launch_app() {
    local app="$1"
    if [[ -d "/Applications/$app.app" ]]; then
        open -a "$app"
        echo "🚀 Launched: $app"
    else
        echo "❌ Application not found: $app"
        return 1
    fi
}

# Common macOS Applications
alias browser='open -a "Firefox" || open -a "Safari"'
alias mail='open -a "Mail"'
alias office='open -a "Microsoft Word" || open -a "Pages"'
{{- end }}

# ========================================
# Desktop Productivity Functions
# ========================================

# Quick Project Opener
open_project() {
    local project_dir="$1"
    
    if [[ -z "$project_dir" ]]; then
        echo "Usage: open_project <directory>"
        return 1
    fi
    
    if [[ ! -d "$project_dir" ]]; then
        echo "❌ Directory not found: $project_dir"
        return 1
    fi
    
    cd "$project_dir" || return 1
    
    # Open in VS Code if available
    if command -v code >/dev/null 2>&1; then
        code .
        echo "🚀 Opened project in VS Code: $project_dir"
    else
        echo "📁 Changed to project directory: $project_dir"
    fi
}

# Workspace Management
create_workspace() {
    local workspace_name="$1"
    local base_dir="${WORKSPACE_DIR:-$HOME/Workspace}"
    
    if [[ -z "$workspace_name" ]]; then
        echo "Usage: create_workspace <name>"
        return 1
    fi
    
    local workspace_path="$base_dir/$workspace_name"
    
    if [[ -d "$workspace_path" ]]; then
        echo "⚠️  Workspace already exists: $workspace_path"
        open_project "$workspace_path"
        return 0
    fi
    
    mkdir -p "$workspace_path"
    cd "$workspace_path" || return 1
    
    # Initialize basic project structure
    mkdir -p {src,docs,tests}
    touch README.md
    
    # Initialize git if available
    if command -v git >/dev/null 2>&1; then
        git init
        echo "# $workspace_name" > README.md
        git add README.md
        git commit -m "Initial commit"
    fi
    
    # Open in editor
    if command -v code >/dev/null 2>&1; then
        code .
    fi
    
    echo "✅ Created workspace: $workspace_path"
}

# ========================================
# Desktop System Integration
# ========================================

# Clipboard Management
{{- if eq .chezmoi.os "linux" }}
if command -v xclip >/dev/null 2>&1; then
    alias pbcopy='xclip -selection clipboard'
    alias pbpaste='xclip -selection clipboard -o'
elif command -v xsel >/dev/null 2>&1; then
    alias pbcopy='xsel --clipboard --input'
    alias pbpaste='xsel --clipboard --output'
elif command -v wl-copy >/dev/null 2>&1; then
    # Wayland clipboard
    alias pbcopy='wl-copy'
    alias pbpaste='wl-paste'
fi
{{- end }}

# Desktop Notifications
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

# Desktop Session Management
{{- if eq .chezmoi.os "linux" }}
# GNOME Session Management
if command -v gnome-session-quit >/dev/null 2>&1; then
    alias logout='gnome-session-quit --logout'
    alias reboot='gnome-session-quit --reboot'
    alias shutdown='gnome-session-quit --power-off'
fi

# Lock Screen
if command -v gnome-screensaver-command >/dev/null 2>&1; then
    alias lock='gnome-screensaver-command -l'
elif command -v loginctl >/dev/null 2>&1; then
    alias lock='loginctl lock-session'
fi
{{- end }}

# ========================================
# Desktop Development Shortcuts
# ========================================

# Quick Development Server
serve() {
    local port="${1:-8000}"
    local directory="${2:-.}"
    
    if command -v python3 >/dev/null 2>&1; then
        echo "🌐 Starting HTTP server on port $port..."
        echo "📁 Serving directory: $(realpath "$directory")"
        echo "🔗 URL: http://localhost:$port"
        cd "$directory" && python3 -m http.server "$port"
    elif command -v python >/dev/null 2>&1; then
        echo "🌐 Starting HTTP server on port $port..."
        cd "$directory" && python -m SimpleHTTPServer "$port"
    else
        echo "❌ Python not available for HTTP server"
        return 1
    fi
}

# Git GUI Integration
if command -v git >/dev/null 2>&1; then
    # Git GUI shortcuts
    {{- if eq .chezmoi.os "linux" }}
    if command -v gitk >/dev/null 2>&1; then
        alias gitgui='gitk --all &'
    fi
    
    if command -v git-cola >/dev/null 2>&1; then
        alias gitcola='git-cola &'
    fi
    {{- else if eq .chezmoi.os "darwin" }}
    if command -v gitk >/dev/null 2>&1; then
        alias gitgui='gitk --all &'
    fi
    
    # SourceTree integration
    if [[ -d "/Applications/Sourcetree.app" ]]; then
        alias sourcetree='open -a Sourcetree'
    fi
    {{- end }}
fi

# ========================================
# Desktop Environment Validation
# ========================================

# Validate desktop environment setup
validate_desktop_environment() {
    echo "🖥️  Desktop Environment Validation:"
    echo ""
    
    # Display server check
    if [[ -n "${DISPLAY:-}" ]]; then
        echo "✅ X11 Display: $DISPLAY"
    elif [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
        echo "✅ Wayland Display: $WAYLAND_DISPLAY"
    {{- if eq .chezmoi.os "darwin" }}
    elif [[ "$(uname -s)" == "Darwin" ]]; then
        echo "✅ macOS Desktop Environment"
    {{- end }}
    else
        echo "⚠️  No display server detected"
    fi
    
    # GUI tools availability
    local gui_tools=()
    {{- if eq .chezmoi.os "linux" }}
    gui_tools=("nautilus" "gnome-terminal" "firefox" "code" "git-cola")
    {{- else if eq .chezmoi.os "darwin" }}
    gui_tools=("open" "code" "git")
    {{- end }}
    
    echo ""
    echo "🛠️  GUI Tools Status:"
    for tool in "${gui_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "  ✅ $tool"
        else
            echo "  ❌ $tool (not installed)"
        fi
    done
    
    # Development environment check
    echo ""
    echo "💻 Development Environment:"
    echo "  Editor: ${EDITOR:-not set}"
    echo "  Browser: ${BROWSER:-not set}"
    echo "  Terminal: ${TERMINAL:-not set}"
    
    # Desktop integration features
    echo ""
    echo "🔧 Desktop Integration:"
    {{- if eq .chezmoi.os "linux" }}
    if command -v notify-send >/dev/null 2>&1; then
        echo "  ✅ Desktop Notifications"
    else
        echo "  ❌ Desktop Notifications (notify-send not available)"
    fi
    
    if command -v xclip >/dev/null 2>&1 || command -v xsel >/dev/null 2>&1 || command -v wl-copy >/dev/null 2>&1; then
        echo "  ✅ Clipboard Integration"
    else
        echo "  ❌ Clipboard Integration (no clipboard tool available)"
    fi
    {{- else if eq .chezmoi.os "darwin" }}
    if command -v osascript >/dev/null 2>&1; then
        echo "  ✅ Desktop Notifications"
        echo "  ✅ Clipboard Integration"
    else
        echo "  ❌ AppleScript not available"
    fi
    {{- end }}
}

# Export desktop functions (with error handling)
declare -f open_project >/dev/null 2>&1 && export -f open_project 2>/dev/null || true
declare -f create_workspace >/dev/null 2>&1 && export -f create_workspace 2>/dev/null || true
declare -f send_notification >/dev/null 2>&1 && export -f send_notification 2>/dev/null || true
declare -f serve >/dev/null 2>&1 && export -f serve 2>/dev/null || true
declare -f validate_desktop_environment >/dev/null 2>&1 && export -f validate_desktop_environment 2>/dev/null || true
{{- if eq .chezmoi.os "linux" }}
declare -f launch_app >/dev/null 2>&1 && export -f launch_app 2>/dev/null || true
{{- end }}

# ========================================
# Desktop Environment Initialization
# ========================================

# Set up desktop-specific aliases and functions
alias workspace='create_workspace'
alias notify='send_notification'
alias validate-desktop='validate_desktop_environment'

# Desktop environment configuration loaded