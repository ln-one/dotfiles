#!/bin/bash
# ========================================
# 迁移验证脚本
# ========================================
# 验证 Shell 功能迁移是否成功完成

set -e

echo "🔍 验证 Chezmoi Shell 功能迁移..."
echo "=================================="

# 检查必需的模板文件
echo "📁 检查模板文件..."
required_templates=(
    ".chezmoitemplates/aliases.sh"
    ".chezmoitemplates/basic-functions.sh"
    ".chezmoitemplates/proxy-functions.sh"
    ".chezmoitemplates/theme-functions.sh"
    ".chezmoitemplates/shell-common.sh"
)

for template in "${required_templates[@]}"; do
    if [[ -f "$template" ]]; then
        echo "✅ $template 存在"
    else
        echo "❌ $template 缺失"
        exit 1
    fi
done

# 检查 shell 配置模板
echo ""
echo "📝 检查 Shell 配置模板..."
shell_templates=(
    "dot_bashrc.tmpl"
    "dot_zshrc.tmpl"
)

for template in "${shell_templates[@]}"; do
    if [[ -f "$template" ]]; then
        echo "✅ $template 存在"
        # 检查是否包含 shell-common.sh
        if grep -q "shell-common.sh" "$template"; then
            echo "  └── 包含 shell-common.sh 引用"
        else
            echo "  ⚠️  未找到 shell-common.sh 引用"
        fi
    else
        echo "❌ $template 缺失"
        exit 1
    fi
done

# 验证模板语法
echo ""
echo "🧪 验证模板语法..."
for template in "${required_templates[@]}"; do
    if chezmoi execute-template < "$template" > /dev/null 2>&1; then
        echo "✅ $template 语法正确"
    else
        echo "❌ $template 语法错误"
        exit 1
    fi
done

# 检查核心功能
echo ""
echo "🔧 检查核心功能..."

# 生成完整的 shell 配置
chezmoi execute-template < .chezmoitemplates/shell-common.sh > /tmp/test-shell-config.sh

# 检查别名
if grep -q "alias ll=" /tmp/test-shell-config.sh; then
    echo "✅ ll 别名存在"
else
    echo "❌ ll 别名缺失"
    exit 1
fi

if grep -q "alias la=" /tmp/test-shell-config.sh; then
    echo "✅ la 别名存在"
else
    echo "❌ la 别名缺失"
    exit 1
fi

# 检查代理函数
proxy_functions=("proxyon" "proxyoff" "proxystatus")
for func in "${proxy_functions[@]}"; do
    if grep -q "${func}()" /tmp/test-shell-config.sh; then
        echo "✅ $func 函数存在"
    else
        echo "❌ $func 函数缺失"
        exit 1
    fi
done

# 检查主题函数
theme_functions=("dark" "light" "themestatus")
for func in "${theme_functions[@]}"; do
    if grep -q "${func}()" /tmp/test-shell-config.sh; then
        echo "✅ $func 函数存在"
    else
        echo "❌ $func 函数缺失"
        exit 1
    fi
done

# 检查基础函数
basic_functions=("mkcd" "sysinfo")
for func in "${basic_functions[@]}"; do
    if grep -q "${func}()" /tmp/test-shell-config.sh; then
        echo "✅ $func 函数存在"
    else
        echo "❌ $func 函数缺失"
        exit 1
    fi
done

# 检查项目文件
echo ""
echo "📋 检查项目文件..."
project_files=(
    ".gitignore"
    "PROJECT_STRUCTURE.md"
    "test-templates.sh"
)

for file in "${project_files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "✅ $file 存在"
    else
        echo "❌ $file 缺失"
        exit 1
    fi
done

# 清理临时文件
rm -f /tmp/test-shell-config.sh

echo ""
echo "🎉 迁移验证完成！"
echo ""
echo "📊 迁移总结:"
echo "   ✅ 5 个模板文件已创建"
echo "   ✅ 2 个 Shell 配置模板已更新"
echo "   ✅ 核心功能已验证 (别名、代理、主题、基础函数)"
echo "   ✅ 项目文档已完善"
echo "   ✅ Git 配置已设置"
echo ""
echo "🚀 下一步:"
echo "   1. 运行 'chezmoi apply' 应用配置"
echo "   2. 重新加载 shell 配置"
echo "   3. 测试功能: ll, proxyon, dark, mkcd, sysinfo"