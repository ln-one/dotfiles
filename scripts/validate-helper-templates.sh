#!/usr/bin/env bash

# 验证辅助模板功能的脚本

set -euo pipefail

echo "🔍 验证辅助模板创建情况..."

# 检查文件是否存在
templates=(
    ".chezmoitemplates/helpers/tool-check.sh"
    ".chezmoitemplates/helpers/defer-load.sh"
    ".chezmoitemplates/helpers/config-section.sh"
    ".chezmoitemplates/helpers/README.md"
    ".chezmoitemplates/helpers/test-templates.sh.tmpl"
    ".chezmoitemplates/helpers/example-usage.sh.tmpl"
)

for template in "${templates[@]}"; do
    if [[ -f "$template" ]]; then
        echo "✅ $template 存在"
    else
        echo "❌ $template 不存在"
        exit 1
    fi
done

echo ""
echo "🧪 测试模板语法..."

# 测试模板语法
if chezmoi execute-template < .chezmoitemplates/helpers/test-templates.sh.tmpl >/dev/null 2>&1; then
    echo "✅ 基础测试模板语法正确"
else
    echo "❌ 基础测试模板语法错误"
    exit 1
fi

if chezmoi execute-template < .chezmoitemplates/helpers/example-usage.sh.tmpl >/dev/null 2>&1; then
    echo "✅ 示例模板语法正确"
else
    echo "❌ 示例模板语法错误"
    exit 1
fi

echo ""
echo "🎯 测试功能..."

# 运行实际测试
echo "执行基础功能测试:"
chezmoi execute-template < .chezmoitemplates/helpers/test-templates.sh.tmpl | bash

echo ""
echo "🎉 所有辅助模板验证通过！"
echo ""
echo "📋 已创建的辅助模板："
echo "   • tool-check.sh    - 工具检测和条件执行"
echo "   • defer-load.sh    - 延迟加载优化"
echo "   • config-section.sh - 配置节格式化"
echo ""
echo "📚 下一步建议："
echo "   1. 开始重构现有的大型配置文件"
echo "   2. 将 evalcache-config.sh 拆分为模块"
echo "   3. 使用这些模板简化配置逻辑"
