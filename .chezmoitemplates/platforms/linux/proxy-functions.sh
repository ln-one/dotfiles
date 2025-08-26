# ========================================
# Proxy Management Functions (Linux Only)
# ========================================
# Clash 代理管理功能 (迁移自原 system-tools.sh)
# 仅在 Linux 桌面环境加载，macOS 不使用此功能

{{- if and (eq .chezmoi.os "linux") (eq .environment "desktop") }}
# Only load proxy functions on Linux desktop environments

# Clash 代理配置
CLASH_DIR="${CLASH_DIR:-$HOME/.config/clash}"
PROXY_HOST="${PROXY_HOST:-127.0.0.1}"
PROXY_HTTP_PORT="${PROXY_HTTP_PORT:-7890}"
PROXY_SOCKS_PORT="${PROXY_SOCKS_PORT:-7891}"

# Enable proxy (启动 Clash + 设置环境变量)
proxyon() {
    echo "🔗 启用代理..."
    
    # 1. 启动 Clash 代理服务
    if [[ -n "$CLASH_DIR" ]] && [[ -d "$CLASH_DIR" ]] && [[ -f "$CLASH_DIR/clash" ]]; then
        echo "启动 Clash 代理服务..."
        (cd "$CLASH_DIR" && ./clash -d . &)
        sleep 2  # 等待 Clash 启动
        
        # 设置环境变量代理
        export http_proxy="http://${PROXY_HOST}:${PROXY_HTTP_PORT}"
        export https_proxy="http://${PROXY_HOST}:${PROXY_HTTP_PORT}"
        export all_proxy="socks5://${PROXY_HOST}:${PROXY_SOCKS_PORT}"
        export HTTP_PROXY="$http_proxy"
        export HTTPS_PROXY="$https_proxy"
        export ALL_PROXY="$all_proxy"
        export no_proxy="localhost,127.0.0.1,10.0.0.0/8,192.168.0.0/16,172.16.0.0/12"
        export NO_PROXY="$no_proxy"
        
{{- if lookPath "gsettings" }}
        # 配置 GNOME 系统代理
        if command -v gsettings >/dev/null 2>&1; then
            echo "配置 GNOME 系统代理..."
            gsettings set org.gnome.system.proxy mode "manual" 2>/dev/null || true
            gsettings set org.gnome.system.proxy.http host "$PROXY_HOST" 2>/dev/null || true
            gsettings set org.gnome.system.proxy.http port "$PROXY_HTTP_PORT" 2>/dev/null || true
            gsettings set org.gnome.system.proxy.https host "$PROXY_HOST" 2>/dev/null || true
            gsettings set org.gnome.system.proxy.https port "$PROXY_HTTP_PORT" 2>/dev/null || true
            gsettings set org.gnome.system.proxy.socks host "$PROXY_HOST" 2>/dev/null || true
            gsettings set org.gnome.system.proxy.socks port "$PROXY_SOCKS_PORT" 2>/dev/null || true
        fi
{{- end }}
        
        # 启动 Dropbox (如果可用)
        if command -v dropbox >/dev/null 2>&1; then
            echo "启动 Dropbox..."
            dropbox start -i 2>/dev/null || true
        fi
        
        echo "✅ 代理已启用 (Clash + 环境变量)"
    else
        echo "⚠️  Clash 未找到或未配置 (CLASH_DIR: $CLASH_DIR)"
        echo "仅设置环境变量代理..."
        
        # 仅设置环境变量代理
        export http_proxy="http://${PROXY_HOST}:${PROXY_HTTP_PORT}"
        export https_proxy="http://${PROXY_HOST}:${PROXY_HTTP_PORT}"
        export all_proxy="socks5://${PROXY_HOST}:${PROXY_SOCKS_PORT}"
        export HTTP_PROXY="$http_proxy"
        export HTTPS_PROXY="$https_proxy"
        export ALL_PROXY="$all_proxy"
        export no_proxy="localhost,127.0.0.1,10.0.0.0/8,192.168.0.0/16,172.16.0.0/12"
        export NO_PROXY="$no_proxy"
        
        echo "✅ 环境变量代理已设置"
    fi
}

