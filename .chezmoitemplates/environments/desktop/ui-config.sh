# ========================================
# 桌面UI相关配置
# ========================================
# 主题、字体、GUI工具和界面相关设置

# 文件管理器别名
if command -v nautilus >/dev/null 2>&1; then
    alias fm='nautilus'
    alias files='nautilus'
elif command -v dolphin >/dev/null 2>&1; then
    alias fm='dolphin'
    alias files='dolphin'
{{- if eq .chezmoi.os "darwin" }}
elif command -v open >/dev/null 2>&1; then
    alias fm='open'
    alias files='open'
{{- end }}
fi

# 文本编辑器快捷方式
if command -v code >/dev/null 2>&1; then
    alias edit='code'
    alias c='code .'
    alias code.='code .'
fi

# 系统监视器快捷方式
{{- if eq .chezmoi.os "linux" }}
if command -v gnome-system-monitor >/dev/null 2>&1; then
    alias sysmon='gnome-system-monitor'
    alias taskman='gnome-system-monitor'
elif command -v ksysguard >/dev/null 2>&1; then
    alias sysmon='ksysguard'
    alias taskman='ksysguard'
fi
{{- else if eq .chezmoi.os "darwin" }}
alias sysmon='open -a "Activity Monitor"'
alias taskman='open -a "Activity Monitor"'
{{- end }}

# 截图工具
{{- if eq .chezmoi.os "linux" }}
if command -v gnome-screenshot >/dev/null 2>&1; then
    alias screenshot='gnome-screenshot'
    alias ss='gnome-screenshot -a'  # 区域截图
elif command -v spectacle >/dev/null 2>&1; then
    alias screenshot='spectacle'
    alias ss='spectacle -r'  # 区域截图
elif command -v flameshot >/dev/null 2>&1; then
    alias screenshot='flameshot gui'
    alias ss='flameshot gui'
fi
{{- else if eq .chezmoi.os "darwin" }}
alias screenshot='screencapture'
alias ss='screencapture -s'  # 选择截图
{{- end }}

# 快速应用程序启动器
{{- if eq .chezmoi.os "linux" }}
launch_app() {
    local app="$1"
    if command -v "$app" >/dev/null 2>&1; then
        nohup "$app" >/dev/null 2>&1 &
        disown
        echo "🚀 已启动: $app"
    else
        echo "❌ 应用程序未找到: $app"
        return 1
    fi
}
{{- end }}
