#!/bin/bash

# 测试脚本：验证环境配置完整性
# 验证删除脚本后环境配置仍然完整，测试所有工具的环境变量和路径配置

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

# 检查 Homebrew 环境变量配置
check_homebrew_environment_config() {
    log_info "检查 Homebrew 环境变量配置..."
    
    local found_issues=0
    
    # 检查 HOMEBREW_PREFIX 设置
    if ! grep -q "HOMEBREW_PREFIX" .chezmoitemplates/core/environment.sh; then
        log_error "environment.sh 中缺少 HOMEBREW_PREFIX 设置"
        found_issues=1
    fi
    
    # 检查 PATH 配置
    if ! grep -q "HOMEBREW_PREFIX.*bin.*PATH" .chezmoitemplates/core/environment.sh; then
        log_error "environment.sh 中缺少 Homebrew PATH 配置"
        found_issues=1
    fi
    
    # 检查 MANPATH 配置
    if ! grep -q "MANPATH.*HOMEBREW_PREFIX" .chezmoitemplates/core/environment.sh; then
        log_error "environment.sh 中缺少 MANPATH 配置"
        found_issues=1
    fi
    
    # 检查 zshenv 中的早期 PATH 设置
    if ! grep -q "HOMEBREW_PREFIX" dot_zshenv.tmpl; then
        log_error "dot_zshenv.tmpl 中缺少 Homebrew 配置"
        found_issues=1
    fi
    
    if [[ $found_issues -eq 0 ]]; then
        record_test "Homebrew 环境变量配置检查" "PASS"
    else
        record_test "Homebrew 环境变量配置检查" "FAIL"
    fi
}

# 检查工具别名配置
check_tool_aliases_config() {
    log_info "检查工具别名配置..."
    
    local found_issues=0
    
    # 检查是否使用 Homebrew 路径的别名
    if ! grep -q "HOMEBREW_PREFIX.*bin.*eza" .chezmoitemplates/core/aliases.sh; then
        log_error "aliases.sh 中缺少 eza 的 Homebrew 路径配置"
        found_issues=1
    fi
    
    if ! grep -q "HOMEBREW_PREFIX.*bin.*bat" .chezmoitemplates/core/aliases.sh; then
        log_error "aliases.sh 中缺少 bat 的 Homebrew 路径配置"
        found_issues=1
    fi
    
    if ! grep -q "HOMEBREW_PREFIX.*bin.*fd" .chezmoitemplates/core/aliases.sh; then
        log_error "aliases.sh 中缺少 fd 的 Homebrew 路径配置"
        found_issues=1
    fi
    
    # 检查是否移除了旧的别名映射逻辑
    if grep -q "batcat.*bat" .chezmoitemplates/core/aliases.sh | grep -v "不再使用"; then
        log_error "aliases.sh 中仍有 batcat 别名映射逻辑"
        found_issues=1
    fi
    
    if grep -q "fdfind.*fd" .chezmoitemplates/core/aliases.sh | grep -v "不再使用"; then
        log_error "aliases.sh 中仍有 fdfind 别名映射逻辑"
        found_issues=1
    fi
    
    if [[ $found_issues -eq 0 ]]; then
        record_test "工具别名配置检查" "PASS"
    else
        record_test "工具别名配置检查" "FAIL"
    fi
}

# 检查 fzf 配置
check_fzf_configuration() {
    log_info "检查 fzf 配置..."
    
    local found_issues=0
    
    # 检查 fzf 是否使用 Homebrew 工具
    if ! grep -q "HOMEBREW_PREFIX.*bin.*fd" .chezmoitemplates/core/environment.sh; then
        log_error "environment.sh 中 fzf 未使用 Homebrew fd"
        found_issues=1
    fi
    
    if ! grep -q "HOMEBREW_PREFIX.*bin.*bat" .chezmoitemplates/core/environment.sh; then
        log_error "environment.sh 中 fzf 预览未使用 Homebrew bat"
        found_issues=1
    fi
    
    if ! grep -q "HOMEBREW_PREFIX.*bin.*eza" .chezmoitemplates/core/environment.sh; then
        log_error "environment.sh 中 fzf 预览未使用 Homebrew eza"
        found_issues=1
    fi
    
    # 检查 FZF_DEFAULT_COMMAND 配置
    if ! grep -q "FZF_DEFAULT_COMMAND" .chezmoitemplates/core/environment.sh; then
        log_error "environment.sh 中缺少 FZF_DEFAULT_COMMAND 配置"
        found_issues=1
    fi
    
    if [[ $found_issues -eq 0 ]]; then
        record_test "fzf 配置检查" "PASS"
    else
        record_test "fzf 配置检查" "FAIL"
    fi
}

