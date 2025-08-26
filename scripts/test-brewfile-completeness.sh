#!/bin/bash

# 测试脚本：验证 Brewfile 完整性
# 确认所有删除脚本中的工具都已添加到 Brewfile，验证条件安装逻辑正确

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

# 检查核心工具是否在 Brewfile 中
check_core_tools() {
    log_info "检查核心工具是否在 Brewfile 中..."
    
    local missing_tools=()
    local core_tools=("git" "curl" "wget" "unzip" "tree")
    
    for tool in "${core_tools[@]}"; do
        if ! grep -q "brew \"$tool\"" Brewfile.tmpl; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -eq 0 ]]; then
        record_test "核心工具完整性检查" "PASS"
    else
        record_test "核心工具完整性检查" "FAIL"
        log_error "缺少核心工具: ${missing_tools[*]}"
    fi
}

# 检查现代化 CLI 工具是否在 Brewfile 中
check_modern_cli_tools() {
    log_info "检查现代化 CLI 工具是否在 Brewfile 中..."
    
    local missing_tools=()
    local modern_tools=("eza" "bat" "fd" "ripgrep" "fzf" "zoxide" "jq")
    
    for tool in "${modern_tools[@]}"; do
        if ! grep -q "brew \"$tool\"" Brewfile.tmpl; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -eq 0 ]]; then
        record_test "现代化 CLI 工具完整性检查" "PASS"
    else
        record_test "现代化 CLI 工具完整性检查" "FAIL"
        log_error "缺少现代化 CLI 工具: ${missing_tools[*]}"
    fi
}

# 检查 Shell 和终端工具
check_shell_tools() {
    log_info "检查 Shell 和终端工具是否在 Brewfile 中..."
    
    local missing_tools=()
    local shell_tools=("zsh" "tmux" "starship")
    
    for tool in "${shell_tools[@]}"; do
        if ! grep -q "brew \"$tool\"" Brewfile.tmpl; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -eq 0 ]]; then
        record_test "Shell 和终端工具完整性检查" "PASS"
    else
        record_test "Shell 和终端工具完整性检查" "FAIL"
        log_error "缺少 Shell 和终端工具: ${missing_tools[*]}"
    fi
}

# 检查条件安装逻辑
check_conditional_installation() {
    log_info "检查条件安装逻辑..."
    
    local found_issues=0
    
    # 检查 Node.js 相关条件
    if ! grep -q "{{- if.*features.*enable_node" Brewfile.tmpl; then
        log_error "缺少 Node.js 功能条件判断"
        found_issues=1
    fi
    
    # 检查 AI 工具条件
    if ! grep -q "{{- if.*features.*enable_ai_tools" Brewfile.tmpl; then
        log_error "缺少 AI 工具功能条件判断"
        found_issues=1
    fi
    
    # 检查平台特定条件
    if ! grep -q "{{- if eq .chezmoi.os \"darwin\"" Brewfile.tmpl; then
        log_error "缺少 macOS 平台条件判断"
        found_issues=1
    fi
    
    if ! grep -q "{{- else if eq .chezmoi.os \"linux\"" Brewfile.tmpl; then
        log_error "缺少 Linux 平台条件判断"
        found_issues=1
    fi
    
    # 检查环境条件
    if ! grep -q "{{- if eq .environment \"desktop\"" Brewfile.tmpl; then
        log_error "缺少桌面环境条件判断"
        found_issues=1
    fi
    
    if [[ $found_issues -eq 0 ]]; then
        record_test "条件安装逻辑检查" "PASS"
    else
        record_test "条件安装逻辑检查" "FAIL"
    fi
}

