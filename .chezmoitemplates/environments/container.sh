# ========================================
# Container Environment Configuration
# ========================================
# Minimal configuration for container environments (Docker, Podman, etc.)
# Requirements: 3.3, 7.4 - Container environment with minimal config, optimized startup speed

# ========================================
# Container Environment Configuration (Static)
# ========================================
# 容器环境配置 - 由 chezmoi 静态编译，无运行时检测

# ========================================
# Container-Specific Environment Variables
# ========================================

# Minimal Mode Indicators
export DEVELOPMENT_MODE="minimal"
export GUI_TOOLS_ENABLED="false"
export CONTAINER_ENVIRONMENT="true"

# Optimize for container startup speed
export HISTSIZE=1000
export SAVEHIST=1000

# Minimal terminal settings
export TERM="${TERM:-xterm}"
export COLORTERM="${COLORTERM:-}"

# Container-optimized editor (prefer vi for minimal footprint)
{{- if .features.enable_vi }}
export EDITOR="vi"
export VISUAL="vi"
export GIT_EDITOR="vi"
{{- else if .features.enable_nano }}
export EDITOR="nano"
export VISUAL="nano"
export GIT_EDITOR="nano"
{{- end }}

# Disable unnecessary GUI variables
unset DISPLAY 2>/dev/null || true
unset WAYLAND_DISPLAY 2>/dev/null || true
unset XDG_SESSION_TYPE 2>/dev/null || true

# Container-specific paths
export CONTAINER_ID="${HOSTNAME:-unknown}"

# ========================================
# Minimal Aliases
# ========================================

# Essential file operations only
{{- if eq .chezmoi.os "linux" }}
alias ls='ls --color=auto'
alias ll='ls -l --color=auto'
alias la='ls -la --color=auto'
{{- else if eq .chezmoi.os "darwin" }}
alias ls='ls -G'
alias ll='ls -lG'
alias la='ls -laG'
{{- end }}

# Basic navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ~='cd ~'
alias -- -='cd -'

# Minimal system info
alias ps='ps aux'

# Safe operations (important in containers)
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# ========================================
# Container-Optimized Functions
# ========================================

# Minimal system information
container_info() {
    echo "🐳 Container Information:"
    echo ""
    echo "📦 Container ID: ${CONTAINER_ID}"
    echo "🖥️  Hostname: $(hostname)"
    echo "👤 User: $(whoami) (UID: $(id -u))"
    echo "📍 PWD: $(pwd)"
    echo "⏰ Uptime: $(uptime -p 2>/dev/null || uptime | cut -d',' -f1)"
    
    # Container type detection
    if [[ -f "/.dockerenv" ]]; then
        echo "🐋 Type: Docker Container"
    elif [[ -f "/run/.containerenv" ]]; then
        echo "🦭 Type: Podman Container"
    elif [[ -n "${container:-}" ]]; then
        echo "📦 Type: Container ($container)"
    else
        echo "📦 Type: Unknown Container"
    fi
    
    # Basic resource info
    if [[ -f "/proc/meminfo" ]]; then
        local mem_total=$(awk '/MemTotal/ {print int($2/1024) "MB"}' /proc/meminfo)
        local mem_available=$(awk '/MemAvailable/ {print int($2/1024) "MB"}' /proc/meminfo 2>/dev/null || echo "N/A")
        echo "💾 Memory: $mem_available available / $mem_total total"
    fi
    
    # Disk usage for root
    echo "💿 Disk: $(df -h / 2>/dev/null | awk 'NR==2 {print $3 "/" $2 " (" $5 " used)"}')"
}

# Minimal process listing
container_ps() {
    echo "🔄 Container Processes:"
    echo ""
    
    if command -v ps >/dev/null 2>&1; then
        # Show all processes in container (usually very few)
        {{- if eq .chezmoi.os "linux" }}
        ps aux --sort=-%cpu
        {{- else if eq .chezmoi.os "darwin" }}
        ps aux -r
        {{- end }}
    else
        echo "❌ ps command not available"
    fi
}

# Container network info
container_network() {
    echo "🌐 Container Network:"
    echo ""
    
    # Show container IP
    if command -v hostname >/dev/null 2>&1; then
        local container_ip=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "N/A")
        echo "📍 Container IP: $container_ip"
    fi
    
    # Show network interfaces (minimal)
    if command -v ip >/dev/null 2>&1; then
        echo "🔗 Interfaces:"
        ip addr show 2>/dev/null | grep -E "^[0-9]+:|inet " | sed 's/^/  /'
    elif command -v ifconfig >/dev/null 2>&1; then
        echo "🔗 Interfaces:"
        ifconfig 2>/dev/null | grep -E "^[a-z]|inet " | sed 's/^/  /'
    fi
    
    # Test external connectivity (if available)
    if command -v ping >/dev/null 2>&1; then
        if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
            echo "✅ External connectivity: Available"
        else
            echo "❌ External connectivity: Not available"
        fi
    fi
}