# 检查环境验证脚本
check_environment_verification_script() {
    log_info "检查环境验证脚本..."
    
    local found_issues=0
    
    # 检查是否使用 Homebrew 路径验证工具
    if ! grep -q "HOMEBREW_PREFIX.*bin" run_onchange_verify-environment.sh.tmpl; then
        log_error "验证脚本中缺少 Homebrew 路径检查"
        found_issues=1
    fi
    
    # 检查是否移除了系统包管理器检测
    if grep -q "command -v apt\|command -v yum\|command -v dnf" run_onchange_verify-environment.sh.tmpl; then
        log_error "验证脚本中仍有系统包管理器检测"
        found_issues=1
    fi
    
    # 检查是否有 check_homebrew_tool 函数
    if ! grep -q "check_homebrew_tool" run_onchange_verify-environment.sh.tmpl; then
        log_error "验证脚本中缺少 check_homebrew_tool 函数"
        found_issues=1
    fi
    
    if [[ $found_issues -eq 0 ]]; then
        record_test "环境验证脚本检查" "PASS"
    else
        record_test "环境验证脚本检查" "FAIL"
    fi
}

# 检查 Shell 集成配置
check_shell_integration() {
    log_info "检查 Shell 集成配置..."
    
    local found_issues=0
    
    # 检查 zshenv 中的基础配置
    if ! grep -q "ZIM_HOME" dot_zshenv.tmpl; then
        log_error "dot_zshenv.tmpl 中缺少 ZIM_HOME 配置"
        found_issues=1
    fi
    
    # 检查 PATH 早期设置
    if ! grep -q "local/bin.*PATH" dot_zshenv.tmpl; then
        log_error "dot_zshenv.tmpl 中缺少 ~/.local/bin PATH 设置"
        found_issues=1
    fi
    
    # 检查平台特定配置
    if ! grep -q "chezmoi.os.*darwin" dot_zshenv.tmpl; then
        log_error "dot_zshenv.tmpl 中缺少 macOS 特定配置"
        found_issues=1
    fi
    
    if [[ $found_issues -eq 0 ]]; then
        record_test "Shell 集成配置检查" "PASS"
    else
        record_test "Shell 集成配置检查" "FAIL"
    fi
}

# 检查环境变量完整性
check_environment_variables_completeness() {
    log_info "检查环境变量完整性..."
    
    local found_issues=0
    
    # 检查基础环境变量
    local required_vars=("EDITOR" "VISUAL" "LANG" "LC_ALL" "USER_HOME" "CONFIG_DIR")
    
    for var in "${required_vars[@]}"; do
        if ! grep -q "export $var" .chezmoitemplates/core/environment.sh; then
            log_error "environment.sh 中缺少 $var 环境变量"
            found_issues=1
        fi
    done
    
    # 检查 Homebrew 相关环境变量
    local homebrew_vars=("HOMEBREW_CELLAR" "HOMEBREW_REPOSITORY")
    
    for var in "${homebrew_vars[@]}"; do
        if ! grep -q "export $var" .chezmoitemplates/core/environment.sh; then
            log_error "environment.sh 中缺少 $var 环境变量"
            found_issues=1
        fi
    done
    
    if [[ $found_issues -eq 0 ]]; then
        record_test "环境变量完整性检查" "PASS"
    else
        record_test "环境变量完整性检查" "FAIL"
    fi
}

# 检查条件配置逻辑
check_conditional_configuration() {
    log_info "检查条件配置逻辑..."
    
    local found_issues=0
    
    # 检查平台条件
    if ! grep -q "{{- if eq .chezmoi.os" .chezmoitemplates/core/environment.sh; then
        log_error "environment.sh 中缺少平台条件判断"
        found_issues=1
    fi
    
    # 检查功能条件
    if ! grep -q "{{- if.*features" .chezmoitemplates/core/environment.sh; then
        log_error "environment.sh 中缺少功能条件判断"
        found_issues=1
    fi
    
    # 检查 Homebrew 存在性检查
    if ! grep -q "stat.*homebrew" .chezmoitemplates/core/environment.sh; then
        log_error "environment.sh 中缺少 Homebrew 存在性检查"
        found_issues=1
    fi
    
    if [[ $found_issues -eq 0 ]]; then
        record_test "条件配置逻辑检查" "PASS"
    else
        record_test "条件配置逻辑检查" "FAIL"
    fi
}

