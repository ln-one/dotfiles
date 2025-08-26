# ========================================
# Starship 提示符配置模板
# ========================================
# 跨 Shell 的现代化提示符初始化

{{- if .features.enable_starship }}

# 检查 Starship 是否已安装
if command -v starship >/dev/null 2>&1; then
    # 初始化 Starship (检测当前 Shell)
    # 注意: evalcache 配置在 evalcache-config.sh 中处理
    # 这里保留回退逻辑，当 evalcache 不可用时使用
    if [ -n "$ZSH_VERSION" ]; then
        # 如果 evalcache 可用，在 evalcache-config.sh 中处理
        # 否则使用标准 eval
        if ! command -v _evalcache >/dev/null 2>&1; then
            eval "$(starship init zsh)"
        fi
    elif [ -n "$BASH_VERSION" ]; then
        if ! command -v _evalcache >/dev/null 2>&1; then
            eval "$(starship init bash)"
        fi
    fi
    
    # 设置配置文件路径
    export STARSHIP_CONFIG="$HOME/.config/starship.toml"
    
    {{- if eq .environment "remote" }}
    # 远程环境优化: 禁用一些耗时的模块
    export STARSHIP_CACHE="$HOME/.cache/starship"
    # 创建缓存目录
    mkdir -p "$HOME/.cache/starship"
    {{- end }}
    
else
    echo "⚠️  Starship 未安装，使用默认提示符"
fi

{{- else }}
# Starship 功能已禁用
{{- end }}