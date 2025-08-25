# ========================================
# Remote Environment Configuration
# ========================================
# Lightweight configuration for SSH remote environments and VPS
# Requirements: 3.2, 7.1, 7.2 - Remote environment with lightweight config, skip GUI and heavy tools

# Remote Environment Detection and Validation
if [[ "${CHEZMOI_DETECTED_ENV:-}" != "remote" ]] && [[ -z "${FORCE_REMOTE_CONFIG:-}" ]]; then
    # Only load remote config in actual remote environments
    if [[ -z "${SSH_CONNECTION:-}${SSH_CLIENT:-}${SSH_TTY:-}" ]]; then
        echo "⚠️  Remote configuration loaded in non-remote environment. Use FORCE_REMOTE_CONFIG=1 to override."
        return 0
    fi
fi

echo "🌐 Loading remote environment configuration..."

# ========================================
# Remote-Specific Environment Variables
# ========================================

# Lightweight Mode Indicators
export DEVELOPMENT_MODE="lightweight"
export GUI_TOOLS_ENABLED="false"
export REMOTE_ENVIRONMENT="true"

# Terminal Optimization for Remote Sessions
export TERM="${TERM:-xterm-256color}"
export COLORTERM="${COLORTERM:-truecolor}"

# Network Optimization Settings
export SSH_KEEPALIVE_INTERVAL="60"
export SSH_KEEPALIVE_COUNT="3"

# Reduced History Size for Performance
export HISTSIZE=5000
export SAVEHIST=5000

# Lightweight Editor Preferences (Remote Priority)
if command -v vim >/dev/null 2>&1; then
    export EDITOR="vim"
    export VISUAL="vim"
    export GIT_EDITOR="vim"
elif command -v nano >/dev/null 2>&1; then
    export EDITOR="nano"
    export VISUAL="nano"
    export GIT_EDITOR="nano"
elif command -v vi >/dev/null 2>&1; then
    export EDITOR="vi"
    export VISUAL="vi"
    export GIT_EDITOR="vi"
fi

# Disable GUI-related variables
unset DISPLAY 2>/dev/null || true
unset WAYLAND_DISPLAY 2>/dev/null || true

# ========================================
# Lightweight Tool Aliases
# ========================================

# Prefer lightweight alternatives
if command -v batcat >/dev/null 2>&1; then
    alias bat='batcat'
    alias cat='batcat --paging=never'
elif command -v bat >/dev/null 2>&1; then
    alias cat='bat --paging=never'
fi

# File listing with minimal options
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --color=auto'
    alias ll='eza -l --color=auto'
    alias la='eza -la --color=auto'
elif command -v exa >/dev/null 2>&1; then
    alias ls='exa --color=auto'
    alias ll='exa -l --color=auto'
    alias la='exa -la --color=auto'
else
    # Fallback to standard ls with colors
    {{- if eq .chezmoi.os "linux" }}
    alias ls='ls --color=auto'
    alias ll='ls -l --color=auto'
    alias la='ls -la --color=auto'
    {{- else if eq .chezmoi.os "darwin" }}
    alias ls='ls -G'
    alias ll='ls -lG'
    alias la='ls -laG'
    {{- end }}
fi

# Lightweight system monitoring
if command -v htop >/dev/null 2>&1; then
    alias top='htop'
elif command -v top >/dev/null 2>&1; then
    alias monitor='top'
fi

# Network utilities
alias myip='curl -s ifconfig.me || curl -s ipinfo.io/ip'
alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3'

# ========================================
# Remote-Optimized Functions
# ========================================

# Lightweight file search (avoid heavy indexing)
search() {
    local pattern="$1"
    local path="${2:-.}"
    
    if [[ -z "$pattern" ]]; then
        echo "Usage: search <pattern> [path]"
        return 1
    fi
    
    # Use find for lightweight search
    find "$path" -type f -name "*$pattern*" 2>/dev/null | head -20
}

# Quick text search in files
grep_files() {
    local pattern="$1"
    local path="${2:-.}"
    
    if [[ -z "$pattern" ]]; then
        echo "Usage: grep_files <pattern> [path]"
        return 1
    fi
    
    # Use grep with basic options for performance
    grep -r --include="*.txt" --include="*.md" --include="*.sh" --include="*.py" --include="*.js" \
         --include="*.json" --include="*.yaml" --include="*.yml" \
         "$pattern" "$path" 2>/dev/null | head -20
}

