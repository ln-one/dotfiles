# ========================================
# Starship 提示符配置模板 (静态版本)
# ========================================
# 跨 Shell 的现代化提示符初始化，无运行时检测

{{- if .features.enable_starship }}

# Starship 初始化 (静态生成)
# 注意: evalcache 配置在 evalcache-config.sh 中处理
# 这里保留回退逻辑，当 evalcache 不可用时使用
{{- if eq (base .chezmoi.targetFile) ".zshrc" }}
    # 如果 evalcache 可用，在 evalcache-config.sh 中处理
    # 否则使用标准 eval
    {{- if not .features.enable_evalcache }}
    eval "$(starship init zsh)"
    {{- end }}
{{- else if eq (base .chezmoi.targetFile) ".bashrc" }}
    {{- if not .features.enable_evalcache }}
    eval "$(starship init bash)"
    {{- end }}
{{- end }}

# 设置配置文件路径
export STARSHIP_CONFIG="$HOME/.config/starship.toml"

{{- if eq .environment "remote" }}
# 远程环境优化: 禁用一些耗时的模块
export STARSHIP_CACHE="$HOME/.cache/starship"
    # 创建缓存目录
mkdir -p "$HOME/.cache/starship"
{{- end }}

{{- else }}
# Starship 功能已禁用
{{- end }}