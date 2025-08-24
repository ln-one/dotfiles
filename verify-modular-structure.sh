#!/bin/bash
# ========================================
# 验证模块化结构脚本
# ========================================

echo "🔍 验证 Chezmoi Shell 模块化结构..."
echo "=================================="

# 检查所有模板文件是否存在
templates=(
    ".chezmoitemplates/aliases.sh"
    ".chezmoitemplates/proxy-functions.sh" 
    ".chezmoitemplates/theme-functions.sh"
    ".chezmoitemplates/basic-functions.sh"
    ".chezmoitemplates/shell-common.sh"
)

echo "📁 检查模板文件..."
for template in "${templates[@]}"; do
    if [[ -f "$template" ]]; then
        echo "✅ $template"
    else
        echo "❌ $template - 文件不存在"
        exit 1
    fi
done

echo ""
echo "🔧 检查模块功能..."

# 检查别名模块
echo "📝 aliases.sh 模块:"
if grep -q "alias ll=" .chezmoitemplates/aliases.sh; then
    echo "  ✅ 包含 ll 别名"
else
    echo "  ❌ 缺少 ll 别名"
fi

# 检查代理模块
echo "📝 proxy-functions.sh 模块:"
proxy_functions=("proxyon" "proxyoff" "proxyai" "proxystatus")
for func in "${proxy_functions[@]}"; do
    if grep -q "${func}()" .chezmoitemplates/proxy-functions.sh; then
        echo "  ✅ 包含 $func 函数"
    else
        echo "  ❌ 缺少 $func 函数"
    fi
done

# 检查主题模块
echo "📝 theme-functions.sh 模块:"
theme_functions=("dark" "light" "themestatus")
for func in "${theme_functions[@]}"; do
    if grep -q "${func}()" .chezmoitemplates/theme-functions.sh; then
        echo "  ✅ 包含 $func 函数"
    else
        echo "  ❌ 缺少 $func 函数"
    fi
done

# 检查基础函数模块
echo "📝 basic-functions.sh 模块:"
basic_functions=("mkcd" "sysinfo")
for func in "${basic_functions[@]}"; do
    if grep -q "${func}()" .chezmoitemplates/basic-functions.sh; then
        echo "  ✅ 包含 $func 函数"
    else
        echo "  ❌ 缺少 $func 函数"
    fi
done

# 检查模块化加载
echo "📝 shell-common.sh 模块化加载:"
includes=("aliases.sh" "basic-functions.sh" "proxy-functions.sh" "theme-functions.sh")
for include in "${includes[@]}"; do
    if grep -q "includeTemplate.*${include}" .chezmoitemplates/shell-common.sh; then
        echo "  ✅ 加载 $include"
    else
        echo "  ❌ 未加载 $include"
    fi
done

echo ""
echo "🎯 检查平台特定功能..."

# 检查 Linux 特定功能
if grep -q "eq .chezmoi.os \"linux\"" .chezmoitemplates/proxy-functions.sh; then
    echo "✅ 代理功能仅限 Linux"
else
    echo "❌ 代理功能平台限制缺失"
fi

if grep -q "eq .chezmoi.os \"linux\"" .chezmoitemplates/theme-functions.sh; then
    echo "✅ 主题功能仅限 Linux"
else
    echo "❌ 主题功能平台限制缺失"
fi

# 检查 SSH 环境排除
if grep -q "not (env \"SSH_CONNECTION\")" .chezmoitemplates/proxy-functions.sh; then
    echo "✅ 代理功能排除 SSH 环境"
else
    echo "❌ 代理功能 SSH 环境排除缺失"
fi

echo ""
echo "📊 模块化结构总结:"
echo "   🎯 功能模块化: 每个功能独立的模板文件"
echo "   🎯 平台感知: Linux/macOS 条件加载"
echo "   🎯 环境感知: 桌面/SSH 环境区分"
echo "   🎯 依赖管理: 通过 includeTemplate 组合"
echo ""
echo "✅ 模块化结构验证完成！"