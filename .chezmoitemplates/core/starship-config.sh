# ========================================
# Starship 提示符配置模板 (静态版本)
# ========================================
# 跨 Shell 的现代化提示符配置，初始化由 evalcache-config-static.sh 统一处理

{{- if .features.enable_starship }}

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