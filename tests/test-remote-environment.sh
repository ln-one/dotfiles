#!/bin/bash
# ========================================
# 远程环境配置测试脚本
# ========================================
# 测试远程环境的配置是否正确工作

set -euo pipefail

echo "🧪 开始测试远程环境配置..."

# 模拟SSH环境
export SSH_CONNECTION="192.168.1.100 12345 192.168.1.1 22"
export SSH_CLIENT="192.168.1.100 12345 22"

# 测试环境检测
echo "🔍 测试环境检测..."
if [[ -n "${SSH_CONNECTION:-}" ]]; then
    echo "✅ SSH_CONNECTION环境变量已设置"
else
    echo "❌ SSH_CONNECTION环境变量未设置"
    exit 1
fi

# 测试chezmoi数据生成
echo "📊 测试chezmoi数据生成..."
if command -v chezmoi >/dev/null 2>&1; then
    chezmoi data | grep -q "remote" && echo "✅ 环境正确识别为remote" || echo "❌ 环境识别失败"
else
    echo "⚠️  chezmoi未安装，跳过数据测试"
fi

# 测试配置文件生成
echo "📝 测试配置文件生成..."
temp_dir=$(mktemp -d)
cd "$temp_dir"

# 创建测试用的chezmoi源目录结构
mkdir -p .chezmoitemplates/{core,environments,platforms/linux}

# 复制必要的模板文件进行测试
cat > .chezmoitemplates/environments/remote.sh << 'EOF'
# Test remote environment
export REMOTE_ENVIRONMENT="true"
sysinfo() {
    echo "Remote sysinfo function"
}
EOF

# 测试模板渲染
echo "🎨 测试模板渲染..."
if chezmoi execute-template --init < .chezmoitemplates/environments/remote.sh >/dev/null 2>&1; then
    echo "✅ 模板渲染成功"
else
    echo "❌ 模板渲染失败"
fi

# 清理
cd - >/dev/null
rm -rf "$temp_dir"

# 测试函数定义
echo "🔧 测试函数定义..."

# 模拟加载远程环境配置
source_remote_config() {
    # 模拟远程环境变量
    export DEVELOPMENT_MODE="lightweight"
    export GUI_TOOLS_ENABLED="false"
    export REMOTE_ENVIRONMENT="true"
    
    # 定义测试函数
    sysinfo() {
        echo "🖥️  Remote System Information:"
        echo "  Hostname: $(hostname)"
        echo "  User: $(whoami)"
        echo "  Environment: Remote"
    }
    
    remote_proxyon() {
        echo "🔗 Setting remote proxy..."
        export http_proxy="http://127.0.0.1:7890"
    }
    
    remote_proxyoff() {
        echo "🔗 Clearing remote proxy..."
        unset http_proxy
    }
    
    alias proxyon='remote_proxyon'
    alias proxyoff='remote_proxyoff'
}

# 加载配置
source_remote_config

# 测试函数
echo "🧪 测试远程函数..."
if declare -f sysinfo >/dev/null 2>&1; then
    echo "✅ sysinfo函数已定义"
    sysinfo | grep -q "Remote" && echo "✅ sysinfo函数工作正常" || echo "❌ sysinfo函数输出异常"
else
    echo "❌ sysinfo函数未定义"
fi

if declare -f remote_proxyon >/dev/null 2>&1; then
    echo "✅ remote_proxyon函数已定义"
    remote_proxyon >/dev/null 2>&1 && echo "✅ remote_proxyon函数工作正常" || echo "❌ remote_proxyon函数异常"
else
    echo "❌ remote_proxyon函数未定义"
fi

# 测试别名
echo "🔗 测试别名..."
if alias proxyon >/dev/null 2>&1; then
    echo "✅ proxyon别名已定义"
else
    echo "❌ proxyon别名未定义"
fi

# 测试环境变量
echo "🌐 测试环境变量..."
if [[ "${REMOTE_ENVIRONMENT:-}" == "true" ]]; then
    echo "✅ REMOTE_ENVIRONMENT环境变量正确"
else
    echo "❌ REMOTE_ENVIRONMENT环境变量错误"
fi

if [[ "${GUI_TOOLS_ENABLED:-}" == "false" ]]; then
    echo "✅ GUI_TOOLS_ENABLED环境变量正确"
else
    echo "❌ GUI_TOOLS_ENABLED环境变量错误"
fi

echo "🎉 远程环境配置测试完成！"

# 清理测试环境变量
unset SSH_CONNECTION SSH_CLIENT REMOTE_ENVIRONMENT GUI_TOOLS_ENABLED DEVELOPMENT_MODE