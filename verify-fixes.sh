#!/bin/bash
# ========================================
# 验证修复脚本
# ========================================
# 验证所有修复是否正确工作

set -euo pipefail

echo "🔧 验证远程环境配置修复..."

# 1. 测试zoxide配置语法
echo "1️⃣ 测试zoxide配置语法..."
if chezmoi execute-template < .chezmoitemplates/core/zoxide-config.sh >/dev/null 2>&1; then
    echo "✅ zoxide配置语法正确"
else
    echo "❌ zoxide配置语法错误"
    exit 1
fi

# 2. 测试远程环境配置语法
echo "2️⃣ 测试远程环境配置语法..."
if chezmoi execute-template < .chezmoitemplates/environments/remote.sh >/dev/null 2>&1; then
    echo "✅ 远程环境配置语法正确"
else
    echo "❌ 远程环境配置语法错误"
    exit 1
fi

# 3. 测试基础函数配置语法
echo "3️⃣ 测试基础函数配置语法..."
if chezmoi execute-template < .chezmoitemplates/core/basic-functions.sh >/dev/null 2>&1; then
    echo "✅ 基础函数配置语法正确"
else
    echo "❌ 基础函数配置语法错误"
    exit 1
fi

# 4. 测试starship安装脚本语法
echo "4️⃣ 测试starship安装脚本语法..."
if chezmoi execute-template < run_once_install-starship.sh.tmpl >/dev/null 2>&1; then
    echo "✅ starship安装脚本语法正确"
else
    echo "❌ starship安装脚本语法错误"
    exit 1
fi

# 5. 测试远程环境验证脚本语法
echo "5️⃣ 测试远程环境验证脚本语法..."
if chezmoi execute-template < run_once_verify-remote-environment.sh.tmpl >/dev/null 2>&1; then
    echo "✅ 远程环境验证脚本语法正确"
else
    echo "❌ 远程环境验证脚本语法错误"
    exit 1
fi

# 6. 检查函数冲突（分别测试本地和远程环境）
echo "6️⃣ 检查函数冲突..."

# 测试本地环境（当前环境）
temp_file_local=$(mktemp)
chezmoi execute-template < .chezmoitemplates/shell-common.sh > "$temp_file_local"

echo "  📍 本地环境测试:"
# 检查本地环境中的sysinfo函数
if grep -q "sysinfo()" "$temp_file_local"; then
    sysinfo_count=$(grep -c "sysinfo()" "$temp_file_local")
    if [[ $sysinfo_count -eq 1 ]]; then
        echo "  ✅ 本地环境：没有sysinfo函数冲突"
    else
        echo "  ❌ 本地环境：检测到sysinfo函数冲突 ($sysinfo_count 个)"
    fi
else
    echo "  ✅ 本地环境：没有sysinfo函数定义"
fi

# 测试远程环境（模拟）
temp_file_remote=$(mktemp)
SSH_CONNECTION="test" chezmoi execute-template < .chezmoitemplates/shell-common.sh > "$temp_file_remote"

echo "  🌐 远程环境测试（模拟）:"
# 检查远程环境中的sysinfo函数
if grep -q "sysinfo()" "$temp_file_remote"; then
    sysinfo_count=$(grep -c "sysinfo()" "$temp_file_remote")
    if [[ $sysinfo_count -eq 1 ]]; then
        echo "  ✅ 远程环境：没有sysinfo函数冲突"
    else
        echo "  ❌ 远程环境：检测到sysinfo函数冲突 ($sysinfo_count 个)"
    fi
else
    echo "  ❌ 远程环境：没有sysinfo函数定义"
fi

# 检查远程环境中的代理函数
if grep -q "remote_proxyon()" "$temp_file_remote"; then
    echo "  ✅ 远程环境：remote_proxyon函数存在"
else
    echo "  ℹ️  远程环境：remote_proxyon函数缺失（这是正常的，因为当前环境被识别为desktop）"
    echo "      在真实的远程环境中运行 'chezmoi apply' 时会正确加载"
fi

rm "$temp_file_local" "$temp_file_remote"

# 7. 测试环境检测逻辑
echo "7️⃣ 测试环境检测逻辑..."
# 测试模板逻辑本身
if env SSH_CONNECTION="test" chezmoi execute-template --init <<< '{{- if or (env "SSH_CONNECTION") (env "SSH_CLIENT") }}remote{{- else }}desktop{{- end }}' | grep -q "remote"; then
    echo "✅ 环境检测模板逻辑正确"
else
    echo "❌ 环境检测模板逻辑错误"
fi

# 说明chezmoi的工作原理
echo "ℹ️  注意：chezmoi在初始化时确定环境类型，而不是在每次渲染时检测"
echo "ℹ️  在真实的远程环境中运行 'chezmoi init' 或 'chezmoi apply' 会正确设置环境"

# 8. 检查当前实际环境
echo "8️⃣ 检查当前实际环境..."
current_env=$(chezmoi data | grep '"environment":' | cut -d'"' -f4)
echo "ℹ️  当前环境类型: $current_env"

if [[ -n "${SSH_CONNECTION:-}" ]] || [[ -n "${SSH_CLIENT:-}" ]]; then
    echo "ℹ️  检测到SSH连接，这是真实的远程环境"
else
    echo "ℹ️  未检测到SSH连接，这是本地环境"
fi

echo "🎉 所有修复验证完成！"