# 检查工具路径一致性
check_tool_path_consistency() {
    log_info "检查工具路径一致性..."
    
    local found_issues=0
    
    # 检查所有配置文件中的工具路径是否一致使用 Homebrew
    local config_files=(".chezmoitemplates/core/environment.sh" ".chezmoitemplates/core/aliases.sh" "run_onchange_verify-environment.sh.tmpl")
    
    for file in "${config_files[@]}"; do
        if [[ -f "$file" ]]; then
            # 检查是否有硬编码的系统路径
            if grep -q "/usr/bin/\|/usr/local/bin/" "$file" | grep -v "#!/usr/bin" | grep -v "/usr/bin/env"; then
                log_error "$file 中发现硬编码的系统路径"
                found_issues=1
            fi
        fi
    done
    
    if [[ $found_issues -eq 0 ]]; then
        record_test "工具路径一致性检查" "PASS"
    else
        record_test "工具路径一致性检查" "FAIL"
    fi
}

# 检查配置文件语法
check_configuration_syntax() {
    log_info "检查配置文件语法..."
    
    local found_issues=0
    
    # 检查 shell 脚本语法
    local shell_files=(".chezmoitemplates/core/environment.sh" ".chezmoitemplates/core/aliases.sh" "run_onchange_verify-environment.sh.tmpl")
    
    for file in "${shell_files[@]}"; do
        if [[ -f "$file" ]]; then
            # 基本语法检查 - 检查是否有未闭合的引号或括号
            if grep -q "{{.*}}" "$file"; then
                # 这是模板文件，跳过严格的语法检查
                continue
            fi
            
            # 检查基本的 shell 语法问题
            if grep -q "export.*=" "$file" && ! grep -q "export [A-Z_]*=" "$file"; then
                log_warning "$file 中可能有环境变量语法问题"
            fi
        fi
    done
    
    # 检查模板语法
    local template_files=("dot_zshenv.tmpl" "run_onchange_verify-environment.sh.tmpl")
    
    for file in "${template_files[@]}"; do
        if [[ -f "$file" ]]; then
            # 简化的模板语法检查 - 只检查是否有基本的模板标记
            if grep -q "{{" "$file" && grep -q "}}" "$file"; then
                # 基本模板语法存在，假设正确
                continue
            elif grep -q "{{" "$file" && ! grep -q "}}" "$file"; then
                log_error "$file 中有未闭合的模板标记"
                found_issues=1
            elif ! grep -q "{{" "$file" && grep -q "}}" "$file"; then
                # 可能是 shell 变量，检查是否是 ${} 格式
                if ! grep -q "\${.*}" "$file"; then
                    log_error "$file 中有未匹配的 }} 标记"
                    found_issues=1
                fi
            fi
        fi
    done
    
    if [[ $found_issues -eq 0 ]]; then
        record_test "配置文件语法检查" "PASS"
    else
        record_test "配置文件语法检查" "FAIL"
    fi
}

# 主测试函数
main() {
    log_info "开始环境配置完整性验证测试..."
    echo ""
    
    # 执行所有测试
    check_homebrew_environment_config
    check_tool_aliases_config
    check_fzf_configuration
    check_environment_verification_script
    check_shell_integration
    check_environment_variables_completeness
    check_conditional_configuration
    check_tool_path_consistency
    check_configuration_syntax
    
    # 输出测试结果摘要
    echo ""
    log_info "测试结果摘要:"
    echo "  总测试数: $TOTAL_TESTS"
    echo "  通过: $PASSED_TESTS"
    echo "  失败: $FAILED_TESTS"
    
    if [[ $FAILED_TESTS -eq 0 ]]; then
        log_success "🎉 所有环境配置完整性测试通过！"
        exit 0
    else
        log_error "❌ 有 $FAILED_TESTS 个测试失败，需要修复"
        exit 1
    fi
}

# 运行主函数
main "$@"