# Disable proxy (关闭 Clash + 清除环境变量)
proxyoff() {
    echo "🔗 关闭代理..."
    
    # 1. 关闭 Clash 进程
    if pgrep clash >/dev/null 2>&1; then
        echo "关闭 Clash 进程..."
        pkill clash
        echo "Clash 进程已终止"
    fi
    
    # 2. 清除环境变量
    unset http_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY no_proxy NO_PROXY
    
{{- if lookPath "gsettings" }}
    # 3. 禁用 GNOME 系统代理
    if command -v gsettings >/dev/null 2>&1; then
        echo "禁用 GNOME 系统代理..."
        gsettings set org.gnome.system.proxy mode "none" 2>/dev/null || true
    fi
{{- end }}
    
    # 4. 停止 Dropbox (如果可用)
    if command -v dropbox >/dev/null 2>&1; then
        echo "停止 Dropbox..."
        dropbox stop 2>/dev/null || true
    fi
    
    echo "✅ 代理已关闭"
}

# Show proxy status
proxystatus() {
    echo "🔗 代理状态检查:"
    echo ""
    
    # 环境变量状态
    echo "📋 环境变量:"
    echo "  http_proxy: ${http_proxy:-未设置}"
    echo "  https_proxy: ${https_proxy:-未设置}"
    echo "  all_proxy: ${all_proxy:-未设置}"
    echo ""
    
    # Clash 进程状态
    if pgrep clash >/dev/null 2>&1; then
        echo "🟢 Clash: 运行中 (PID: $(pgrep clash))"
    else
        echo "🔴 Clash: 未运行"
    fi
    
{{- if lookPath "gsettings" }}
    # GNOME 代理状态
    if command -v gsettings >/dev/null 2>&1; then
        local gnome_proxy_mode=$(gsettings get org.gnome.system.proxy mode 2>/dev/null | tr -d "'")
        echo "🖥️  GNOME 代理: ${gnome_proxy_mode:-未知}"
    fi
{{- end }}
    
    # Dropbox 状态
    if command -v dropbox >/dev/null 2>&1; then
        local dropbox_status=$(dropbox status 2>/dev/null | head -1 || echo "未知")
        echo "📦 Dropbox: $dropbox_status"
    fi
    
    # 网络连接测试
    echo ""
    echo "🌐 连接测试:"
    if command -v curl >/dev/null 2>&1; then
        if curl -s --connect-timeout 3 httpbin.org/ip >/dev/null 2>&1; then
            echo "🟢 网络连接: 正常"
        else
            echo "🔴 网络连接: 异常"
        fi
    else
        echo "ℹ️  curl 未安装，无法测试连接"
    fi
    
    # 配置信息
    echo ""
    echo "⚙️  配置信息:"
    echo "  CLASH_DIR: ${CLASH_DIR:-未设置}"
    echo "  PROXY_HOST: ${PROXY_HOST}"
    echo "  HTTP_PORT: ${PROXY_HTTP_PORT}"
    echo "  SOCKS_PORT: ${PROXY_SOCKS_PORT}"
}

{{- else }}
# 非Linux桌面环境不加载代理功能
# 提供占位函数以避免命令未找到错误
proxyon() {
    echo "ℹ️  代理管理功能仅在 Linux 桌面环境中可用"
}

proxyoff() {
    echo "ℹ️  代理管理功能仅在 Linux 桌面环境中可用"
}

proxyai() {
    echo "ℹ️  代理管理功能仅在 Linux 桌面环境中可用"
}

proxystatus() {
    echo "ℹ️  代理管理功能仅在 Linux 桌面环境中可用"
}
{{- end }}