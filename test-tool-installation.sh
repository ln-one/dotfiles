#!/bin/bash
# 测试工具安装脚本
# 验证脚本语法和基本功能

set -euo pipefail

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[TEST]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# 测试脚本语法
test_script_syntax() {
    log_info "测试脚本语法..."
    
    if bash -n run_once_install-tools.sh.tmpl; then
        log_info "✅ 脚本语法检查通过"
        return 0
    else
        log_error "❌ 脚本语法检查失败"
        return 1
    fi
}

# 测试 Chezmoi 模板渲染
test_template_rendering() {
    log_info "测试 Chezmoi 模板渲染..."
    
    # 检查是否有 chezmoi 命令
    if ! command -v chezmoi >/dev/null 2>&1; then
        log_warn "⚠️ Chezmoi 未安装，跳过模板渲染测试"
        return 0
    fi
    
    # 尝试渲染模板
    if chezmoi execute-template < run_once_install-tools.sh.tmpl > /tmp/test-install-tools.sh 2>/dev/null; then
        log_info "✅ 模板渲染成功"
        
        # 检查渲染后的脚本语法
        if bash -n /tmp/test-install-tools.sh; then
            log_info "✅ 渲染后脚本语法正确"
        else
            log_error "❌ 渲染后脚本语法错误"
            return 1
        fi
        
        # 清理临时文件
        rm -f /tmp/test-install-tools.sh
        return 0
    else
        log_error "❌ 模板渲染失败"
        return 1
    fi
}

# 测试工具检测函数
test_tool_detection() {
    log_info "测试工具检测功能..."
    
    # 创建临时测试脚本
    cat > /tmp/test-detection.sh << 'EOF'
#!/bin/bash
check_tool_installed() {
    local tool="$1"
    if command -v "$tool" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# 测试已知存在的工具
if check_tool_installed "bash"; then
    echo "✅ bash 检测正确"
else
    echo "❌ bash 检测失败"
    exit 1
fi

# 测试不存在的工具
if check_tool_installed "nonexistent-tool-12345"; then
    echo "❌ 不存在工具检测错误"
    exit 1
else
    echo "✅ 不存在工具检测正确"
fi
EOF
    
    if bash /tmp/test-detection.sh; then
        log_info "✅ 工具检测功能测试通过"
        rm -f /tmp/test-detection.sh
        return 0
    else
        log_error "❌ 工具检测功能测试失败"
        rm -f /tmp/test-detection.sh
        return 1
    fi
}

# 验证脚本结构
test_script_structure() {
    log_info "验证脚本结构..."
    
    local required_functions=(
        "check_tool_installed"
        "install_tool"
        "install_tool_group"
        "verify_installation"
        "main"
    )
    
    local missing_functions=()
    
    for func in "${required_functions[@]}"; do
        if grep -q "^$func()" run_once_install-tools.sh.tmpl; then
            log_info "✅ 找到函数: $func"
        else
            log_error "❌ 缺少函数: $func"
            missing_functions+=("$func")
        fi
    done
    
    if [[ ${#missing_functions[@]} -eq 0 ]]; then
        log_info "✅ 脚本结构验证通过"
        return 0
    else
        log_error "❌ 脚本结构验证失败，缺少函数: ${missing_functions[*]}"
        return 1
    fi
}

# 检查必需的工具列表
test_tool_lists() {
    log_info "检查工具列表定义..."
    
    local required_lists=(
        "ESSENTIAL_TOOLS"
        "MODERN_CLI_TOOLS"
        "DEVELOPMENT_TOOLS"
    )
    
    local missing_lists=()
    
    for list in "${required_lists[@]}"; do
        if grep -q "declare -A $list" run_once_install-tools.sh.tmpl; then
            log_info "✅ 找到工具列表: $list"
        else
            log_error "❌ 缺少工具列表: $list"
            missing_lists+=("$list")
        fi
    done
    
    if [[ ${#missing_lists[@]} -eq 0 ]]; then
        log_info "✅ 工具列表检查通过"
        return 0
    else
        log_error "❌ 工具列表检查失败，缺少列表: ${missing_lists[*]}"
        return 1
    fi
}

# 主测试函数
main() {
    log_info "开始测试工具安装脚本..."
    
    local failed_tests=0
    
    # 运行所有测试
    test_script_syntax || ((failed_tests++))
    test_script_structure || ((failed_tests++))
    test_tool_lists || ((failed_tests++))
    test_tool_detection || ((failed_tests++))
    test_template_rendering || ((failed_tests++))
    
    echo ""
    if [[ $failed_tests -eq 0 ]]; then
        log_info "🎉 所有测试通过! 工具安装脚本准备就绪。"
        return 0
    else
        log_error "❌ $failed_tests 个测试失败。请检查脚本。"
        return 1
    fi
}

# 运行测试
main "$@"