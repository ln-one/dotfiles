# ========================================
# 桌面环境静态配置
# ========================================
# 完全静态的桌面环境配置，无运行时检测
# 所有功能由中央功能配置决定

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
