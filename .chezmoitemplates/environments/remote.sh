# ========================================
# Remote Environment Configuration
# ========================================
# Lightweight configuration for SSH remote environments and VPS
# Requirements: 3.2, 7.1, 7.2 - Remote environment with lightweight config, skip GUI and heavy tools

# ========================================
# Remote Environment Configuration (Static)
# ========================================
# 远程环境配置 - 由 chezmoi 静态编译，无运行时检测

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
{{- if .features.enable_vim }}
export EDITOR="vim"
export VISUAL="vim"
export GIT_EDITOR="vim"
{{- else if .features.enable_nano }}
export EDITOR="nano"
export VISUAL="nano"
export GIT_EDITOR="nano"
{{- else if .features.enable_vi }}
export EDITOR="vi"
export VISUAL="vi"
export GIT_EDITOR="vi"
{{- end }}

# Disable GUI-related variables
unset DISPLAY 2>/dev/null || true
unset WAYLAND_DISPLAY 2>/dev/null || true

# ========================================
# Lightweight Tool Aliases
# ========================================

# Use Homebrew standard bat command (no more batcat aliases)
{{- if .features.enable_bat }}
alias cat='bat --paging=never'
{{- end }}

# Remote-specific file listing (lightweight, no icons for performance)
{{- if .features.enable_eza }}
# Use eza without icons for better performance over SSH
alias rls='eza --color=auto'
alias rll='eza -l --color=auto'
alias rla='eza -la --color=auto'
{{- else if .features.enable_exa }}
# Use exa without icons for better performance over SSH
alias rls='exa --color=auto'
alias rll='exa -l --color=auto'
alias rla='exa -la --color=auto'
{{- else }}
# Fallback to standard ls with colors
{{- if eq .chezmoi.os "linux" }}
alias rls='ls --color=auto'
alias rll='ls -l --color=auto'
alias rla='ls -la --color=auto'
{{- else if eq .chezmoi.os "darwin" }}
alias rls='ls -G'
alias rll='ls -lG'
alias rla='ls -laG'
{{- end }}
{{- end }}

# Note: Core aliases.sh will handle the main ls/ll/la aliases
# These remote-specific aliases (rls/rll/rla) are for explicit remote usage

# Lightweight system monitoring
{{- if .features.enable_htop }}
alias top='htop'
{{- else if .features.enable_top }}
alias monitor='top'
{{- end }}

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
    
    {{- if .features.enable_ps }}
        {{- if eq .chezmoi.os "linux" }}
        ps aux --sort=-%cpu | head -11
        {{- else if eq .chezmoi.os "darwin" }}
        ps aux -r | head -11
        {{- end }}
    {{- else }}
        echo "❌ ps command not available"
    {{- end }}
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

# ========================================
# Server专用代理管理函数
# ========================================
# Requirements: 2.3, 2.4, 2.5, 2.6 - Server环境专用代理管理

# 确保覆盖任何之前定义的代理函数
unset -f proxyon proxyoff proxystatus 2>/dev/null || true

