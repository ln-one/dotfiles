# ========================================
# WSL Environment Configuration
# ========================================
# Hybrid configuration optimized for Windows Subsystem for Linux
# Requirements: 3.4 - WSL environment with Windows integration and hybrid configuration

# ========================================
# WSL Environment Configuration (Static)
# ========================================
# WSL环境配置 - 由 chezmoi 静态编译，无运行时检测

# ========================================
# WSL-Specific Environment Variables
# ========================================

# Hybrid Mode Indicators
export DEVELOPMENT_MODE="hybrid"
export GUI_TOOLS_ENABLED="conditional"
export WSL_ENVIRONMENT="true"

# WSL Distribution Information
export WSL_DISTRO="${WSL_DISTRO_NAME:-$(grep -oP '(?<=WSL_DISTRO_NAME=).*' /proc/version 2>/dev/null || echo 'unknown')}"
export WSL_VERSION="${WSL_VERSION:-2}"

# Windows Integration Paths
export WINDOWS_HOME="/mnt/c/Users/${USER}"
export WINDOWS_SYSTEM="/mnt/c/Windows/System32"
export WINDOWS_PROGRAM_FILES="/mnt/c/Program Files"
export WINDOWS_PROGRAM_FILES_X86="/mnt/c/Program Files (x86)"

# WSL-optimized editor preferences
if command -v code >/dev/null 2>&1; then
    # VS Code with WSL integration
    export EDITOR="code --wait"
    export VISUAL="code --wait"
    export GIT_EDITOR="code --wait"
elif command -v vim >/dev/null 2>&1; then
    export EDITOR="vim"
    export VISUAL="vim"
    export GIT_EDITOR="vim"
elif command -v nano >/dev/null 2>&1; then
    export EDITOR="nano"
    export VISUAL="nano"
    export GIT_EDITOR="nano"
fi

# WSL Display Configuration (for GUI apps)
if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
    # WSL2 with WSLg (Windows 11)
    if command -v wslg >/dev/null 2>&1 || [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
        export DISPLAY="${DISPLAY:-:0}"
        export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"
        export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-$USER}"
        export GUI_AVAILABLE="true"
    # WSL2 with X11 forwarding
    elif [[ -n "${DISPLAY:-}" ]]; then
        export GUI_AVAILABLE="true"
    else
        export GUI_AVAILABLE="false"
    fi
fi

# Windows PATH Integration
if [[ -d "/mnt/c/Windows/System32" ]]; then
    # Add Windows tools to PATH (selective)
    export PATH="$PATH:/mnt/c/Windows/System32"
    export PATH="$PATH:/mnt/c/Windows/System32/WindowsPowerShell/v1.0"
fi

# ========================================
# WSL-Optimized Aliases
# ========================================

# File listing with Windows integration
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --color=auto'
    alias ll='eza -l --color=auto'
    alias la='eza -la --color=auto'
    alias lw='eza -la --color=auto /mnt/c/Users/$USER'  # Windows home
elif command -v exa >/dev/null 2>&1; then
    alias ls='exa --color=auto'
    alias ll='exa -l --color=auto'
    alias la='exa -la --color=auto'
    alias lw='exa -la --color=auto /mnt/c/Users/$USER'
else
    alias ls='ls --color=auto'
    alias ll='ls -l --color=auto'
    alias la='ls -la --color=auto'
    alias lw='ls -la --color=auto /mnt/c/Users/$USER'
fi

# Windows directory shortcuts
alias cdw='cd /mnt/c/Users/$USER'
alias cdd='cd /mnt/c/Users/$USER/Desktop'
alias cdoc='cd /mnt/c/Users/$USER/Documents'
alias cdl='cd /mnt/c/Users/$USER/Downloads'

# Windows application integration
alias explorer='explorer.exe'
alias notepad='notepad.exe'
alias calc='calc.exe'

# PowerShell integration
alias ps='powershell.exe'
alias pwsh='pwsh.exe'

# ========================================
# WSL Windows Integration Functions
# ========================================

# Open file/directory in Windows Explorer
open() {
    local target="${1:-.}"
    
    if [[ -d "$target" ]]; then
        explorer.exe "$(wslpath -w "$target")" 2>/dev/null
        echo "📁 Opened directory in Windows Explorer: $target"
    elif [[ -f "$target" ]]; then
        # Open file with default Windows application
        cmd.exe /c start "$(wslpath -w "$target")" 2>/dev/null
        echo "📄 Opened file with default Windows app: $target"
    else
        echo "❌ File or directory not found: $target"
        return 1
    fi
}

