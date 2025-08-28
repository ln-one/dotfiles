# ========================================
# Remote Environment Optimization
# ========================================

# Color helpers
_red()   { printf '\033[0;31m%s\033[0m\n' "$*"; }
_green() { printf '\033[0;32m%s\033[0m\n' "$*"; }
_yellow(){ printf '\033[0;33m%s\033[0m\n' "$*"; }
_blue()  { printf '\033[0;34m%s\033[0m\n' "$*"; }
_cyan()  { printf '\033[0;36m%s\033[0m\n' "$*"; }
_bold()  { printf '\033[1m%s\033[0m\n' "$*"; }

{{- if eq .chezmoi.os "linux" }}

# Stub GUI theme functions in remote environment
dark()        { _yellow "GUI theme functions are disabled in remote environment"; }
light()       { _yellow "GUI theme functions are disabled in remote environment"; }
themestatus() { _yellow "GUI theme functions are disabled in remote environment"; }

# Server-only proxy management functions

proxyon() {
    _cyan "Enable server proxy (remote environment)..."

    local clash_dir="$HOME/.config/clash"
    local clash_binary="$clash_dir/clash"
    local config_file="$clash_dir/subscription.yaml"
    local fallback_config="$clash_dir/config.yaml"
    local log_file="$clash_dir/clash.log"

    if [[ ! -d "$clash_dir" ]]; then
        _red "Clash directory does not exist: $clash_dir"
        _yellow "Please create the directory and place the clash binary and config file"
        return 1
    fi

    if [[ ! -f "$clash_binary" ]]; then
        _red "Clash binary not found: $clash_binary"
        _yellow "Download clash binary to $clash_binary"
        _yellow "Download: https://github.com/Dreamacro/clash/releases"
        return 1
    fi

    if [[ ! -x "$clash_binary" ]]; then
        _yellow "Setting clash binary as executable..."
        chmod +x "$clash_binary" || {
            _red "Cannot set execute permission, check file permissions"
            return 1
        }
    fi

    local selected_config=""
    if [[ -f "$config_file" ]]; then
        selected_config="$config_file"
        _cyan "Using config file: subscription.yaml"
    elif [[ -f "$fallback_config" ]]; then
        selected_config="$fallback_config"
        _cyan "Using fallback config file: config.yaml"
    else
        _red "No config file found:"
        echo "   - $config_file"
        echo "   - $fallback_config"
        _yellow "Ensure at least one config file exists"
        return 1
    fi

    if pgrep -f "clash.*$(basename "$selected_config")" >/dev/null 2>&1; then
        _yellow "Clash process already running"
        _yellow "Use 'proxyoff' to stop or 'proxystatus' to check status"
        return 1
    fi

    _cyan "Starting clash process..."
    cd "$clash_dir" || { _red "Cannot change to clash directory"; return 1; }

    if [[ -f "clash.log" ]]; then
        rm -f "clash.log" 2>/dev/null
    fi

    nohup ./clash -f "$(basename "$selected_config")" > clash.log 2>&1 &
    local clash_pid=$!

    sleep 2

    if ! kill -0 "$clash_pid" 2>/dev/null; then
        _red "Clash process failed to start"
        _yellow "Check log file for details: $log_file"
        if [[ -f "$log_file" ]]; then
            _cyan "Recent log:"
            tail -10 "$log_file"
        fi
        return 1
    fi

    _green "Clash process started (PID: $clash_pid)"

    local http_port="7890"
    local socks_port="7891"

    if command -v grep >/dev/null 2>&1 && command -v awk >/dev/null 2>&1; then
        local parsed_http_port=$(grep -E "^port:" "$selected_config" 2>/dev/null | awk '{print $2}' | tr -d '"' | head -1)
        if [[ -n "$parsed_http_port" ]] && [[ "$parsed_http_port" =~ ^[0-9]+$ ]]; then
            http_port="$parsed_http_port"
        fi
        local parsed_socks_port=$(grep -E "^socks-port:" "$selected_config" 2>/dev/null | awk '{print $2}' | tr -d '"' | head -1)
        if [[ -n "$parsed_socks_port" ]] && [[ "$parsed_socks_port" =~ ^[0-9]+$ ]]; then
            socks_port="$parsed_socks_port"
        fi
    fi

    export http_proxy="http://127.0.0.1:$http_port"
    export https_proxy="http://127.0.0.1:$http_port"
    export all_proxy="socks5://127.0.0.1:$socks_port"
    export HTTP_PROXY="$http_proxy"
    export HTTPS_PROXY="$https_proxy"
    export ALL_PROXY="$all_proxy"
    export no_proxy="localhost,127.0.0.1,10.0.0.0/8,192.168.0.0/16,172.16.0.0/12"
    export NO_PROXY="$no_proxy"

    _cyan "Proxy environment variables set:"
    echo "   HTTP proxy: $http_proxy"
    echo "   HTTPS proxy: $https_proxy"
    echo "   SOCKS proxy: $all_proxy"

    _cyan "Testing proxy connection..."
    if command -v curl >/dev/null 2>&1; then
        local test_result=$(curl -s --connect-timeout 10 --proxy "$http_proxy" httpbin.org/ip 2>/dev/null || echo "failed")
        if [[ "$test_result" != "failed" ]]; then
            _green "Proxy connection test successful"
        else
            _yellow "Proxy connection test failed, but process started"
            _yellow "Check config file and network"
        fi
    else
        _yellow "curl not available, skipping connection test"
    fi

    _green "Server proxy enabled"
    _cyan "Use 'proxystatus' to check status, 'proxyoff' to stop proxy"
}

proxyoff() {
    _cyan "Stop server proxy (remote environment)..."

    local clash_dir="$HOME/.config/clash"
    local stopped_any=false

    local clash_pids=$(pgrep -f "clash.*\.(yaml|yml)" 2>/dev/null)

    if [[ -n "$clash_pids" ]]; then
        _cyan "Stopping clash process..."
        for pid in $clash_pids; do
            if kill -0 "$pid" 2>/dev/null; then
                echo "   Stopping PID: $pid"
                kill "$pid" 2>/dev/null
                stopped_any=true
                local count=0
                while kill -0 "$pid" 2>/dev/null && [[ $count -lt 10 ]]; do
                    sleep 1
                    ((count++))
                done
                if kill -0 "$pid" 2>/dev/null; then
                    echo "   Force killing PID: $pid"
                    kill -9 "$pid" 2>/dev/null
                fi
            fi
        done
    else
        _yellow "No running clash process found"
    fi

    _cyan "Cleaning proxy environment variables..."
    unset http_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY no_proxy NO_PROXY

    local log_file="$clash_dir/clash.log"
    if [[ -f "$log_file" ]]; then
        _cyan "Removing log file..."
        rm -f "$log_file" 2>/dev/null && _green "Log file deleted: $log_file" || _yellow "Cannot delete log file: $log_file"
    fi

    if [[ "$stopped_any" == true ]]; then
        _green "Clash process stopped"
    fi
    _green "Proxy environment variables cleaned"

    if pgrep -f "clash.*\.(yaml|yml)" >/dev/null 2>&1; then
        _yellow "Some clash processes are still running, please check manually:"
        pgrep -f "clash.*\.(yaml|yml)" | while read -r pid; do
            echo "   PID: $pid - $(ps -p "$pid" -o comm= 2>/dev/null || echo 'unknown')"
        done
    else
        _green "All clash processes stopped"
    fi
}
{{- end }}