# Server专用的proxyon函数 - 使用nohup和subscription.yaml
proxyon() {
    echo "🔗 启用服务器代理 (Remote环境版本)..."
    
    local clash_dir="$HOME/.config/clash"
    local clash_binary="$clash_dir/clash"
    local config_file="$clash_dir/subscription.yaml"
    local fallback_config="$clash_dir/config.yaml"
    local log_file="$clash_dir/clash.log"
    
    # 检查clash目录是否存在
    if [[ ! -d "$clash_dir" ]]; then
        echo "❌ Clash目录不存在: $clash_dir"
        echo "💡 请创建目录并放置clash二进制文件和配置文件"
        return 1
    fi
    
    # 检查clash二进制文件
    if [[ ! -f "$clash_binary" ]]; then
        echo "❌ Clash二进制文件不存在: $clash_binary"
        echo "💡 请下载clash二进制文件到 $clash_binary"
        echo "💡 下载地址: https://github.com/Dreamacro/clash/releases"
        return 1
    fi
    
    # 检查二进制文件是否可执行
    if [[ ! -x "$clash_binary" ]]; then
        echo "⚠️  设置clash二进制文件为可执行..."
        chmod +x "$clash_binary" || {
            echo "❌ 无法设置执行权限，请检查文件权限"
            return 1
        }
    fi
    
    # 检查配置文件（优先subscription.yaml，回退到config.yaml）
    local selected_config=""
    if [[ -f "$config_file" ]]; then
        selected_config="$config_file"
        echo "📄 使用配置文件: subscription.yaml"
    elif [[ -f "$fallback_config" ]]; then
        selected_config="$fallback_config"
        echo "📄 使用回退配置文件: config.yaml"
    else
        echo "❌ 配置文件不存在:"
        echo "   - $config_file"
        echo "   - $fallback_config"
        echo "💡 请确保至少有一个配置文件存在"
        return 1
    fi
    
    # 检查clash进程是否已经在运行
    if pgrep -f "clash.*$(basename "$selected_config")" >/dev/null 2>&1; then
        echo "⚠️  Clash进程已在运行"
        echo "💡 使用 'proxyoff' 停止现有进程，或使用 'proxystatus' 查看状态"
        return 1
    fi
    
    # 切换到clash目录并启动clash进程
    echo "🚀 启动clash进程..."
    cd "$clash_dir" || {
        echo "❌ 无法切换到clash目录"
        return 1
    }
    
    # 清理旧的日志文件，避免nohup重定向失败
    if [[ -f "clash.log" ]]; then
        rm -f "clash.log" 2>/dev/null
    fi
    
    # 使用nohup启动clash进程
    nohup ./clash -f "$(basename "$selected_config")" > clash.log 2>&1 &
    local clash_pid=$!
    
    # 等待一小段时间确保进程启动
    sleep 2
    
    # 验证进程是否成功启动
    if ! kill -0 "$clash_pid" 2>/dev/null; then
        echo "❌ Clash进程启动失败"
        echo "📋 查看日志文件获取详细信息: $log_file"
        if [[ -f "$log_file" ]]; then
            echo "📋 最近的日志内容:"
            tail -10 "$log_file"
        fi
        return 1
    fi
    
    echo "✅ Clash进程已启动 (PID: $clash_pid)"
    
    # 从配置文件中解析端口信息
    local http_port="7890"  # 默认HTTP端口
    local socks_port="7891" # 默认SOCKS端口
    
    # 尝试从配置文件解析端口
    if command -v grep >/dev/null 2>&1 && command -v awk >/dev/null 2>&1; then
        # 解析HTTP端口
        local parsed_http_port=$(grep -E "^port:" "$selected_config" 2>/dev/null | awk '{print $2}' | tr -d '"' | head -1)
        if [[ -n "$parsed_http_port" ]] && [[ "$parsed_http_port" =~ ^[0-9]+$ ]]; then
            http_port="$parsed_http_port"
        fi
        
        # 解析SOCKS端口
        local parsed_socks_port=$(grep -E "^socks-port:" "$selected_config" 2>/dev/null | awk '{print $2}' | tr -d '"' | head -1)
        if [[ -n "$parsed_socks_port" ]] && [[ "$parsed_socks_port" =~ ^[0-9]+$ ]]; then
            socks_port="$parsed_socks_port"
        fi
    fi
    
    # 设置环境变量
    export http_proxy="http://127.0.0.1:$http_port"
    export https_proxy="http://127.0.0.1:$http_port"
    export all_proxy="socks5://127.0.0.1:$socks_port"
    export HTTP_PROXY="$http_proxy"
    export HTTPS_PROXY="$https_proxy"
    export ALL_PROXY="$all_proxy"
    export no_proxy="localhost,127.0.0.1,10.0.0.0/8,192.168.0.0/16,172.16.0.0/12"
    export NO_PROXY="$no_proxy"
    
    echo "🌐 代理环境变量已设置:"
    echo "   HTTP代理: $http_proxy"
    echo "   HTTPS代理: $https_proxy"
    echo "   SOCKS代理: $all_proxy"
    
    # 测试代理连接
    echo "🔍 测试代理连接..."
    if command -v curl >/dev/null 2>&1; then
        local test_result=$(curl -s --connect-timeout 10 --proxy "$http_proxy" httpbin.org/ip 2>/dev/null || echo "failed")
        if [[ "$test_result" != "failed" ]]; then
            echo "✅ 代理连接测试成功"
        else
            echo "⚠️  代理连接测试失败，但进程已启动"
            echo "💡 请检查配置文件和网络连接"
        fi
    else
        echo "⚠️  curl不可用，跳过连接测试"
    fi
    
    echo "✅ 服务器代理已启用"
    echo "💡 使用 'proxystatus' 查看状态，'proxyoff' 停止代理"
}