# Minimal file search
find_file() {
    local name="$1"
    local path="${2:-.}"
    
    if [[ -z "$name" ]]; then
        echo "Usage: find_file <name> [path]"
        return 1
    fi
    
    # Simple find command optimized for containers
    find "$path" -name "*$name*" -type f 2>/dev/null | head -10
}

# Container environment check
container_env() {
    echo "🔍 Container Environment Variables:"
    echo ""
    
    # Show container-related environment variables
    env | grep -E "(CONTAINER|DOCKER|PODMAN|KUBERNETES|K8S)" | sort || echo "No container-specific variables found"
    
    echo ""
    echo "🏷️  Common Variables:"
    echo "  HOME: ${HOME:-not set}"
    echo "  PATH: ${PATH:-not set}"
    echo "  USER: ${USER:-not set}"
    echo "  SHELL: ${SHELL:-not set}"
    echo "  TERM: ${TERM:-not set}"
}

# ========================================
# Container Optimization Functions
# ========================================

# Disable all GUI-related functions
{{- if eq .chezmoi.os "linux" }}
# Stub GUI functions for container environment
dark() {
    echo "ℹ️  GUI functions not available in container environment"
}

light() {
    echo "ℹ️  GUI functions not available in container environment"
}

themestatus() {
    echo "ℹ️  GUI functions not available in container environment"
}

# Minimal proxy support (environment variables only)
proxyon() {
    echo "🔗 Setting minimal proxy environment variables..."
    export http_proxy="${HTTP_PROXY_URL:-http://127.0.0.1:7890}"
    export https_proxy="${HTTPS_PROXY_URL:-http://127.0.0.1:7890}"
    export HTTP_PROXY="$http_proxy"
    export HTTPS_PROXY="$https_proxy"
    export no_proxy="localhost,127.0.0.1"
    export NO_PROXY="$no_proxy"
    echo "✅ Proxy environment variables set"
}

proxyoff() {
    echo "🔗 Clearing proxy environment variables..."
    unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY no_proxy NO_PROXY
    echo "✅ Proxy environment variables cleared"
}

proxystatus() {
    echo "🔗 Proxy Status (Environment Variables):"
    echo "  http_proxy: ${http_proxy:-not set}"
    echo "  https_proxy: ${https_proxy:-not set}"
}
{{- end }}

# ========================================
# Container Health and Diagnostics
# ========================================

# Container health check
container_health() {
    echo "🏥 Container Health Check:"
    echo ""
    
    # Basic system health
    local exit_code=0
    
    # Check if basic commands work
    if ! command -v ls >/dev/null 2>&1; then
        echo "❌ Basic commands: ls not available"
        exit_code=1
    else
        echo "✅ Basic commands: Available"
    fi
    
    # Check filesystem access
    if [[ -r "/" ]] && [[ -w "/tmp" ]]; then
        echo "✅ Filesystem: Read/Write access OK"
    else
        echo "❌ Filesystem: Access issues detected"
        exit_code=1
    fi
    
    # Check memory availability
    if [[ -f "/proc/meminfo" ]]; then
        local mem_available=$(awk '/MemAvailable/ {print $2}' /proc/meminfo 2>/dev/null || echo "0")
        if [[ "$mem_available" -gt 100000 ]]; then  # > 100MB
            echo "✅ Memory: Sufficient ($(($mem_available/1024))MB available)"
        else
            echo "⚠️  Memory: Low ($(($mem_available/1024))MB available)"
        fi
    fi
    
    # Check disk space
    local disk_usage=$(df / 2>/dev/null | awk 'NR==2 {print $5}' | tr -d '%')
    if [[ -n "$disk_usage" ]] && [[ "$disk_usage" -lt 90 ]]; then
        echo "✅ Disk space: OK (${disk_usage}% used)"
    elif [[ -n "$disk_usage" ]]; then
        echo "⚠️  Disk space: High usage (${disk_usage}% used)"
    else
        echo "❓ Disk space: Cannot determine"
    fi
    
    return $exit_code
}