# Lightweight system information
sysinfo() {
    echo "🖥️  System Information (Remote):"
    echo ""
    echo "📍 Hostname: $(hostname)"
    echo "👤 User: $(whoami)"
    echo "🌐 IP: $(hostname -I 2>/dev/null | awk '{print $1}' || echo 'N/A')"
    echo "⏰ Uptime: $(uptime -p 2>/dev/null || uptime)"
    echo ""
    
    # OS Information
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo "🐧 OS: $PRETTY_NAME"
    elif [[ "$(uname -s)" == "Darwin" ]]; then
        echo "🍎 OS: macOS $(sw_vers -productVersion 2>/dev/null || echo 'Unknown')"
    else
        echo "💻 OS: $(uname -s) $(uname -r)"
    fi
    
    # Memory usage (lightweight check)
    if command -v free >/dev/null 2>&1; then
        echo "💾 Memory: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    elif [[ "$(uname -s)" == "Darwin" ]]; then
        local mem_total=$(sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1024/1024/1024) "GB"}')
        echo "💾 Memory: $mem_total total"
    fi
    
    # Disk usage for current directory
    echo "💿 Disk (current): $(df -h . 2>/dev/null | awk 'NR==2 {print $3 "/" $2 " (" $5 " used)"}')"
    
    # Load average
    if [[ -f /proc/loadavg ]]; then
        echo "📊 Load: $(cat /proc/loadavg | awk '{print $1, $2, $3}')"
    fi
}

# Network connectivity check
netcheck() {
    echo "🌐 Network Connectivity Check:"
    echo ""
    
    # Check basic connectivity
    if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        echo "✅ Internet: Connected"
    else
        echo "❌ Internet: Disconnected"
    fi
    
    # Check DNS resolution
    if nslookup google.com >/dev/null 2>&1; then
        echo "✅ DNS: Working"
    else
        echo "❌ DNS: Failed"
    fi
    
    # Show external IP
    local external_ip=$(curl -s --connect-timeout 5 ifconfig.me 2>/dev/null || echo "N/A")
    echo "🌍 External IP: $external_ip"
    
    # SSH connection info
    if [[ -n "${SSH_CONNECTION:-}" ]]; then
        echo "🔗 SSH: $SSH_CONNECTION"
    fi
}

# Lightweight process management
processes() {
    echo "🔄 Running Processes (Top 10 by CPU):"
    echo ""
    
    if command -v ps >/dev/null 2>&1; then
        {{- if eq .chezmoi.os "linux" }}
        ps aux --sort=-%cpu | head -11
        {{- else if eq .chezmoi.os "darwin" }}
        ps aux -r | head -11
        {{- end }}
    else
        echo "❌ ps command not available"
    fi
}

# ========================================
# Remote Development Shortcuts
# ========================================

# Lightweight development server
serve_simple() {
    local port="${1:-8000}"
    local directory="${2:-.}"
    
    echo "🌐 Starting simple HTTP server on port $port..."
    echo "📁 Serving: $(pwd)/$directory"
    echo "🔗 Access via SSH tunnel: ssh -L $port:localhost:$port user@server"
    
    if command -v python3 >/dev/null 2>&1; then
        cd "$directory" && python3 -m http.server "$port"
    elif command -v python >/dev/null 2>&1; then
        cd "$directory" && python -m SimpleHTTPServer "$port"
    else
        echo "❌ Python not available"
        return 1
    fi
}

