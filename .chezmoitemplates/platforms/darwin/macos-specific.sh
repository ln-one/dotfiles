# ========================================
# macOS Specific Configuration
# ========================================
# macOS 平台特定的配置和功能
# 仅在 macOS 环境中加载

{{- if eq .chezmoi.os "darwin" }}
# Homebrew 配置优化
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1
# macOS 特定的颜色配置
export LSCOLORS=ExFxCxDxBxegedabagacad
alias memory='system_profiler SPMemoryDataType'
{{- end }}