#!/bin/bash

# 修复 compinit 警告的脚本
# 根据 Zim 故障排除指南修复 compinit 被多次调用的问题

echo "🔧 修复 compinit 冲突警告..."
echo "================================"

# 1. 确保 skip_global_compinit=1 在 .zshenv 中设置
echo "📋 检查 skip_global_compinit 设置"
if ! grep -q "skip_global_compinit=1" ~/.zshenv 2>/dev/null; then
    echo "⚠️  添加 skip_global_compinit=1 到 ~/.zshenv"
    echo "skip_global_compinit=1" >> ~/.zshenv
    echo "✅ 已添加 skip_global_compinit=1"
else
    echo "✅ skip_global_compinit=1 已存在"
fi

# 2. 检查并修复可能的重复 compinit 调用
echo ""
echo "🔍 检查可能的 compinit 冲突源"

# 检查 ~/.zshrc 是否有手动的 compinit 调用
if [ -f ~/.zshrc ]; then
    if grep -q "^[[:space:]]*compinit" ~/.zshrc || grep -q "^[[:space:]]*autoload.*compinit" ~/.zshrc; then
        echo "⚠️  在 ~/.zshrc 中发现手动的 compinit 调用"
        echo "📝 备份 ~/.zshrc"
        cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
        
        # 注释掉手动的 compinit 调用
        sed -i.tmp 's/^[[:space:]]*autoload.*compinit/# &/' ~/.zshrc
        sed -i.tmp 's/^[[:space:]]*compinit/# &/' ~/.zshrc
        rm ~/.zshrc.tmp
        
        echo "✅ 已注释掉 ~/.zshrc 中的手动 compinit 调用"
    else
        echo "✅ ~/.zshrc 中没有发现手动的 compinit 调用"
    fi
fi

# 3. 检查其他可能的配置文件
config_files=(
    "$HOME/.zprofile"
    "$HOME/.zlogin"
    "/etc/zsh/zshrc"
    "/etc/zshrc"
)

for config_file in "${config_files[@]}"; do
    if [ -f "$config_file" ]; then
        if grep -q "compinit" "$config_file" 2>/dev/null; then
            echo "⚠️  在 $config_file 中发现 compinit 调用"
            echo "   请手动检查并移除不必要的 compinit 调用"
        fi
    fi
done

# 4. 验证 Zim 配置
echo ""
echo "🔍 验证 Zim 配置"

if [ -n "$ZIM_HOME" ] && [ -f "$ZIM_HOME/init.zsh" ]; then
    echo "✅ Zim 已正确安装: $ZIM_HOME"
    
    # 检查 Zim completion 模块是否存在
    if [ -f "$ZIM_HOME/modules/completion/init.zsh" ]; then
        echo "✅ Zim completion 模块存在"
    else
        echo "⚠️  Zim completion 模块不存在，可能需要重新安装"
    fi
else
    echo "❌ Zim 未正确安装或配置"
fi

# 5. 创建测试脚本来验证修复
echo ""
echo "📝 创建验证脚本"
cat > /tmp/test_zsh_startup.sh << 'EOF'
#!/bin/zsh
# 测试 Zsh 启动是否有 compinit 警告

echo "测试 Zsh 启动..."
exec zsh -c 'echo "Zsh 启动完成，检查上方是否有 compinit 警告"'
EOF

chmod +x /tmp/test_zsh_startup.sh

echo "✅ 修复完成！"
echo ""
echo "📋 下一步操作："
echo "1. 重启终端或执行: exec zsh"
echo "2. 或者运行测试脚本: /tmp/test_zsh_startup.sh"
echo "3. 检查是否还有 compinit 警告"
echo ""
echo "💡 提示："
echo "- 使用 'exec zsh' 而不是 'source ~/.zshrc' 来重新加载配置"
echo "- 如果警告仍然存在，请检查其他可能调用 compinit 的脚本"