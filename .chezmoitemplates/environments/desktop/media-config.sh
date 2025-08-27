# ========================================
# 桌面媒体和娱乐配置
# ========================================
# 媒体播放、娱乐和多媒体工具配置

# 媒体播放器别名
{{- if eq .chezmoi.os "linux" }}
if command -v vlc >/dev/null 2>&1; then
    alias video='vlc'
    alias media='vlc'
fi

if command -v mpv >/dev/null 2>&1; then
    alias play='mpv'
fi

if command -v rhythmbox >/dev/null 2>&1; then
    alias music='rhythmbox'
elif command -v amarok >/dev/null 2>&1; then
    alias music='amarok'
fi

{{- else if eq .chezmoi.os "darwin" }}
alias video='open -a "VLC" || open -a "QuickTime Player"'
alias music='open -a "Music"'
alias media='open -a "VLC"'
{{- end }}

# 音频控制函数
volume_control() {
    local action="$1"
    local amount="${2:-5}"
    
    case "$action" in
        up|+)
{{- if eq .chezmoi.os "linux" }}
            if command -v amixer >/dev/null 2>&1; then
                amixer set Master "${amount}%+"
            elif command -v pactl >/dev/null 2>&1; then
                pactl set-sink-volume @DEFAULT_SINK@ "+${amount}%"
            fi
{{- else if eq .chezmoi.os "darwin" }}
            osascript -e "set volume output volume (output volume of (get volume settings) + $amount)"
{{- end }}
            ;;
        down|-)
{{- if eq .chezmoi.os "linux" }}
            if command -v amixer >/dev/null 2>&1; then
                amixer set Master "${amount}%-"
            elif command -v pactl >/dev/null 2>&1; then
                pactl set-sink-volume @DEFAULT_SINK@ "-${amount}%"
            fi
{{- else if eq .chezmoi.os "darwin" }}
            osascript -e "set volume output volume (output volume of (get volume settings) - $amount)"
{{- end }}
            ;;
        mute)
{{- if eq .chezmoi.os "linux" }}
            if command -v amixer >/dev/null 2>&1; then
                amixer set Master toggle
            elif command -v pactl >/dev/null 2>&1; then
                pactl set-sink-mute @DEFAULT_SINK@ toggle
            fi
{{- else if eq .chezmoi.os "darwin" }}
            osascript -e "set volume with output muted"
{{- end }}
            ;;
        *)
            echo "用法: volume_control {up|down|mute} [amount]"
            return 1
            ;;
    esac
}

# 音量控制别名
alias vol='volume_control'
alias mute='volume_control mute'

# 屏幕录制功能
{{- if eq .chezmoi.os "linux" }}
record_screen() {
    local output="${1:-screen_recording_$(date +%Y%m%d_%H%M%S).mp4}"
    
    if command -v ffmpeg >/dev/null 2>&1; then
        echo "🎬 开始屏幕录制: $output"
        echo "按 Ctrl+C 停止录制"
        ffmpeg -f x11grab -s $(xrandr | grep '*' | awk '{print $1}' | head -1) -i :0.0 "$output"
    elif command -v recordmydesktop >/dev/null 2>&1; then
        echo "🎬 开始屏幕录制: $output"
        recordmydesktop -o "$output"
    else
        echo "❌ 未找到屏幕录制工具 (ffmpeg 或 recordmydesktop)"
        return 1
    fi
}

{{- else if eq .chezmoi.os "darwin" }}
record_screen() {
    local output="${1:-screen_recording_$(date +%Y%m%d_%H%M%S).mov}"
    echo "🎬 开始屏幕录制: $output"
    echo "按 Ctrl+C 停止录制"
    ffmpeg -f avfoundation -i "1:0" "$output" 2>/dev/null
}
{{- end }}

# 图片查看器
{{- if eq .chezmoi.os "linux" }}
if command -v eog >/dev/null 2>&1; then
    alias view='eog'
elif command -v gwenview >/dev/null 2>&1; then
    alias view='gwenview'
elif command -v feh >/dev/null 2>&1; then
    alias view='feh'
fi

{{- else if eq .chezmoi.os "darwin" }}
alias view='open -a Preview'
{{- end }}
