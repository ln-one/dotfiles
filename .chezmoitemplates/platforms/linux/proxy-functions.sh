# ========================================
# Proxy Management Functions (Linux Only)
# ========================================

{{- if and (eq .chezmoi.os "linux") (not (env "SSH_CONNECTION")) }}
# Only load proxy functions on Linux desktop environments

CLASH_DIR="${CLASH_DIR:-$HOME/.config/clash}"
PROXY_HOST="${PROXY_HOST:-127.0.0.1}"
PROXY_HTTP_PORT="${PROXY_HTTP_PORT:-7890}"
PROXY_SOCKS_PORT="${PROXY_SOCKS_PORT:-7891}"

# Color helpers
_red()   { printf '\033[0;31m%s\033[0m\n' "$*"; }
_green() { printf '\033[0;32m%s\033[0m\n' "$*"; }
_yellow(){ printf '\033[0;33m%s\033[0m\n' "$*"; }
_blue()  { printf '\033[0;34m%s\033[0m\n' "$*"; }
_cyan()  { printf '\033[0;36m%s\033[0m\n' "$*"; }
_bold()  { printf '\033[1m%s\033[0m\n' "$*"; }

# Enable proxy (start Clash + set environment variables)
proxyon() {
    _cyan "Enabling proxy..."

    # Start Clash proxy service
    if [[ -n "$CLASH_DIR" ]] && [[ -d "$CLASH_DIR" ]] && [[ -f "$CLASH_DIR/clash" ]]; then
        _cyan "Starting Clash proxy service..."
        (cd "$CLASH_DIR" && ./clash -d . &)
        sleep 2

        # Set environment variable proxies
        export http_proxy="http://${PROXY_HOST}:${PROXY_HTTP_PORT}"
        export https_proxy="http://${PROXY_HOST}:${PROXY_HTTP_PORT}"
        export all_proxy="socks5://${PROXY_HOST}:${PROXY_SOCKS_PORT}"
        export HTTP_PROXY="$http_proxy"
        export HTTPS_PROXY="$https_proxy"
        export ALL_PROXY="$all_proxy"
        export no_proxy="localhost,127.0.0.1,10.0.0.0/8,192.168.0.0/16,172.16.0.0/12"
        export NO_PROXY="$no_proxy"

{{- if .features.enable_gsettings }}
        # Configure GNOME system proxy (static)
        _cyan "Configuring GNOME system proxy..."
        gsettings set org.gnome.system.proxy mode "manual" 2>/dev/null || true
        gsettings set org.gnome.system.proxy.http host "$PROXY_HOST" 2>/dev/null || true
        gsettings set org.gnome.system.proxy.http port "$PROXY_HTTP_PORT" 2>/dev/null || true
        gsettings set org.gnome.system.proxy.https host "$PROXY_HOST" 2>/dev/null || true
        gsettings set org.gnome.system.proxy.https port "$PROXY_HTTP_PORT" 2>/dev/null || true
        gsettings set org.gnome.system.proxy.socks host "$PROXY_HOST" 2>/dev/null || true
        gsettings set org.gnome.system.proxy.socks port "$PROXY_SOCKS_PORT" 2>/dev/null || true
{{- end }}

        # Start Dropbox if enabled
        {{- if .features.enable_dropbox }}
        _cyan "Starting Dropbox..."
        dropbox start -i 2>/dev/null || true
        {{- end }}

        _green "Proxy enabled (Clash + environment variables)"
    else
        _yellow "Clash not found or not configured (CLASH_DIR: $CLASH_DIR)"
        _cyan "Setting environment variable proxies only..."

        export http_proxy="http://${PROXY_HOST}:${PROXY_HTTP_PORT}"
        export https_proxy="http://${PROXY_HOST}:${PROXY_HTTP_PORT}"
        export all_proxy="socks5://${PROXY_HOST}:${PROXY_SOCKS_PORT}"
        export HTTP_PROXY="$http_proxy"
        export HTTPS_PROXY="$https_proxy"
        export ALL_PROXY="$all_proxy"
        export no_proxy="localhost,127.0.0.1,10.0.0.0/8,192.168.0.0/16,172.16.0.0/12"
        export NO_PROXY="$no_proxy"

        _green "Environment variable proxies set"
    fi
}

# Disable proxy (stop Clash + unset environment variables)
proxyoff() {
    _cyan "Disabling proxy..."

    # Stop Clash process
    if pgrep clash >/dev/null 2>&1; then
        _cyan "Stopping Clash process..."
        pkill clash
        _green "Clash process terminated"
    fi

    # Unset environment variables
    unset http_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY no_proxy NO_PROXY

{{- if .features.enable_gsettings }}
    # Disable GNOME system proxy (static)
    _cyan "Disabling GNOME system proxy..."
    gsettings set org.gnome.system.proxy mode "none" 2>/dev/null || true
{{- end }}

    # Stop Dropbox if enabled
    {{- if .features.enable_dropbox }}
    _cyan "Stopping Dropbox..."
    dropbox stop 2>/dev/null || true
    {{- end }}

    _green "Proxy disabled"
}

# Show proxy status
proxystatus() {
    _bold "Proxy status:"
    echo ""

    # Environment variable status
    _cyan "Environment variables:"
    echo "  http_proxy: ${http_proxy:-unset}"
    echo "  https_proxy: ${https_proxy:-unset}"
    echo "  all_proxy: ${all_proxy:-unset}"
    echo ""

    # Clash process status
    if pgrep clash >/dev/null 2>&1; then
        _green "Clash: running (PID: $(pgrep clash))"
    else
        _red "Clash: not running"
    fi

{{- if .features.enable_gsettings }}
    # GNOME proxy status (static)
    local gnome_proxy_mode=$(gsettings get org.gnome.system.proxy mode 2>/dev/null | tr -d "'")
    _cyan "GNOME proxy: ${gnome_proxy_mode:-unknown}"
{{- end }}

    # Dropbox status
    {{- if .features.enable_dropbox }}
    local dropbox_status=$(dropbox status 2>/dev/null | head -1 || echo "unknown")
    _cyan "Dropbox: $dropbox_status"
    {{- end }}

    # Network connectivity test
    echo ""
    _cyan "Connectivity test:"
    {{- if .features.enable_curl }}
    if curl -s --connect-timeout 3 httpbin.org/ip >/dev/null 2>&1; then
        _green "Network: OK"
    else
        _red "Network: Error"
    fi
    {{- else }}
    _yellow "curl not installed, cannot test connectivity"
    {{- end }}

    # Config info
    echo ""
    _cyan "Config info:"
    echo "  CLASH_DIR: ${CLASH_DIR:-unset}"
    echo "  PROXY_HOST: ${PROXY_HOST}"
    echo "  HTTP_PORT: ${PROXY_HTTP_PORT}"
    echo "  SOCKS_PORT: ${PROXY_SOCKS_PORT}"
}

{{- else if eq .chezmoi.os "darwin" }}
# macOS does not load proxy functions, provide stubs to avoid command not found errors
proxyon() {
    _yellow "Proxy management is only available on Linux"
}

proxyoff() {
    _yellow "Proxy management is only available on Linux"
}

proxyai() {
    _yellow "Proxy management is only available on Linux"
}

proxystatus() {
    _yellow "Proxy management is only available on Linux"
}
{{- end }}
