#!/bin/bash

# compinit 冲突修复脚本
# 根据诊断结果修复 compinit 多次调用的问题

echo "🔧 修复 compinit 冲突问题..."
echo "================================"

# 检查常见的 compinit 调用位置并修复

# 1. 检查 ~/.zshrc 文件
if [ -f ~/.zshrc ]; then
    echo "🔍 检查 ~/.zshrc 中的 compinit 调用"
    
    if grep -q "compinit" ~/.zshrc; then
        echo "⚠️  在 ~/.zshrc 中发现 compinit 调用"
        echo "📝 备份 ~/.zshrc"
        cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
        
        # 注释掉 compinit 相关行
        sed -i.tmp 's/^[[:space:]]*autoload -Uz compinit/# &/' ~/.zshrc
        sed -i.tmp 's/^[[:space:]]*compinit/# &/' ~/.zshrc
        rm ~/.zshrc.tmp
        
        echo "✅ 已注释掉 ~/.zshrc 中的 compinit 调用"
    else
        echo "✅ ~/.zshrc 中没有发现 compinit 调用"
    fi
fi

# 2. 检查其他可能的配置文件
config_files=(
    "~/.zprofile"
    "~/.zlogin"
    "/etc/zsh/zshrc"
    "/etc/zshrc"
)

for config_file in "${config_files[@]}"; do
    expanded_file=$(eval echo "$config_file")
    if [ -f "$expanded_file" ]; then
        echo "🔍 检查 $expanded_file"
        if grep -q "compinit" "$expanded_file" 2>/dev/null; then
            echo "⚠️  在 $expanded_file 中发现 compinit 调用"
            echo "📝 请手动检查并修复此文件中的 compinit 调用"
        else
            echo "✅ $expanded_file 中没有发现 compinit 调用"
        fi
    fi
done

# 3. 检查 Zim 配置
if [ -f "$ZIM_HOME/init.zsh" ]; then
    echo "🔍 检查 Zim 初始化脚本"
    echo "✅ Zim 初始化脚本存在: $ZIM_HOME/init.zsh"
else
    echo "❌ Zim 初始化脚本不存在，可能需要重新安装 Zim"
fi

# 4. 验证 skip_global_compinit 设置
if grep -q "skip_global_compinit=1" ~/.zshenv 2>/dev/null; then
    echo "✅ skip_global_compinit=1 已设置"
else
    echo "⚠️  添加 skip_global_compinit=1 到 ~/.zshenv"
    echo "skip_global_compinit=1" >> ~/.zshenv
fi

echo ""
echo "🎯 修复建议："
echo "1. 确保只有 Zim 的 completion 模块调用 compinit"
echo "2. 移除其他地方的 compinit 调用"
echo "3. 使用 'exec zsh' 而不是 'source ~/.zshrc' 来重新加载配置"
echo "4. 运行清理脚本移除诊断代码"