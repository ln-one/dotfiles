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
{{- end }}