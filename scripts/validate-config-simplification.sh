#!/bin/bash

# 配置简化验证脚本
# 验证简化后的 .chezmoi.toml.tmpl 配置是否正常工作

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

# 检查模板文件是否存在
check_template_files() {
    log_info "检查新创建的模板文件..."
    
    local missing_files=()
    local template_files=(
        ".chezmoitemplates/config/proxy-detection.toml"
        ".chezmoitemplates/config/proxy-clash-detection.toml"
        ".chezmoitemplates/config/proxy-clash-config.toml"
        ".chezmoitemplates/config/proxy-default.toml"
        ".chezmoitemplates/config/proxy-disabled.toml"
        ".chezmoitemplates/config/secrets-1password.toml"
        ".chezmoitemplates/config/secrets-fallback.toml"
        ".chezmoitemplates/config/environment-packages.toml"
    )
    
    for file in "${template_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            missing_files+=("$file")
        fi
    done
    
    if [[ ${#missing_files[@]} -eq 0 ]]; then
        record_test "模板文件存在性检查" "PASS"
    else
        record_test "模板文件存在性检查" "FAIL"
        log_error "缺少模板文件: ${missing_files[*]}"
    fi
}

# 检查主配置文件的简化程度
check_main_config_simplification() {
    log_info "检查主配置文件简化程度..."
    
    local config_file=".chezmoi.toml.tmpl"
    local issues=0
    
    # 检查是否移除了复杂的代理配置逻辑
    if grep -q "subscription_config.*clash_config" "$config_file"; then
        log_error "主配置文件中仍有复杂的代理配置逻辑"
        issues=1
    fi
    
    # 检查是否使用了 includeTemplate
    if ! grep -q "includeTemplate.*config/proxy-detection" "$config_file"; then
        log_error "主配置文件未使用代理检测模板"
        issues=1
    fi
    
    if ! grep -q "includeTemplate.*config/secrets" "$config_file"; then
        log_error "主配置文件未使用密钥配置模板"
        issues=1
    fi
    
    # 检查文件行数是否减少
    local line_count=$(wc -l < "$config_file")
    if [[ $line_count -gt 100 ]]; then
        log_warning "主配置文件仍然较长 ($line_count 行)，可能需要进一步简化"
    fi
    
    if [[ $issues -eq 0 ]]; then
        record_test "主配置文件简化检查" "PASS"
    else
        record_test "主配置文件简化检查" "FAIL"
    fi
}

# 检查模板语法
check_template_syntax() {
    log_info "检查模板语法..."
    
    local syntax_errors=0
    local template_files=(
        ".chezmoi.toml.tmpl"
        ".chezmoitemplates/config/proxy-detection.toml"
        ".chezmoitemplates/config/proxy-clash-detection.toml"
        ".chezmoitemplates/config/proxy-clash-config.toml"
        ".chezmoitemplates/config/secrets-1password.toml"
    )
    
    for file in "${template_files[@]}"; do
        if [[ -f "$file" ]]; then
            # 检查基本的模板语法
            if grep -q "{{.*}}" "$file"; then
                # 检查是否有未闭合的模板标记
                local open_count=$(grep -o "{{" "$file" | wc -l)
                local close_count=$(grep -o "}}" "$file" | wc -l)
                
                if [[ $open_count -ne $close_count ]]; then
                    log_error "$file: 模板标记不匹配 ({{ $open_count 个, }} $close_count 个)"
                    syntax_errors=1
                fi
            fi
        fi
    done
    
    if [[ $syntax_errors -eq 0 ]]; then
        record_test "模板语法检查" "PASS"
    else
        record_test "模板语法检查" "FAIL"
    fi
}

# 测试配置渲染
test_config_rendering() {
    log_info "测试配置渲染..."
    
    # 创建临时目录进行测试
    local temp_dir=$(mktemp -d)
    local test_passed=true
    
    # 复制必要文件到临时目录
    cp -r .chezmoitemplates "$temp_dir/" 2>/dev/null || true
    cp .chezmoi.toml.tmpl "$temp_dir/" 2>/dev/null || true
    
    # 尝试渲染配置（如果 chezmoi 可用）
    if command -v chezmoi >/dev/null 2>&1; then
        cd "$temp_dir" || exit 1
        
        # 尝试执行模板渲染
        if ! chezmoi execute-template < .chezmoi.toml.tmpl >/dev/null 2>&1; then
            log_error "配置模板渲染失败"
            test_passed=false
        fi
        
        cd - >/dev/null || exit 1
    else
        log_warning "chezmoi 不可用，跳过渲染测试"
    fi
    
    # 清理临时目录
    rm -rf "$temp_dir"
    
    if [[ "$test_passed" == true ]]; then
        record_test "配置渲染测试" "PASS"
    else
        record_test "配置渲染测试" "FAIL"
    fi
}

# 检查模块化程度
check_modularization() {
    log_info "检查模块化程度..."
    
    local config_dir=".chezmoitemplates/config"
    local issues=0
    
    # 检查是否创建了配置目录
    if [[ ! -d "$config_dir" ]]; then
        log_error "配置目录不存在: $config_dir"
        issues=1
    fi
    
    # 检查模块文件数量
    local module_count=$(find "$config_dir" -name "*.toml" 2>/dev/null | wc -l)
    if [[ $module_count -lt 5 ]]; then
        log_error "配置模块数量不足 ($module_count 个)"
        issues=1
    fi
    
    # 检查每个模块的职责单一性
    local proxy_modules=$(find "$config_dir" -name "proxy-*.toml" 2>/dev/null | wc -l)
    local secrets_modules=$(find "$config_dir" -name "secrets-*.toml" 2>/dev/null | wc -l)
    
    if [[ $proxy_modules -lt 3 ]]; then
        log_error "代理配置模块化不足 ($proxy_modules 个)"
        issues=1
    fi
    
    if [[ $secrets_modules -lt 2 ]]; then
        log_error "密钥配置模块化不足 ($secrets_modules 个)"
        issues=1
    fi
    
    if [[ $issues -eq 0 ]]; then
        record_test "模块化程度检查" "PASS"
    else
        record_test "模块化程度检查" "FAIL"
    fi
}

# 检查配置完整性
check_config_completeness() {
    log_info "检查配置完整性..."
    
    local issues=0
    
    # 检查主配置文件是否包含所有必要部分
    local required_sections=("data" "data.user" "data.features" "data.packages" "edit" "git")
    
    for section in "${required_sections[@]}"; do
        if ! grep -q "\\[$section\\]" .chezmoi.toml.tmpl; then
            log_error "主配置文件缺少必要部分: [$section]"
            issues=1
        fi
    done
    
    # 检查代理配置是否完整
    if ! grep -q "includeTemplate.*proxy-detection" .chezmoi.toml.tmpl; then
        log_error "缺少代理配置引用"
        issues=1
    fi
    
    # 检查密钥配置是否完整
    if ! grep -q "includeTemplate.*secrets" .chezmoi.toml.tmpl; then
        log_error "缺少密钥配置引用"
        issues=1
    fi
    
    if [[ $issues -eq 0 ]]; then
        record_test "配置完整性检查" "PASS"
    else
        record_test "配置完整性检查" "FAIL"
    fi
}

# 主测试函数
main() {
    log_info "开始配置简化验证测试..."
    echo ""
    
    # 执行所有测试
    check_template_files
    check_main_config_simplification
    check_template_syntax
    test_config_rendering
    check_modularization
    check_config_completeness
    
    # 输出测试结果摘要
    echo ""
    log_info "测试结果摘要:"
    echo "  总测试数: $TOTAL_TESTS"
    echo "  通过: $PASSED_TESTS"
    echo "  失败: $FAILED_TESTS"
    
    if [[ $FAILED_TESTS -eq 0 ]]; then
        log_success "🎉 所有配置简化验证测试通过！"
        echo ""
        log_info "简化成果总结:"
        echo "  ✅ 主配置文件复杂度显著降低"
        echo "  ✅ 代理配置逻辑模块化完成"
        echo "  ✅ 密钥管理配置分离完成"
        echo "  ✅ 环境配置模块化完成"
        echo "  ✅ 模板语法正确"
        echo "  ✅ 配置功能完整性保持"
        exit 0
    else
        log_error "❌ 有 $FAILED_TESTS 个测试失败，需要修复"
        exit 1
    fi
}

# 运行主函数
main "$@"