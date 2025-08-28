# ========================================
# Desktop Environment Static Configuration
# ========================================
# All features are controlled by central feature configuration

# Desktop Notification
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