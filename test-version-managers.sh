#!/bin/bash
# 测试版本管理器安装脚本
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
    log_info "测试版本管理器脚本语法..."
    
    if bash -n run_once_install-version-managers.sh.tmpl; then
        log_info "✅ 脚本语法检查通过"
        return 0
    else
        log_error "❌ 脚本语法检查失败"
        return 1
    fi
}

# 验证脚本结构
test_script_structure() {
    log_info "验证版本管理器脚本结构..."
    
    local required_functions=(
        "check_version_manager_installed"
        "install_nvm"
        "install_pyenv"
        "install_rbenv"
        "install_mise"
        "create_version_manager_configs"
        "verify_version_managers"
        "main"
    )
    
    local missing_functions=()
    
    for func in "${required_functions[@]}"; do
        if grep -q "^$func()" run_once_install-version-managers.sh.tmpl; then
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

# 检查版本管理器配置
test_version_manager_configs() {
    log_info "检查版本管理器配置..."
    
    # 检查是否定义了版本管理器数组
    if grep -q "declare -A VERSION_MANAGERS" run_once_install-version-managers.sh.tmpl; then
        log_info "✅ 找到版本管理器配置数组"
    else
        log_error "❌ 缺少版本管理器配置数组"
        return 1
    fi
    
    # 检查各个版本管理器的安装函数
    local managers=("nvm" "pyenv" "rbenv" "mise")
    
    for manager in "${managers[@]}"; do
        if grep -q "install_$manager()" run_once_install-version-managers.sh.tmpl; then
            log_info "✅ 找到 $manager 安装函数"
        else
            log_warn "⚠️ 缺少 $manager 安装函数"
        fi
    done
    
    return 0
}

# 测试 Chezmoi 模板渲染
test_template_rendering() {
    log_info "测试版本管理器模板渲染..."
    
    # 检查是否有 chezmoi 命令
    if ! command -v chezmoi >/dev/null 2>&1; then
        log_warn "⚠️ Chezmoi 未安装，跳过模板渲染测试"
        return 0
    fi
    
    # 尝试渲染模板
    if chezmoi execute-template < run_once_install-version-managers.sh.tmpl > /tmp/test-version-managers.sh 2>/dev/null; then
        log_info "✅ 模板渲染成功"
        
        # 检查渲染后的脚本语法
        if bash -n /tmp/test-version-managers.sh; then
            log_info "✅ 渲染后脚本语法正确"
        else
            log_error "❌ 渲染后脚本语法错误"
            return 1
        fi
        
        # 清理临时文件
        rm -f /tmp/test-version-managers.sh
        return 0
    else
        log_error "❌ 模板渲染失败"
        return 1
    fi
}

# 检查模板变量使用
test_template_variables() {
    log_info "检查模板变量使用..."
    
    local required_variables=(
        "chezmoi.os"
        "chezmoi.arch"
        "chezmoi.homeDir"
        "features.enable_node"
        "features.enable_python"
    )
    
    local missing_variables=()
    
    for var in "${required_variables[@]}"; do
        if grep -q "{{ .*$var" run_once_install-version-managers.sh.tmpl; then
            log_info "✅ 使用了模板变量: $var"
        else
            log_warn "⚠️ 未使用模板变量: $var"
            missing_variables+=("$var")
        fi
    done
    
    if [[ ${#missing_variables[@]} -eq 0 ]]; then
        log_info "✅ 模板变量检查通过"
    else
        log_warn "⚠️ 部分模板变量未使用: ${missing_variables[*]}"
    fi
    
    return 0
}

# 主测试函数
main() {
    log_info "开始测试版本管理器安装脚本..."
    
    local failed_tests=0
    
    # 运行所有测试
    test_script_syntax || ((failed_tests++))
    test_script_structure || ((failed_tests++))
    test_version_manager_configs || ((failed_tests++))
    test_template_variables || ((failed_tests++))
    test_template_rendering || ((failed_tests++))
    
    echo ""
    if [[ $failed_tests -eq 0 ]]; then
        log_info "🎉 所有测试通过! 版本管理器安装脚本准备就绪。"
        return 0
    else
        log_error "❌ $failed_tests 个测试失败。请检查脚本。"
        return 1
    fi
}

# 运行测试
main "$@"