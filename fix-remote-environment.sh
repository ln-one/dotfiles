#!/bin/bash
# ========================================
# 修复远程环境配置脚本
# ========================================
# 强制重新初始化chezmoi以正确识别远程环境

set -euo pipefail

echo "🔧 修复远程环境配置..."

# 检查是否在SSH环境中
if [[ -n "${SSH_CONNECTION:-}" ]] || [[ -n "${SSH_CLIENT:-}" ]] || [[ -n "${SSH_TTY:-}" ]]; then
    echo "✅ 检测到SSH连接环境"
else
    echo "⚠️  未检测到SSH连接，但继续执行"
fi

# 备份当前配置
echo "📦 备份当前配置..."
if [[ -f "$HOME/.config/chezmoi/chezmoi.toml" ]]; then
    cp "$HOME/.config/chezmoi/chezmoi.toml" "$HOME/.config/chezmoi/chezmoi.toml.backup.$(date +%Y%m%d_%H%M%S)"
    echo "✅ 已备份 chezmoi.toml"
fi

# 强制重新生成配置
echo "🔄 重新生成chezmoi配置..."
chezmoi init --force

# 检查环境是否正确识别
echo "🔍 检查环境识别..."
current_env=$(chezmoi data | grep '"environment":' | cut -d'"' -f4)
echo "当前环境类型: $current_env"

if [[ "$current_env" == "remote" ]]; then
    echo "✅ 环境正确识别为remote"
else
    echo "❌ 环境仍未正确识别，尝试手动设置..."
    
    # 手动创建配置文件
    mkdir -p "$HOME/.config/chezmoi"
    cat > "$HOME/.config/chezmoi/chezmoi.toml" << 'EOF'
[data]
environment = "remote"

[data.features]
enable_starship = true
enable_zoxide = true
enable_fzf = true
enable_zim = true
enable_evalcache = true
enable_proxy = true
enable_1password = false

[data.user]
name = "ln1"
email = "ln1.opensource@gmail.com"
EOF
    
    echo "✅ 手动设置环境为remote"
fi

# 重新应用配置
echo "🚀 重新应用配置..."
chezmoi apply

echo "🎉 修复完成！请重新加载shell: source ~/.zshrc"