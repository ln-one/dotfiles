#!/usr/bin/env zsh
# ========================================
# zsh-defer 初始化配置 (静态版本)
# ========================================
# 初始化 zsh-defer 并设置延迟加载的命令，无运行时检测

{{- if .features.enable_zsh_defer }}
# 确保只在 zsh 中执行
if [[ -n "${ZSH_VERSION}" ]]; then
    # 初始化 zsh-defer (如果通过 Zim 安装)
    if [[ -f "${ZIM_HOME}/modules/zsh-defer/zsh-defer.plugin.zsh" ]]; then
        source "${ZIM_HOME}/modules/zsh-defer/zsh-defer.plugin.zsh"
    else
        echo "⚠️  zsh-defer not found, please run 'zimfw install'"
    fi
fi
{{- else }}
# zsh-defer 功能已禁用，跳过初始化
{{- end }}