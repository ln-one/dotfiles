# ========================================
# Starship 提示符配置模板
# ========================================
# 跨 Shell 的现代化提示符初始化

{{- if .features.enable_starship }}

# 检查 Starship 是否已安装
if command -v starship >/dev/null 2>&1; then
    # 初始化 Starship (检测当前 Shell)
    if [ -n "$ZSH_VERSION" ]; then
        eval "$(starship init zsh)"
    elif [ -n "$BASH_VERSION" ]; then
        eval "$(starship init bash)"
    fi
    
    # 设置配置文件路径
    export STARSHIP_CONFIG="$HOME/.config/starship.toml"
    
    {{- if eq .environment "remote" }}
    # 远程环境优化: 禁用一些耗时的模块
    export STARSHIP_CACHE="$HOME/.cache/starship"
    {{- end }}
    
else
    echo "⚠️  Starship 未安装，使用默认提示符"
fi

{{- else }}
# Starship 功能已禁用
{{- end }}