# Server专用的proxyoff函数 - 停止clash进程和清理环境变量
proxyoff() {
    echo "🔗 停止服务器代理 (Remote环境版本)..."
    
    local clash_dir="$HOME/.config/clash"
    local stopped_any=false
    
    # 查找并停止clash进程
    local clash_pids=$(pgrep -f "clash.*\.(yaml|yml)" 2>/dev/null)
    
    if [[ -n "$clash_pids" ]]; then
        echo "🛑 停止clash进程..."
        for pid in $clash_pids; do
            if kill -0 "$pid" 2>/dev/null; then
                echo "   停止进程 PID: $pid"
                kill "$pid" 2>/dev/null
                stopped_any=true
                
                # 等待进程结束
                local count=0
                while kill -0 "$pid" 2>/dev/null && [[ $count -lt 10 ]]; do
                    sleep 1
                    ((count++))
                done
                
                # 如果进程仍在运行，强制终止
                if kill -0 "$pid" 2>/dev/null; then
                    echo "   强制终止进程 PID: $pid"
                    kill -9 "$pid" 2>/dev/null
                fi
            fi
        done
    else
        echo "ℹ️  未找到运行中的clash进程"
    fi
    
    # 清理环境变量
    echo "🧹 清理代理环境变量..."
    unset http_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY no_proxy NO_PROXY
    
    # 清理日志文件
    local log_file="$clash_dir/clash.log"
    if [[ -f "$log_file" ]]; then
        echo "🗑️  清理日志文件..."
        rm -f "$log_file" 2>/dev/null && echo "   ✅ 日志文件已删除: $log_file" || echo "   ⚠️  无法删除日志文件: $log_file"
    fi
    
    # 显示结果
    if [[ "$stopped_any" == true ]]; then
        echo "✅ Clash进程已停止"
    fi
    echo "✅ 代理环境变量已清理"
    
    # 验证进程确实已停止
    if pgrep -f "clash.*\.(yaml|yml)" >/dev/null 2>&1; then
        echo "⚠️  仍有clash进程在运行，请手动检查:"
        pgrep -f "clash.*\.(yaml|yml)" | while read -r pid; do
            echo "   PID: $pid - $(ps -p "$pid" -o comm= 2>/dev/null || echo 'unknown')"
        done
    else
        echo "✅ 所有clash进程已停止"
    fi
}

