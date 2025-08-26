#!/bin/bash

# 综合测试脚本：运行所有重构验证测试
# 执行路径统一、Brewfile 完整性和环境配置完整性的所有测试

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

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 测试结果统计
TOTAL_TEST_SUITES=0
PASSED_TEST_SUITES=0
FAILED_TEST_SUITES=0

# 运行单个测试套件
run_test_suite() {
    local test_name="$1"
    local test_script="$2"
    
    TOTAL_TEST_SUITES=$((TOTAL_TEST_SUITES + 1))
    
    echo ""
    echo "=========================================="
    log_info "运行测试套件: $test_name"
    echo "=========================================="
    
    if ./"$test_script"; then
        PASSED_TEST_SUITES=$((PASSED_TEST_SUITES + 1))
        log_success "✅ $test_name 测试套件通过"
    else
        FAILED_TEST_SUITES=$((FAILED_TEST_SUITES + 1))
        log_error "❌ $test_name 测试套件失败"
    fi
}

# 主函数
main() {
    log_info "开始运行所有重构验证测试..."
    
    # 检查测试脚本是否存在
    local test_scripts=(
        "scripts/test-path-unification.sh"
        "scripts/test-brewfile-completeness.sh"
        "scripts/test-environment-completeness.sh"
    )
    
    for script in "${test_scripts[@]}"; do
        if [[ ! -f "$script" ]]; then
            log_error "测试脚本不存在: $script"
            exit 1
        fi
        
        if [[ ! -x "$script" ]]; then
            log_error "测试脚本不可执行: $script"
            exit 1
        fi
    done
    
    # 运行所有测试套件
    run_test_suite "路径统一验证" "scripts/test-path-unification.sh"
    run_test_suite "Brewfile 完整性验证" "scripts/test-brewfile-completeness.sh"
    run_test_suite "环境配置完整性验证" "scripts/test-environment-completeness.sh"
    
    # 输出总体测试结果
    echo ""
    echo "=========================================="
    log_info "所有测试套件执行完成"
    echo "=========================================="
    echo "  总测试套件数: $TOTAL_TEST_SUITES"
    echo "  通过: $PASSED_TEST_SUITES"
    echo "  失败: $FAILED_TEST_SUITES"
    
    if [[ $FAILED_TEST_SUITES -eq 0 ]]; then
        echo ""
        log_success "🎉 所有重构验证测试通过！"
        log_success "Homebrew 统一包管理重构已成功完成并验证"
        echo ""
        log_info "重构成果总结:"
        echo "  ✅ 系统包管理器路径已统一为 Homebrew 路径"
        echo "  ✅ 工具名称已统一为 Homebrew 标准名称"
        echo "  ✅ Brewfile 包含所有必要工具和正确的条件逻辑"
        echo "  ✅ 环境配置完整且正确使用 Homebrew 路径"
        echo "  ✅ Shell 集成功能正常"
        echo ""
        exit 0
    else
        echo ""
        log_error "❌ 有 $FAILED_TEST_SUITES 个测试套件失败"
        log_error "请检查失败的测试并修复相关问题"
        exit 1
    fi
}

# 运行主函数
main "$@"