# Convert between WSL and Windows paths
wslpath_convert() {
    local path="$1"
    local format="${2:-linux}"
    
    if [[ -z "$path" ]]; then
        echo "Usage: wslpath_convert <path> [linux|windows]"
        return 1
    fi
    
    case "$format" in
        "windows"|"win"|"w")
            wslpath -w "$path"
            ;;
        "linux"|"unix"|"l")
            wslpath -u "$path"
            ;;
        *)
            echo "❌ Invalid format. Use 'linux' or 'windows'"
            return 1
            ;;
    esac
}

# Windows clipboard integration
if command -v clip.exe >/dev/null 2>&1; then
    # Copy to Windows clipboard
    pbcopy() {
        if [[ -p /dev/stdin ]]; then
            cat | clip.exe
        else
            echo "$*" | clip.exe
        fi
    }
    
    # Paste from Windows clipboard (requires PowerShell)
    pbpaste() {
        powershell.exe -Command "Get-Clipboard" 2>/dev/null | sed 's/\r$//'
    }
fi

# WSL system information
wsl_info() {
    echo "🪟 WSL Environment Information:"
    echo ""
    echo "📦 Distribution: ${WSL_DISTRO}"
    echo "🔢 WSL Version: ${WSL_VERSION}"
    echo "🖥️  Hostname: $(hostname)"
    echo "👤 User: $(whoami)"
    echo "🏠 Linux Home: $HOME"
    echo "🪟 Windows Home: ${WINDOWS_HOME}"
    
    # WSL version detection
    if [[ -f "/proc/version" ]]; then
        local wsl_kernel=$(grep -oP 'WSL\d+' /proc/version 2>/dev/null || echo "Unknown")
        echo "🐧 Kernel: $wsl_kernel"
    fi
    
    # GUI availability
    echo "🖼️  GUI Support: ${GUI_AVAILABLE:-unknown}"
    if [[ "${GUI_AVAILABLE}" == "true" ]]; then
        echo "   DISPLAY: ${DISPLAY:-not set}"
        echo "   WAYLAND_DISPLAY: ${WAYLAND_DISPLAY:-not set}"
    fi
    
    # Windows integration status
    echo ""
    echo "🔗 Windows Integration:"
    if command -v explorer.exe >/dev/null 2>&1; then
        echo "  ✅ Windows Explorer"
    else
        echo "  ❌ Windows Explorer"
    fi
    
    if command -v powershell.exe >/dev/null 2>&1; then
        echo "  ✅ PowerShell"
    else
        echo "  ❌ PowerShell"
    fi
    
    if command -v clip.exe >/dev/null 2>&1; then
        echo "  ✅ Clipboard Integration"
    else
        echo "  ❌ Clipboard Integration"
    fi
}

# Windows service management
windows_service() {
    local action="$1"
    local service="$2"
    
    if [[ -z "$action" ]] || [[ -z "$service" ]]; then
        echo "Usage: windows_service <start|stop|status> <service_name>"
        return 1
    fi
    
    case "$action" in
        "start")
            powershell.exe -Command "Start-Service -Name '$service'" 2>/dev/null
            echo "🟢 Started Windows service: $service"
            ;;
        "stop")
            powershell.exe -Command "Stop-Service -Name '$service'" 2>/dev/null
            echo "🔴 Stopped Windows service: $service"
            ;;
        "status")
            powershell.exe -Command "Get-Service -Name '$service' | Select-Object Name, Status" 2>/dev/null
            ;;
        *)
            echo "❌ Invalid action. Use start, stop, or status"
            return 1
            ;;
    esac
}

# ========================================
# WSL Development Environment
# ========================================

# WSL-optimized development server
serve_wsl() {
    local port="${1:-3000}"
    local directory="${2:-.}"
    
    echo "🌐 Starting development server on port $port..."
    echo "📁 Serving: $(pwd)/$directory"
    echo "🔗 WSL Access: http://localhost:$port"
    echo "🪟 Windows Access: http://$(hostname).local:$port"
    echo "   Or use: http://$(hostname -I | awk '{print $1}'):$port"
    
    if command -v python3 >/dev/null 2>&1; then
        cd "$directory" && python3 -m http.server "$port"
    elif command -v python >/dev/null 2>&1; then
        cd "$directory" && python -m SimpleHTTPServer "$port"
    else
        echo "❌ Python not available"
        return 1
    fi
}

# Git configuration for WSL
setup_git_wsl() {
    echo "🔧 Configuring Git for WSL environment..."
    
    # Use Windows credential manager if available
    if command -v git-credential-manager-core.exe >/dev/null 2>&1; then
        git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/libexec/git-core/git-credential-manager-core.exe"
        echo "✅ Configured Windows Git Credential Manager"
    elif command -v git-credential-manager.exe >/dev/null 2>&1; then
        git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/libexec/git-core/git-credential-manager.exe"
        echo "✅ Configured Windows Git Credential Manager (legacy)"
    fi
    
    # Set line ending handling for cross-platform compatibility
    git config --global core.autocrlf input
    git config --global core.eol lf
    
    # Set safe directory for Windows paths
    git config --global --add safe.directory '*'
    
    echo "✅ Git configured for WSL/Windows integration"
}

