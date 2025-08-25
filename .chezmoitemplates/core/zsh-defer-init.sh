#!/usr/bin/env zsh
# ========================================
# zsh-defer 初始化配置
# ========================================
# 初始化 zsh-defer 并设置延迟加载的命令

# 确保只在 zsh 中执行
if [[ -n "${ZSH_VERSION}" ]]; then
    # 初始化 zsh-defer (如果通过 Zim 安装)
    if [[ -f "${ZIM_HOME}/modules/zsh-defer/zsh-defer.plugin.zsh" ]]; then
        source "${ZIM_HOME}/modules/zsh-defer/zsh-defer.plugin.zsh"
        
        # 验证 zsh-defer 是否可用 (静默检查)
        if ! command -v zsh-defer >/dev/null 2>&1; then
            echo "❌ zsh-defer failed to initialize" >&2
        fi
    else
        echo "⚠️  zsh-defer not found, please run 'zimfw install'"
    fi
fi