# Quick file transfer helpers
upload() {
    local file="$1"
    if [[ -z "$file" ]] || [[ ! -f "$file" ]]; then
        echo "Usage: upload <file>"
        echo "Uploads file to transfer.sh for sharing"
        return 1
    fi
    
    if command -v curl >/dev/null 2>&1; then
        local url=$(curl --upload-file "$file" https://transfer.sh/$(basename "$file") 2>/dev/null)
        echo "📤 Upload URL: $url"
        echo "$url" | pbcopy 2>/dev/null || echo "(URL copied to clipboard if available)"
    else
        echo "❌ curl not available"
        return 1
    fi
}

# ========================================
# Remote Session Management
# ========================================

# Session information
session_info() {
    echo "📡 Remote Session Information:"
    echo ""
    echo "🖥️  Server: $(hostname)"
    echo "👤 User: $(whoami)"
    echo "📍 PWD: $(pwd)"
    echo "⏰ Login: $(who am i 2>/dev/null || echo 'N/A')"
    
    if [[ -n "${SSH_CONNECTION:-}" ]]; then
        local ssh_info=(${SSH_CONNECTION})
        echo "🔗 SSH Client: ${ssh_info[0]}:${ssh_info[1]}"
        echo "🔗 SSH Server: ${ssh_info[2]}:${ssh_info[3]}"
    fi
    
    if [[ -n "${SSH_TTY:-}" ]]; then
        echo "📺 TTY: $SSH_TTY"
    fi
    
    echo "🕐 Session Time: $(date)"
}

# Lightweight tmux session management
tmux_quick() {
    if ! command -v tmux >/dev/null 2>&1; then
        echo "❌ tmux not installed"
        return 1
    fi
    
    local session_name="${1:-main}"
    
    # Attach to existing session or create new one
    if tmux has-session -t "$session_name" 2>/dev/null; then
        echo "🔗 Attaching to existing session: $session_name"
        tmux attach-session -t "$session_name"
    else
        echo "🆕 Creating new session: $session_name"
        tmux new-session -s "$session_name"
    fi
}

# ========================================
# Remote Environment Optimization
# ========================================

# Skip GUI-related functions (provide stubs)
{{- if eq .chezmoi.os "linux" }}
# Disable GUI functions in remote environment
dark() {
    echo "ℹ️  GUI theme functions disabled in remote environment"
}

light() {
    echo "ℹ️  GUI theme functions disabled in remote environment"
}

themestatus() {
    echo "ℹ️  GUI theme functions disabled in remote environment"
}

# Provide CLI-only proxy management
proxyon() {
    echo "🔗 Setting environment proxy variables..."
    export http_proxy="http://127.0.0.1:7890"
    export https_proxy="http://127.0.0.1:7890"
    export all_proxy="socks5://127.0.0.1:7891"
    export HTTP_PROXY="$http_proxy"
    export HTTPS_PROXY="$https_proxy"
    export ALL_PROXY="$all_proxy"
    export no_proxy="localhost,127.0.0.1,10.0.0.0/8,192.168.0.0/16,172.16.0.0/12"
    export NO_PROXY="$no_proxy"
    echo "✅ Environment proxy variables set (CLI only)"
}

proxyoff() {
    echo "🔗 Clearing environment proxy variables..."
    unset http_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY no_proxy NO_PROXY
    echo "✅ Environment proxy variables cleared"
}

proxystatus() {
    echo "🔗 Proxy Status (Environment Variables Only):"
    echo "  http_proxy: ${http_proxy:-not set}"
    echo "  https_proxy: ${https_proxy:-not set}"
    echo "  all_proxy: ${all_proxy:-not set}"
}
{{- end }}

# ========================================
# Remote Environment Validation
# ========================================

# Validate remote environment setup
validate_remote_environment() {
    echo "🌐 Remote Environment Validation:"
    echo ""
    
    # SSH connection validation
    if [[ -n "${SSH_CONNECTION:-}" ]]; then
        echo "✅ SSH Connection: Active"
    elif [[ -n "${SSH_CLIENT:-}" ]]; then
        echo "✅ SSH Client: Detected"
    elif [[ -n "${SSH_TTY:-}" ]]; then
        echo "✅ SSH TTY: Active"
    else
        echo "⚠️  No SSH connection detected"
    fi
    
    # Terminal capabilities
    echo ""
    echo "📺 Terminal Capabilities:"
    echo "  TERM: ${TERM:-not set}"
    echo "  Colors: $(tput colors 2>/dev/null || echo 'unknown')"
    echo "  Columns: $(tput cols 2>/dev/null || echo 'unknown')"
    echo "  Lines: $(tput lines 2>/dev/null || echo 'unknown')"
    
    # Essential tools check
    echo ""
    echo "🛠️  Essential Tools:"
    local essential_tools=("vim" "git" "curl" "wget" "tmux" "htop")
    for tool in "${essential_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "  ✅ $tool"
        else
            echo "  ❌ $tool (recommended for remote work)"
        fi
    done
    
    # Performance indicators
    echo ""
    echo "⚡ Performance Mode:"
    echo "  Development Mode: ${DEVELOPMENT_MODE:-not set}"
    echo "  GUI Tools: ${GUI_TOOLS_ENABLED:-not set}"
    echo "  History Size: ${HISTSIZE:-not set}"
    
    # Network status
    echo ""
    echo "🌐 Network Status:"
    if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        echo "  ✅ Internet connectivity"
    else
        echo "  ❌ No internet connectivity"
    fi
}

# ========================================
# Export Remote Functions
# ========================================

export -f search
export -f grep_files
export -f sysinfo
export -f netcheck
export -f processes
export -f serve_simple
export -f upload
export -f session_info
export -f tmux_quick
export -f validate_remote_environment

# ========================================
# Remote Environment Aliases
# ========================================

# Lightweight aliases
alias info='sysinfo'
alias net='netcheck'
alias proc='processes'
alias sess='session_info'
alias tmux='tmux_quick'
alias serve='serve_simple'
alias validate-remote='validate_remote_environment'

# Quick navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# Safe file operations
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# ========================================
# Remote Environment Initialization
# ========================================

# Optimize shell for remote use
if [[ -n "${SSH_CONNECTION:-}" ]]; then
    # Reduce prompt complexity for better performance
    export PS1_SIMPLE="true"
    
    # Set conservative umask for security
    umask 022
    
    # Optimize history settings
    export HISTCONTROL="ignoreboth:erasedups"
    export HISTIGNORE="ls:ll:la:cd:pwd:exit:clear:history"
fi

# Remote environment ready notification
if [[ "${CHEZMOI_DEBUG:-}" == "true" ]]; then
    echo "✅ Remote environment configuration loaded successfully"
    echo "   Lightweight mode enabled - GUI functions disabled"
    echo "   Available commands: info, net, proc, sess, serve, validate-remote"
fi