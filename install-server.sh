#!/bin/bash
# 阿里云ECS服务器简化安装脚本

set -e

echo "🚀 开始在阿里云ECS上安装chezmoi配置..."

# 1. 安装基础工具
sudo apt update
sudo apt install -y git curl wget zsh

# 2. 安装chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)"

# 3. 初始化配置 (替换为你的实际仓库地址)
chezmoi init https://github.com/ln-one/dotfiles-chezmoi.git

# 4. 应用配置
chezmoi apply

# 5. 切换到zsh
chsh -s $(which zsh)

echo "✅ 安装完成！重新登录后生效"
echo "💡 配置会自动检测SSH环境并使用轻量化模式"