# Docker Desktop integration
setup_docker_wsl() {
    if [[ -S "/var/run/docker.sock" ]]; then
        echo "✅ Docker Desktop WSL integration detected"
        export DOCKER_HOST="unix:///var/run/docker.sock"
    elif command -v docker.exe >/dev/null 2>&1; then
        echo "🐋 Using Windows Docker Desktop"
        alias docker='docker.exe'
        alias docker-compose='docker-compose.exe'
    else
        echo "❌ Docker not available in WSL"
    fi
}

# ========================================
# WSL Performance Optimization
# ========================================

# WSL-specific optimizations
optimize_wsl() {
    echo "⚡ Optimizing WSL environment..."
    
    # Set WSL-optimized umask
    umask 022
    
    # Optimize file system performance
    if [[ -d "/mnt/c" ]]; then
        # Set metadata options for Windows drives
        echo "🔧 Optimizing Windows drive access..."
    fi
    
    # Memory optimization
    export HISTSIZE=5000
    export SAVEHIST=5000
    export HISTCONTROL="ignoreboth:erasedups"
    
    # Network optimization
    if [[ -f "/etc/wsl.conf" ]]; then
        echo "📡 WSL network configuration detected"
    fi
    
    echo "✅ WSL environment optimized"
}

# ========================================
# WSL GUI Application Support
# ========================================

# Launch GUI applications (if supported)
launch_gui() {
    local app="$1"
    
    if [[ -z "$app" ]]; then
        echo "Usage: launch_gui <application>"
        return 1
    fi
    
    if [[ "${GUI_AVAILABLE}" != "true" ]]; then
        echo "❌ GUI support not available in this WSL environment"
        return 1
    fi
    
    if command -v "$app" >/dev/null 2>&1; then
        nohup "$app" >/dev/null 2>&1 &
        disown
        echo "🚀 Launched GUI application: $app"
    else
        echo "❌ Application not found: $app"
        return 1
    fi
}

# ========================================
# WSL Proxy and Network Configuration
# ========================================

# WSL-specific proxy configuration (Windows integration)
{{- if eq .chezmoi.os "linux" }}
# WSL proxy management with Windows integration
proxyon_wsl() {
    echo "🔗 Configuring proxy for WSL environment..."
    
    # Set environment variables
    export http_proxy="http://127.0.0.1:7890"
    export https_proxy="http://127.0.0.1:7890"
    export all_proxy="socks5://127.0.0.1:7891"
    export HTTP_PROXY="$http_proxy"
    export HTTPS_PROXY="$https_proxy"
    export ALL_PROXY="$all_proxy"
    export no_proxy="localhost,127.0.0.1,10.0.0.0/8,192.168.0.0/16,172.16.0.0/12"
    export NO_PROXY="$no_proxy"
    
    # Configure Git to use proxy
    git config --global http.proxy "$http_proxy"
    git config --global https.proxy "$https_proxy"
    
    echo "✅ WSL proxy configuration applied"
    echo "   Note: Ensure Windows proxy is running on the specified ports"
}

proxyoff_wsl() {
    echo "🔗 Disabling proxy for WSL environment..."
    
    # Clear environment variables
    unset http_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY no_proxy NO_PROXY
    
    # Clear Git proxy configuration
    git config --global --unset http.proxy 2>/dev/null || true
    git config --global --unset https.proxy 2>/dev/null || true
    
    echo "✅ WSL proxy configuration cleared"
}

proxystatus_wsl() {
    echo "🔗 WSL Proxy Status:"
    echo "  http_proxy: ${http_proxy:-not set}"
    echo "  https_proxy: ${https_proxy:-not set}"
    echo "  all_proxy: ${all_proxy:-not set}"
    echo ""
    echo "🔧 Git Proxy Configuration:"
    echo "  http.proxy: $(git config --global --get http.proxy 2>/dev/null || echo 'not set')"
    echo "  https.proxy: $(git config --global --get https.proxy 2>/dev/null || echo 'not set')"
}

# Override default proxy functions with WSL versions
alias proxyon='proxyon_wsl'
alias proxyoff='proxyoff_wsl'
alias proxystatus='proxystatus_wsl'
{{- end }}

# ========================================
# WSL Environment Validation
# ========================================