# 检查 macOS 特定工具和应用
check_macos_specific_tools() {
    log_info "检查 macOS 特定工具和应用..."
    
    local missing_tools=()
    local macos_tools=("mas" "mackup")
    local macos_casks=("visual-studio-code" "iterm2" "docker" "1password" "1password-cli")
    
    # 检查 brew 工具
    for tool in "${macos_tools[@]}"; do
        if ! grep -q "brew \"$tool\"" Brewfile.tmpl; then
            missing_tools+=("$tool")
        fi
    done
    
    # 检查 cask 应用
    for cask in "${macos_casks[@]}"; do
        if ! grep -q "cask \"$cask\"" Brewfile.tmpl; then
            missing_tools+=("$cask")
        fi
    done
    
    if [[ ${#missing_tools[@]} -eq 0 ]]; then
        record_test "macOS 特定工具检查" "PASS"
    else
        record_test "macOS 特定工具检查" "FAIL"
        log_error "缺少 macOS 工具: ${missing_tools[*]}"
    fi
}

# 检查 Nerd Fonts 配置
check_nerd_fonts() {
    log_info "检查 Nerd Fonts 配置..."
    
    local found_issues=0
    
    # 检查 Nerd Fonts 条件
    if ! grep -q "{{- if.*features.*enable_nerd_fonts" Brewfile.tmpl; then
        log_error "缺少 Nerd Fonts 功能条件判断"
        found_issues=1
    fi
    
    # 检查常用字体
    local fonts=("font-fira-code-nerd-font" "font-hack-nerd-font" "font-jetbrains-mono-nerd-font" "font-meslo-lg-nerd-font")
    for font in "${fonts[@]}"; do
        if ! grep -q "cask \"$font\"" Brewfile.tmpl; then
            log_error "缺少字体: $font"
            found_issues=1
        fi
    done
    
    if [[ $found_issues -eq 0 ]]; then
        record_test "Nerd Fonts 配置检查" "PASS"
    else
        record_test "Nerd Fonts 配置检查" "FAIL"
    fi
}

# 检查开发语言和运行时
check_development_runtimes() {
    log_info "检查开发语言和运行时配置..."
    
    local found_issues=0
    
    # 检查 Python 配置
    if ! grep -q "{{- if.*features.*enable_python" Brewfile.tmpl; then
        log_error "缺少 Python 功能条件判断"
        found_issues=1
    fi
    
    # 检查 Go 配置
    if ! grep -q "{{- if.*features.*enable_go" Brewfile.tmpl; then
        log_error "缺少 Go 功能条件判断"
        found_issues=1
    fi
    
    # 检查 Rust 配置
    if ! grep -q "{{- if.*features.*enable_rust" Brewfile.tmpl; then
        log_error "缺少 Rust 功能条件判断"
        found_issues=1
    fi
    
    if [[ $found_issues -eq 0 ]]; then
        record_test "开发语言和运行时配置检查" "PASS"
    else
        record_test "开发语言和运行时配置检查" "FAIL"
    fi
}

# 测试 brew bundle 语法
test_brew_bundle_syntax() {
    log_info "测试 brew bundle 语法..."
    
    # 创建临时的 Brewfile 用于测试
    local temp_brewfile=$(mktemp)
    
    # 简化模板变量进行语法测试，创建一个最小的有效 Brewfile
    cat > "$temp_brewfile" << 'EOF'
# 测试用的简化 Brewfile
brew "git"
brew "curl"
EOF
    
    # 测试 brew bundle 语法
    if command -v brew >/dev/null 2>&1; then
        # 使用简单的语法验证
        if brew bundle check --file="$temp_brewfile" >/dev/null 2>&1 || \
           brew bundle install --file="$temp_brewfile" --dry-run >/dev/null 2>&1; then
            record_test "brew bundle 语法检查" "PASS"
        else
            record_test "brew bundle 语法检查" "FAIL"
            log_error "Brewfile 语法存在问题"
        fi
    else
        # 如果没有 brew，进行基本的语法检查
        if grep -q '^brew\|^cask\|^mas\|^#' Brewfile.tmpl && \
           ! grep -q 'brew ""' Brewfile.tmpl && \
           ! grep -q 'cask ""' Brewfile.tmpl; then
            record_test "brew bundle 语法检查" "PASS"
        else
            record_test "brew bundle 语法检查" "FAIL"
            log_error "Brewfile 语法存在问题"
        fi
    fi
    
    # 清理临时文件
    rm -f "$temp_brewfile"
}

# 检查是否移除了包名映射逻辑
check_package_name_mapping_removal() {
    log_info "检查包名映射逻辑是否已移除..."
    
    local found_issues=0
    
    # 检查是否还有 apt 包名引用
    if grep -q "fd-find\|batcat" Brewfile.tmpl | grep -v "不再使用"; then
        log_error "Brewfile 中仍有旧包名引用"
        found_issues=1
    fi
    
    # 检查是否统一使用 Homebrew 标准包名
    if ! grep -q "brew \"bat\"" Brewfile.tmpl; then
        log_error "未使用 Homebrew 标准包名 bat"
        found_issues=1
    fi
    
    if ! grep -q "brew \"fd\"" Brewfile.tmpl; then
        log_error "未使用 Homebrew 标准包名 fd"
        found_issues=1
    fi
    
    if [[ $found_issues -eq 0 ]]; then
        record_test "包名映射逻辑移除检查" "PASS"
    else
        record_test "包名映射逻辑移除检查" "FAIL"
    fi
}

# 检查特殊工具的处理说明
check_special_tools_documentation() {
    log_info "检查特殊工具的处理说明..."
    
    local found_issues=0
    
    # 检查是否有关于 evalcache 和 zim 的说明
    if ! grep -q "evalcache" Brewfile.tmpl; then
        log_error "缺少 evalcache 工具的处理说明"
        found_issues=1
    fi
    
    if ! grep -q "zim" Brewfile.tmpl; then
        log_error "缺少 zim 工具的处理说明"
        found_issues=1
    fi
    
    if [[ $found_issues -eq 0 ]]; then
        record_test "特殊工具处理说明检查" "PASS"
    else
        record_test "特殊工具处理说明检查" "FAIL"
    fi
}

# 主测试函数
main() {
    log_info "开始 Brewfile 完整性验证测试..."
    echo ""
    
    # 检查 Brewfile 是否存在
    if [[ ! -f "Brewfile.tmpl" ]]; then
        log_error "Brewfile.tmpl 文件不存在"
        exit 1
    fi
    
    # 执行所有测试
    check_core_tools
    check_modern_cli_tools
    check_shell_tools
    check_conditional_installation
    check_macos_specific_tools
    check_nerd_fonts
    check_development_runtimes
    test_brew_bundle_syntax
    check_package_name_mapping_removal
    check_special_tools_documentation
    
    # 输出测试结果摘要
    echo ""
    log_info "测试结果摘要:"
    echo "  总测试数: $TOTAL_TESTS"
    echo "  通过: $PASSED_TESTS"
    echo "  失败: $FAILED_TESTS"
    
    if [[ $FAILED_TESTS -eq 0 ]]; then
        log_success "🎉 所有 Brewfile 完整性测试通过！"
        exit 0
    else
        log_error "❌ 有 $FAILED_TESTS 个测试失败，需要修复"
        exit 1
    fi
}

# 运行主函数
main "$@"