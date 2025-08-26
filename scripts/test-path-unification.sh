#!/bin/bash

# 测试脚本：验证路径统一
# 检查所有配置文件中的路径引用，确保已统一为 Homebrew 路径

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 测试结果统计
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# 记录测试结果
record_test() {
    local test_name="$1"
    local result="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [[ "$result" == "PASS" ]]; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        log_success "✅ $test_name"
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        log_error "❌ $test_name"
    fi
}

# 检查是否存在系统包管理器路径引用
check_system_package_paths() {
    log_info "检查系统包管理器路径引用..."
    
    local found_issues=0
    
    # 检查 /usr/bin 路径引用
    if grep -r "/usr/bin/" --include="*.tmpl" . 2>/dev/null | grep -v "#!/usr/bin" | grep -v "/usr/bin/env"; then
        log_error "发现 /usr/bin 路径引用"
        found_issues=1
    fi
    
    # 检查 /usr/local/bin 路径引用
    if grep -r "/usr/local/bin" --include="*.tmpl" . 2>/dev/null; then
        log_error "发现 /usr/local/bin 路径引用"
        found_issues=1
    fi
    
    # 检查系统包管理器命令
    local package_managers=("apt" "yum" "dnf" "pacman" "zypper")
    for pm in "${package_managers[@]}"; do
        if grep -r "command -v $pm\|which $pm\|$pm install\|$pm update" --include="*.tmpl" . 2>/dev/null; then
            log_error "发现系统包管理器 $pm 的使用"
            found_issues=1
        fi
    done
    
    if [[ $found_issues -eq 0 ]]; then
        record_test "系统包管理器路径检查" "PASS"
    else
        record_test "系统包管理器路径检查" "FAIL"
    fi
}

# 检查工具名称统一
check_tool_name_unification() {
    log_info "检查工具名称统一..."
    
    local found_issues=0
    
    # 检查 batcat 引用（应该统一为 bat）- 排除注释
    if grep -r "batcat" --include="*.tmpl" . 2>/dev/null | grep -v "^[[:space:]]*#" | grep -v "不再使用 batcat"; then
        log_error "发现 batcat 引用，应该统一为 bat"
        found_issues=1
    fi
    
    # 检查 fdfind 引用（应该统一为 fd）- 排除注释
    if grep -r "fdfind" --include="*.tmpl" . 2>/dev/null | grep -v "^[[:space:]]*#" | grep -v "不再使用.*fdfind"; then
        log_error "发现 fdfind 引用，应该统一为 fd"
        found_issues=1
    fi
    
    # 检查 fd-find 引用（应该统一为 fd）- 排除注释
    if grep -r "fd-find" --include="*.tmpl" . 2>/dev/null | grep -v "^[[:space:]]*#" | grep -v "不再使用.*fd-find"; then
        log_error "发现 fd-find 引用，应该统一为 fd"
        found_issues=1
    fi
    
    if [[ $found_issues -eq 0 ]]; then
        record_test "工具名称统一检查" "PASS"
    else
        record_test "工具名称统一检查" "FAIL"
    fi
}

# 检查 Homebrew 路径使用
check_homebrew_path_usage() {
    log_info "检查 Homebrew 路径使用..."
    
    local found_homebrew_usage=0
    
    # 检查是否使用了 $(brew --prefix) 或 $HOMEBREW_PREFIX
    if grep -r "brew --prefix\|\$HOMEBREW_PREFIX" --include="*.tmpl" . 2>/dev/null >/dev/null; then
        found_homebrew_usage=1
    fi
    
    # 检查是否在环境配置中正确设置了 Homebrew 路径
    if grep -r "HOMEBREW_PREFIX" --include="*.tmpl" . 2>/dev/null >/dev/null; then
        found_homebrew_usage=1
    fi
    
    if [[ $found_homebrew_usage -eq 1 ]]; then
        record_test "Homebrew 路径使用检查" "PASS"
    else
        record_test "Homebrew 路径使用检查" "FAIL"
        log_error "未发现 Homebrew 路径的正确使用"
    fi
}

# 检查包名映射逻辑是否已移除
check_package_name_mapping_removal() {
    log_info "检查包名映射逻辑是否已移除..."
    
    local found_mapping=0
    
    # 检查是否还有平台特定的包名映射
    if grep -r "if.*ubuntu.*then.*apt\|if.*centos.*then.*yum" --include="*.tmpl" . 2>/dev/null; then
        log_error "发现平台特定的包名映射逻辑"
        found_mapping=1
    fi
    
    # 检查是否还有包管理器检测逻辑
    if grep -r "command -v apt.*&&\|which apt.*&&" --include="*.tmpl" . 2>/dev/null; then
        log_error "发现包管理器检测逻辑"
        found_mapping=1
    fi
    
    if [[ $found_mapping -eq 0 ]]; then
        record_test "包名映射逻辑移除检查" "PASS"
    else
        record_test "包名映射逻辑移除检查" "FAIL"
    fi
}

# 检查环境变量配置
check_environment_variables() {
    log_info "检查环境变量配置..."
    
    local found_issues=0
    
    # 检查 HOMEBREW_PREFIX 是否正确设置
    if ! grep -r "HOMEBREW_PREFIX" --include="*.tmpl" . 2>/dev/null >/dev/null; then
        log_error "未找到 HOMEBREW_PREFIX 环境变量设置"
        found_issues=1
    fi
    
    # 检查 PATH 是否包含 Homebrew 路径
    if ! grep -r "HOMEBREW_PREFIX.*bin.*PATH\|PATH.*HOMEBREW_PREFIX.*bin" --include="*.tmpl" . 2>/dev/null >/dev/null; then
        log_error "PATH 中未正确包含 Homebrew 路径"
        found_issues=1
    fi
    
    if [[ $found_issues -eq 0 ]]; then
        record_test "环境变量配置检查" "PASS"
    else
        record_test "环境变量配置检查" "FAIL"
    fi
}

# 检查工具路径引用
check_tool_path_references() {
    log_info "检查工具路径引用..."
    
    local found_issues=0
    
    # 检查是否还有硬编码的工具路径
    local tools=("git" "curl" "wget" "bat" "fd" "rg" "eza" "fzf")
    
    for tool in "${tools[@]}"; do
        # 检查是否有硬编码路径而不是使用 Homebrew 路径
        if grep -r "/usr/bin/$tool\|/usr/local/bin/$tool" --include="*.tmpl" . 2>/dev/null; then
            log_error "发现工具 $tool 的硬编码系统路径"
            found_issues=1
        fi
    done
    
    if [[ $found_issues -eq 0 ]]; then
        record_test "工具路径引用检查" "PASS"
    else
        record_test "工具路径引用检查" "FAIL"
    fi
}

# 主测试函数
main() {
    log_info "开始路径统一验证测试..."
    echo ""
    
    # 执行所有测试
    check_system_package_paths
    check_tool_name_unification
    check_homebrew_path_usage
    check_package_name_mapping_removal
    check_environment_variables
    check_tool_path_references
    
    # 输出测试结果摘要
    echo ""
    log_info "测试结果摘要:"
    echo "  总测试数: $TOTAL_TESTS"
    echo "  通过: $PASSED_TESTS"
    echo "  失败: $FAILED_TESTS"
    
    if [[ $FAILED_TESTS -eq 0 ]]; then
        log_success "🎉 所有路径统一测试通过！"
        exit 0
    else
        log_error "❌ 有 $FAILED_TESTS 个测试失败，需要修复"
        exit 1
    fi
}

# 运行主函数
main "$@"