# ========================================
# 桌面特定工具配置
# ========================================
# 桌面环境特有的开发工具和应用程序配置

# Docker Desktop集成
{{- if eq .chezmoi.os "darwin" }}
if [[ -d "/Applications/Docker.app" ]]; then
    export DOCKER_HOST="unix://$HOME/.docker/run/docker.sock"
fi
{{- else if eq .chezmoi.os "linux" }}
# Linux Docker配置
# 注意：如需要，请将用户添加到docker组：sudo usermod -aG docker $USER
{{- end }}

# 常用Linux应用程序快捷方式
{{- if eq .chezmoi.os "linux" }}
if command -v firefox >/dev/null 2>&1; then
    alias browser='launch_app firefox'
fi

if command -v thunderbird >/dev/null 2>&1; then
    alias mail='launch_app thunderbird'
fi

if command -v libreoffice >/dev/null 2>&1; then
    alias office='launch_app libreoffice'
fi

{{- else if eq .chezmoi.os "darwin" }}
# macOS应用程序启动器
launch_app() {
    local app="$1"
    if [[ -d "/Applications/$app.app" ]]; then
        open -a "$app"
        echo "🚀 已启动: $app"
    else
        echo "❌ 应用程序未找到: $app"
        return 1
    fi
}

# 常用macOS应用程序
alias browser='open -a "Firefox" || open -a "Safari"'
alias mail='open -a "Mail"'
alias office='open -a "Microsoft Word" || open -a "Pages"'
{{- end }}

# 快速项目打开器
open_project() {
    local project_dir="$1"
    
    if [[ -z "$project_dir" ]]; then
        echo "用法: open_project <目录>"
        return 1
    fi
    
    if [[ ! -d "$project_dir" ]]; then
        echo "❌ 目录未找到: $project_dir"
        return 1
    fi
    
    cd "$project_dir" || return 1
    
    # 如果可用，在VS Code中打开项目
    if command -v code >/dev/null 2>&1; then
        code . &
        echo "📁 在VS Code中打开项目: $project_dir"
    fi
    
    # 如果存在，打开文件管理器
    if command -v nautilus >/dev/null 2>&1; then
        nautilus . &
    elif command -v dolphin >/dev/null 2>&1; then
        dolphin . &
{{- if eq .chezmoi.os "darwin" }}
    elif command -v open >/dev/null 2>&1; then
        open .
{{- end }}
    fi
}