# Server专用的proxystatus函数 - 显示进程状态和日志信息
proxystatus() {
    echo "🔍 服务器代理状态检查 (Remote环境版本)"
    echo "================================"
    
    local clash_dir="$HOME/.config/clash"
    local log_file="$clash_dir/clash.log"
    
    # 检查clash进程状态
    echo ""
    echo "📊 进程状态:"
    local clash_pids=$(pgrep -f "clash.*\.(yaml|yml)" 2>/dev/null)
    
    if [[ -n "$clash_pids" ]]; then
        echo "✅ Clash进程运行中:"
        for pid in $clash_pids; do
            if kill -0 "$pid" 2>/dev/null; then
                local cmd=$(ps -p "$pid" -o args= 2>/dev/null | head -1)
                local start_time=$(ps -p "$pid" -o lstart= 2>/dev/null)
                local cpu_mem=$(ps -p "$pid" -o %cpu,%mem= 2>/dev/null)
                echo "   PID: $pid"
                echo "   命令: $cmd"
                echo "   启动时间: $start_time"
                echo "   CPU/内存: $cpu_mem"
                echo ""
            fi
        done
    else
        echo "❌ 未找到运行中的clash进程"
    fi
    
    # 检查环境变量状态
    echo "🌐 环境变量状态:"
    if [[ -n "${http_proxy:-}" ]]; then
        echo "✅ 代理环境变量已设置:"
        echo "   HTTP代理: ${http_proxy:-未设置}"
        echo "   HTTPS代理: ${https_proxy:-未设置}"
        echo "   SOCKS代理: ${all_proxy:-未设置}"
        echo "   排除列表: ${no_proxy:-未设置}"
    else
        echo "❌ 代理环境变量未设置"
    fi
    
    # 检查配置文件状态
    echo ""
    echo "📄 配置文件状态:"
    local config_files=("$clash_dir/subscription.yaml" "$clash_dir/config.yaml")
    for config in "${config_files[@]}"; do
        if [[ -f "$config" ]]; then
            local size=$(ls -lh "$config" 2>/dev/null | awk '{print $5}')
            local mtime=$(ls -l "$config" 2>/dev/null | awk '{print $6, $7, $8}')
            echo "✅ $(basename "$config"): $size (修改时间: $mtime)"
        else
            echo "❌ $(basename "$config"): 不存在"
        fi
    done
    
    # 检查日志文件状态
    echo ""
    echo "📋 日志文件状态:"
    if [[ -f "$log_file" ]]; then
        local log_size=$(ls -lh "$log_file" 2>/dev/null | awk '{print $5}')
        local log_mtime=$(ls -l "$log_file" 2>/dev/null | awk '{print $6, $7, $8}')
        echo "✅ clash.log: $log_size (修改时间: $log_mtime)"
        
        echo ""
        echo "📋 最近的日志内容 (最后10行):"
        echo "--------------------------------"
        tail -10 "$log_file" 2>/dev/null || echo "无法读取日志文件"
        echo "--------------------------------"
    else
        echo "❌ clash.log: 不存在"
    fi
    
    # 网络连接测试
    echo ""
    echo "🌐 网络连接测试:"
    if [[ -n "${http_proxy:-}" ]] && command -v curl >/dev/null 2>&1; then
        echo "🔍 测试HTTP代理连接..."
        local test_result=$(curl -s --connect-timeout 10 --proxy "$http_proxy" httpbin.org/ip 2>/dev/null)
        if [[ -n "$test_result" ]] && echo "$test_result" | grep -q "origin"; then
            local proxy_ip=$(echo "$test_result" | grep -o '"origin": "[^"]*"' | cut -d'"' -f4)
            echo "✅ HTTP代理连接正常 (出口IP: $proxy_ip)"
        else
            echo "❌ HTTP代理连接失败"
        fi
        
        if [[ -n "${all_proxy:-}" ]]; then
            echo "🔍 测试SOCKS代理连接..."
            local socks_result=$(curl -s --connect-timeout 10 --proxy "$all_proxy" httpbin.org/ip 2>/dev/null)
            if [[ -n "$socks_result" ]] && echo "$socks_result" | grep -q "origin"; then
                local socks_ip=$(echo "$socks_result" | grep -o '"origin": "[^"]*"' | cut -d'"' -f4)
                echo "✅ SOCKS代理连接正常 (出口IP: $socks_ip)"
            else
                echo "❌ SOCKS代理连接失败"
            fi
        fi
    else
        echo "⚠️  无法进行网络测试 (代理未设置或curl不可用)"
    fi
    
    # 端口监听状态检查
    echo ""
    echo "🔌 端口监听状态:"
    if command -v netstat >/dev/null 2>&1; then
        local listening_ports=$(netstat -tlnp 2>/dev/null | grep ":789[01]" | head -5)
        if [[ -n "$listening_ports" ]]; then
            echo "✅ 检测到代理端口监听:"
            echo "$listening_ports"
        else
            echo "❌ 未检测到代理端口监听 (7890/7891)"
        fi
    elif command -v ss >/dev/null 2>&1; then
        local listening_ports=$(ss -tlnp 2>/dev/null | grep ":789[01]" | head -5)
        if [[ -n "$listening_ports" ]]; then
            echo "✅ 检测到代理端口监听:"
            echo "$listening_ports"
        else
            echo "❌ 未检测到代理端口监听 (7890/7891)"
        fi
    else
        echo "⚠️  无法检查端口状态 (netstat/ss不可用)"
    fi
    
    echo ""
    echo "================================"
    echo "💡 提示:"
    echo "   - 使用 'proxyon' 启用代理"
    echo "   - 使用 'proxyoff' 停止代理"
    echo "   - 日志文件位置: $log_file"
}

# 注意: 在远程环境中，proxyon/proxyoff/proxystatus函数已经直接定义
# 不需要别名，因为这些函数在远程环境中是专门的server版本实现
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

# Export remote-specific functions (with error handling)
declare -f search >/dev/null 2>&1 && export -f search 2>/dev/null || true
declare -f grep_files >/dev/null 2>&1 && export -f grep_files 2>/dev/null || true
declare -f netcheck >/dev/null 2>&1 && export -f netcheck 2>/dev/null || true
declare -f processes >/dev/null 2>&1 && export -f processes 2>/dev/null || true
declare -f serve_simple >/dev/null 2>&1 && export -f serve_simple 2>/dev/null || true
declare -f upload >/dev/null 2>&1 && export -f upload 2>/dev/null || true
declare -f session_info >/dev/null 2>&1 && export -f session_info 2>/dev/null || true
declare -f tmux_quick >/dev/null 2>&1 && export -f tmux_quick 2>/dev/null || true
declare -f validate_remote_environment >/dev/null 2>&1 && export -f validate_remote_environment 2>/dev/null || true

# 强制export代理函数，确保覆盖platform层的定义
export -f proxyon 2>/dev/null || true
export -f proxyoff 2>/dev/null || true  
export -f proxystatus 2>/dev/null || true

# Note: sysinfo function is defined in this file and will override the basic one from core

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

# Remote environment configuration loaded