# Container startup optimization
optimize_container() {
    echo "⚡ Optimizing container environment..."
    
    # Clear unnecessary history
    history -c 2>/dev/null || true
    
    # Set minimal prompt for faster rendering
    export PS1='$ '
    
    # Disable bash completion loading for speed
    export BASH_COMPLETION_COMPAT_DIR=""
    
    # Set minimal PATH
    export PATH="/usr/local/bin:/usr/bin:/bin"
    
    # Optimize shell options for speed
    if [[ -n "$BASH_VERSION" ]]; then
        set +h  # Disable hash table
        shopt -u histappend  # Don't append to history
    fi
    
    echo "✅ Container environment optimized for minimal resource usage"
}

# ========================================
# Container Environment Validation
# ========================================

# Validate container environment setup
validate_container_environment() {
    echo "🐳 Container Environment Validation:"
    echo ""
    
    # Container detection validation
    local container_detected=false
    if [[ -f "/.dockerenv" ]]; then
        echo "✅ Docker container detected"
        container_detected=true
    elif [[ -f "/run/.containerenv" ]]; then
        echo "✅ Podman container detected"
        container_detected=true
    elif [[ -n "${container:-}" ]]; then
        echo "✅ Container environment detected ($container)"
        container_detected=true
    else
        echo "⚠️  No container environment detected"
    fi
    
    # Essential tools check (minimal set)
    echo ""
    echo "🛠️  Essential Tools:"
    local essential_tools=("sh" "ls" "cat" "grep" "find")
    for tool in "${essential_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "  ✅ $tool"
        else
            echo "  ❌ $tool (critical)"
        fi
    done
    
    # Optional tools
    echo ""
    echo "🔧 Optional Tools:"
    local optional_tools=("vi" "nano" "curl" "wget" "git")
    for tool in "${optional_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "  ✅ $tool"
        else
            echo "  ➖ $tool (not installed)"
        fi
    done
    
    # Performance settings
    echo ""
    echo "⚡ Performance Settings:"
    echo "  Development Mode: ${DEVELOPMENT_MODE:-not set}"
    echo "  GUI Tools: ${GUI_TOOLS_ENABLED:-not set}"
    echo "  History Size: ${HISTSIZE:-not set}"
    echo "  Container ID: ${CONTAINER_ID:-not set}"
    
    # Resource usage
    echo ""
    echo "📊 Resource Usage:"
    if [[ -f "/proc/meminfo" ]]; then
        local mem_used=$(awk '/MemTotal|MemAvailable/ {if($1=="MemTotal:") total=$2; if($1=="MemAvailable:") avail=$2} END {print int((total-avail)/1024) "MB"}' /proc/meminfo)
        local mem_total=$(awk '/MemTotal/ {print int($2/1024) "MB"}' /proc/meminfo)
        echo "  Memory: $mem_used used / $mem_total total"
    fi
    
    local disk_usage=$(df / 2>/dev/null | awk 'NR==2 {print $5}')
    echo "  Disk: ${disk_usage:-unknown} used"
}

# ========================================
# Export Container Functions
# ========================================

# Export container functions (with error handling)
declare -f container_info >/dev/null 2>&1 && export -f container_info 2>/dev/null || true
declare -f container_ps >/dev/null 2>&1 && export -f container_ps 2>/dev/null || true
declare -f container_network >/dev/null 2>&1 && export -f container_network 2>/dev/null || true
declare -f find_file >/dev/null 2>&1 && export -f find_file 2>/dev/null || true
declare -f container_env >/dev/null 2>&1 && export -f container_env 2>/dev/null || true
declare -f container_health >/dev/null 2>&1 && export -f container_health 2>/dev/null || true
declare -f optimize_container >/dev/null 2>&1 && export -f optimize_container 2>/dev/null || true
declare -f validate_container_environment >/dev/null 2>&1 && export -f validate_container_environment 2>/dev/null || true

# ========================================
# Container Environment Aliases
# ========================================

# Minimal aliases for container use
alias info='container_info'
alias cps='container_ps'
alias net='container_network'
alias env='container_env'
alias health='container_health'
alias optimize='optimize_container'
alias validate-container='validate_container_environment'

# Quick shortcuts
alias h='history'
alias j='jobs'
alias p='pwd'

# ========================================
# Container Environment Initialization
# ========================================

# Auto-optimize on load if in container
if [[ -f "/.dockerenv" ]] || [[ -f "/run/.containerenv" ]] || [[ -n "${container:-}" ]]; then
    # Set ultra-minimal prompt
    export PS1='# '
    
    # Disable command hashing for minimal memory usage
    set +h 2>/dev/null || true
    
    # Set conservative umask
    umask 022
    
    # Minimal history settings
    export HISTCONTROL="ignoreboth"
    export HISTIGNORE="ls:ll:la:cd:pwd:exit:clear:history:h:p"
fi

# Container environment configuration loaded