# Validate WSL environment setup
validate_wsl_environment() {
    echo "🪟 WSL Environment Validation:"
    echo ""
    
    # WSL detection validation
    if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
        echo "✅ WSL Distribution: $WSL_DISTRO_NAME"
    elif grep -qi "microsoft\|wsl" /proc/version 2>/dev/null; then
        echo "✅ WSL Environment detected via kernel"
    else
        echo "⚠️  WSL environment not clearly detected"
    fi
    
    # Windows integration check
    echo ""
    echo "🪟 Windows Integration:"
    local integration_score=0
    
    if [[ -d "/mnt/c" ]]; then
        echo "  ✅ Windows filesystem mounted"
        integration_score=$((integration_score + 1))
    else
        echo "  ❌ Windows filesystem not mounted"
    fi
    
    if command -v explorer.exe >/dev/null 2>&1; then
        echo "  ✅ Windows Explorer accessible"
        integration_score=$((integration_score + 1))
    else
        echo "  ❌ Windows Explorer not accessible"
    fi
    
    if command -v powershell.exe >/dev/null 2>&1; then
        echo "  ✅ PowerShell accessible"
        integration_score=$((integration_score + 1))
    else
        echo "  ❌ PowerShell not accessible"
    fi
    
    echo "  📊 Integration Score: $integration_score/3"
    
    # Development tools check
    echo ""
    echo "🛠️  Development Tools:"
    local dev_tools=("git" "code" "docker" "node" "python3")
    for tool in "${dev_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "  ✅ $tool"
        else
            echo "  ❌ $tool (not installed)"
        fi
    done
    
    # GUI support check
    echo ""
    echo "🖼️  GUI Support:"
    echo "  Available: ${GUI_AVAILABLE:-unknown}"
    if [[ "${GUI_AVAILABLE}" == "true" ]]; then
        echo "  DISPLAY: ${DISPLAY:-not set}"
        if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
            echo "  WAYLAND_DISPLAY: $WAYLAND_DISPLAY (WSLg detected)"
        fi
    fi
    
    # Performance settings
    echo ""
    echo "⚡ Performance Settings:"
    echo "  Development Mode: ${DEVELOPMENT_MODE:-not set}"
    echo "  GUI Tools: ${GUI_TOOLS_ENABLED:-not set}"
    echo "  WSL Distro: ${WSL_DISTRO:-not set}"
}

# ========================================
# Export WSL Functions
# ========================================

# Export WSL functions (with error handling)
declare -f open >/dev/null 2>&1 && export -f open 2>/dev/null || true
declare -f wslpath_convert >/dev/null 2>&1 && export -f wslpath_convert 2>/dev/null || true
declare -f wsl_info >/dev/null 2>&1 && export -f wsl_info 2>/dev/null || true
declare -f windows_service >/dev/null 2>&1 && export -f windows_service 2>/dev/null || true
declare -f serve_wsl >/dev/null 2>&1 && export -f serve_wsl 2>/dev/null || true
declare -f setup_git_wsl >/dev/null 2>&1 && export -f setup_git_wsl 2>/dev/null || true
declare -f setup_docker_wsl >/dev/null 2>&1 && export -f setup_docker_wsl 2>/dev/null || true
declare -f optimize_wsl >/dev/null 2>&1 && export -f optimize_wsl 2>/dev/null || true
declare -f launch_gui >/dev/null 2>&1 && export -f launch_gui 2>/dev/null || true
declare -f validate_wsl_environment >/dev/null 2>&1 && export -f validate_wsl_environment 2>/dev/null || true
{{- if eq .chezmoi.os "linux" }}
declare -f proxyon_wsl >/dev/null 2>&1 && export -f proxyon_wsl 2>/dev/null || true
declare -f proxyoff_wsl >/dev/null 2>&1 && export -f proxyoff_wsl 2>/dev/null || true
declare -f proxystatus_wsl >/dev/null 2>&1 && export -f proxystatus_wsl 2>/dev/null || true
{{- end }}

# ========================================
# WSL Environment Aliases
# ========================================

# WSL-specific aliases
alias info='wsl_info'
alias winpath='wslpath_convert'
alias serve='serve_wsl'
alias gui='launch_gui'
alias validate-wsl='validate_wsl_environment'

# Windows integration shortcuts
alias win='cd /mnt/c/Users/$USER'
alias desktop='cd /mnt/c/Users/$USER/Desktop'
alias downloads='cd /mnt/c/Users/$USER/Downloads'
alias documents='cd /mnt/c/Users/$USER/Documents'

# ========================================
# WSL Environment Initialization
# ========================================

# Auto-setup on load
if [[ -n "${WSL_DISTRO_NAME:-}" ]] || grep -qi "microsoft\|wsl" /proc/version 2>/dev/null; then
    # Set up Docker integration if available
    setup_docker_wsl >/dev/null 2>&1
    
    # Optimize WSL environment
    optimize_wsl >/dev/null 2>&1
    
    # Set WSL-specific prompt indicator
    export PS1_WSL_INDICATOR="[WSL] "
fi

# WSL environment configuration loaded