#!/bin/bash
# ========================================
# 远程环境验证脚本
# ========================================
# 在远程服务器上运行此脚本来验证配置是否正确

set -euo pipefail

echo "🌐 远程环境配置验证脚本"
echo "========================"

# 检查是否在SSH环境中
if [[ -n "${SSH_CONNECTION:-}" ]] || [[ -n "${SSH_CLIENT:-}" ]] || [[ -n "${SSH_TTY:-}" ]]; then
    echo "✅ 检测到SSH连接环境"
else
    echo "⚠️  未检测到SSH连接，但可以继续测试"
fi

echo ""
echo "🔍 检查shell配置加载..."

# 检查环境变量
if [[ "${REMOTE_ENVIRONMENT:-}" == "true" ]]; then
    echo "✅ REMOTE_ENVIRONMENT环境变量正确设置"
else
    echo "❌ REMOTE_ENVIRONMENT环境变量未设置或错误"
fi

if [[ "${GUI_TOOLS_ENABLED:-}" == "false" ]]; then
    echo "✅ GUI_TOOLS_ENABLED正确禁用"
else
    echo "❌ GUI_TOOLS_ENABLED未正确设置"
fi

if [[ "${DEVELOPMENT_MODE:-}" == "lightweight" ]]; then
    echo "✅ DEVELOPMENT_MODE设置为轻量模式"
else
    echo "❌ DEVELOPMENT_MODE未正确设置"
fi

echo ""
echo "🔧 检查函数定义..."

# 检查sysinfo函数
if declare -f sysinfo >/dev/null 2>&1; then
    echo "✅ sysinfo函数已定义"
    # 测试函数输出
    if sysinfo | grep -q "Remote\|远程"; then
        echo "✅ sysinfo函数输出正确（远程版本）"
    else
        echo "⚠️  sysinfo函数可能不是远程版本"
    fi
else
    echo "❌ sysinfo函数未定义"
fi

# 检查代理函数
if declare -f remote_proxyon >/dev/null 2>&1; then
    echo "✅ remote_proxyon函数已定义"
else
    echo "❌ remote_proxyon函数未定义"
fi

if declare -f remote_proxyoff >/dev/null 2>&1; then
    echo "✅ remote_proxyoff函数已定义"
else
    echo "❌ remote_proxyoff函数未定义"
fi

# 检查别名
if alias proxyon >/dev/null 2>&1; then
    echo "✅ proxyon别名已定义"
else
    echo "❌ proxyon别名未定义"
fi

echo ""
echo "🚀 检查starship配置..."

if command -v starship >/dev/null 2>&1; then
    echo "✅ starship已安装: $(starship --version)"
    
    # 检查starship配置
    if [[ -n "${STARSHIP_CONFIG:-}" ]]; then
        echo "✅ STARSHIP_CONFIG环境变量已设置: $STARSHIP_CONFIG"
    else
        echo "⚠️  STARSHIP_CONFIG环境变量未设置"
    fi
    
    # 检查缓存目录
    if [[ -d "${STARSHIP_CACHE:-$HOME/.cache/starship}" ]]; then
        echo "✅ starship缓存目录存在"
    else
        echo "⚠️  starship缓存目录不存在"
    fi
else
    echo "❌ starship未安装"
fi

echo ""
echo "🛠️  检查基础工具..."

# 检查基础工具
tools=("git" "curl" "wget" "vim")
for tool in "${tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "✅ $tool 已安装"
    else
        echo "❌ $tool 未安装"
    fi
done

echo ""
echo "🔗 测试网络连接..."

if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
    echo "✅ 网络连接正常"
else
    echo "❌ 网络连接异常"
fi

echo ""
echo "🧪 测试基础功能..."

# 测试mkcd函数
if declare -f mkcd >/dev/null 2>&1; then
    echo "✅ mkcd函数可用"
    # 测试创建临时目录
    temp_test_dir="/tmp/test_mkcd_$$"
    if mkcd "$temp_test_dir" >/dev/null 2>&1 && [[ "$PWD" == "$temp_test_dir" ]]; then
        echo "✅ mkcd函数工作正常"
        cd - >/dev/null
        rmdir "$temp_test_dir" 2>/dev/null || true
    else
        echo "❌ mkcd函数工作异常"
    fi
else
    echo "❌ mkcd函数不可用"
fi

# 测试代理功能
echo ""
echo "🔗 测试代理功能..."

# 保存当前代理设置
old_http_proxy="${http_proxy:-}"
old_https_proxy="${https_proxy:-}"

# 测试proxyon
if proxyon >/dev/null 2>&1; then
    echo "✅ proxyon命令执行成功"
    if [[ -n "${http_proxy:-}" ]]; then
        echo "✅ 代理环境变量已设置"
    else
        echo "❌ 代理环境变量未设置"
    fi
else
    echo "❌ proxyon命令执行失败"
fi

# 测试proxyoff
if proxyoff >/dev/null 2>&1; then
    echo "✅ proxyoff命令执行成功"
    if [[ -z "${http_proxy:-}" ]]; then
        echo "✅ 代理环境变量已清除"
    else
        echo "❌ 代理环境变量未清除"
    fi
else
    echo "❌ proxyoff命令执行失败"
fi

# 恢复原始代理设置
export http_proxy="$old_http_proxy"
export https_proxy="$old_https_proxy"

echo ""
echo "📊 生成诊断报告..."

echo "系统信息:"
echo "  主机名: $(hostname)"
echo "  用户: $(whoami)"
echo "  Shell: $SHELL"
echo "  PWD: $PWD"
echo "  SSH_CONNECTION: ${SSH_CONNECTION:-未设置}"
echo "  TERM: ${TERM:-未设置}"

if command -v chezmoi >/dev/null 2>&1; then
    echo ""
    echo "Chezmoi信息:"
    echo "  版本: $(chezmoi --version 2>/dev/null | head -1 || echo '未知')"
    echo "  源目录: $(chezmoi source-path 2>/dev/null || echo '未知')"
fi

echo ""
echo "🎉 远程环境验证完成！"
echo ""
echo "💡 如果发现问题："
echo "  1. 确保已运行 'chezmoi apply'"
echo "  2. 重新启动shell或运行 'source ~/.zshrc'"
echo "  3. 检查chezmoi配置是否正确识别为远程环境"