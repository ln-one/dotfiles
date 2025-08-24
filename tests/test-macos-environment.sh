#!/bin/bash
# ========================================
# macOS 环境测试脚本
# ========================================
# 测试 Chezmoi 配置在 macOS 环境下的兼容性
# Requirements: 2.2 - macOS 平台支持

set -euo pipefail

# 测试配置
TEST_NAME="macOS Environment Test"
TEST_LOG="/tmp/chezmoi-macos-test.log"
ERRORS=0

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$TEST_LOG"
}

success() {
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$TEST_LOG"
}

error() {
    echo -e "${RED}❌ $1${NC}" | tee -a "$TEST_LOG"
    ((ERRORS++))
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" | tee -a "$TEST_LOG"
}

# 测试开始
log "开始 $TEST_NAME"
log "测试环境: $(sw_vers -productName) $(sw_vers -productVersion)"
log "内核版本: $(uname -r)"
log "架构: $(uname -m)"

# ========================================
# 1. 系统环境检测测试
# ========================================
test_system_detection() {
    log "测试 1: macOS 系统环境检测"
    
    # 检查操作系统检测
    if [[ "$(uname -s)" == "Darwin" ]]; then
        success "操作系统检测正确: Darwin (macOS)"
    else
        error "操作系统检测错误: 期望 Darwin, 实际 $(uname -s)"
    fi
    
    # 检查 macOS 版本
    local macos_version=$(sw_vers -productVersion)
    local major_version=$(echo "$macos_version" | cut -d. -f1)
    if [[ $major_version -ge 12 ]]; then
        success "macOS 版本支持: $macos_version (>= 12.0)"
    else
        warning "macOS 版本较旧: $macos_version (建议 >= 12.0)"
    fi
    
    # 检查架构 (Intel vs Apple Silicon)
    local arch=$(uname -m)
    case "$arch" in
        "x86_64")
            success "架构检测: Intel (x86_64)"
            ;;
        "arm64")
            success "架构检测: Apple Silicon (arm64)"
            ;;
        *)
            warning "未知架构: $arch"
            ;;
    esac
    
    # 检查环境类型检测
    if [[ -n "${SSH_CONNECTION:-}" ]] || [[ -n "${SSH_CLIENT:-}" ]]; then
        success "环境类型检测: remote (SSH)"
    else
        success "环境类型检测: desktop/local"
    fi
}

# ========================================
# 2. Homebrew 集成测试
# ========================================
test_homebrew_integration() {
    log "测试 2: Homebrew 包管理器集成"
    
    # 检查 Homebrew 安装
    if command -v brew >/dev/null 2>&1; then
        success "Homebrew 已安装"
        
        # 检查 Homebrew 版本
        local brew_version=$(brew --version | head -n1)
        success "Homebrew 版本: $brew_version"
        
        # 检查 Homebrew 路径配置
        local brew_prefix=$(brew --prefix)
        if [[ ":$PATH:" == *":$brew_prefix/bin:"* ]]; then
            success "Homebrew 路径配置正确: $brew_prefix/bin"
        else
            error "Homebrew 路径未正确配置"
        fi
        
        # 测试基础包可用性
        local core_packages=("git" "curl" "wget" "fzf" "ripgrep" "fd" "bat" "eza")
        for package in "${core_packages[@]}"; do
            if brew list "$package" >/dev/null 2>&1; then
                success "核心包 $package 已安装"
            elif brew search "$package" | grep -q "^$package$"; then
                warning "核心包 $package 未安装但可通过 Homebrew 获取"
            else
                error "核心包 $package 在 Homebrew 中不可用"
            fi
        done
        
    else
        error "Homebrew 未安装 - macOS 环境需要 Homebrew"
    fi
}

# ========================================
# 3. Chezmoi 模板渲染测试
# ========================================
test_chezmoi_templates() {
    log "测试 3: Chezmoi 模板渲染 (macOS)"
    
    # 创建临时测试目录
    local test_dir=$(mktemp -d)
    local chezmoi_source="$test_dir/chezmoi-source"
    
    # 复制当前 chezmoi 配置到测试目录
    cp -r "$(pwd)" "$chezmoi_source"
    
    # 测试配置文件渲染
    if chezmoi --source "$chezmoi_source" execute-template < .chezmoi.toml.tmpl > /dev/null 2>&1; then
        success "Chezmoi 配置模板渲染成功"
        
        # 验证 macOS 特定配置
        local rendered_config=$(chezmoi --source "$chezmoi_source" execute-template < .chezmoi.toml.tmpl)
        if echo "$rendered_config" | grep -q 'os = "darwin"'; then
            success "macOS 平台检测正确"
        else
            error "macOS 平台检测失败"
        fi
        
        if echo "$rendered_config" | grep -q 'package_manager = "brew"'; then
            success "Homebrew 包管理器检测正确"
        else
            error "Homebrew 包管理器检测失败"
        fi
        
    else
        error "Chezmoi 配置模板渲染失败"
    fi
    
    # 测试 shell 配置模板
    if chezmoi --source "$chezmoi_source" execute-template < dot_zshrc.tmpl > /dev/null 2>&1; then
        success "Zsh 配置模板渲染成功"
    else
        error "Zsh 配置模板渲染失败"
    fi
    
    if chezmoi --source "$chezmoi_source" execute-template < dot_bashrc.tmpl > /dev/null 2>&1; then
        success "Bash 配置模板渲染成功"
    else
        error "Bash 配置模板渲染失败"
    fi
    
    # 清理
    rm -rf "$test_dir"
}

# ========================================
# 4. Shell 配置测试
# ========================================
test_shell_configs() {
    log "测试 4: macOS Shell 配置兼容性"
    
    # macOS 默认使用 zsh (从 Catalina 开始)
    if command -v zsh >/dev/null 2>&1; then
        success "Zsh 可用 (macOS 默认 shell)"
        
        # 检查 zsh 版本
        local zsh_version=$(zsh --version)
        success "Zsh 版本: $zsh_version"
        
        # 测试 zsh 配置语法
        if zsh -n dot_zshrc.tmpl 2>/dev/null; then
            success "Zsh 配置语法检查通过"
        else
            error "Zsh 配置语法错误"
        fi
    else
        error "Zsh 未找到 - macOS 应该默认包含 zsh"
    fi
    
    # 测试 Bash 配置 (macOS 仍然包含 bash)
    if command -v bash >/dev/null 2>&1; then
        success "Bash 可用"
        
        # 检查 bash 版本
        local bash_version=$(bash --version | head -n1)
        success "Bash 版本: $bash_version"
        
        # 测试 bash 配置语法
        if bash -n dot_bashrc.tmpl 2>/dev/null; then
            success "Bash 配置语法检查通过"
        else
            error "Bash 配置语法错误"
        fi
    else
        error "Bash 未找到"
    fi
}

# ========================================
# 5. macOS 特定功能测试
# ========================================
test_macos_specific_features() {
    log "测试 5: macOS 特定功能"
    
    # 测试 macOS 命令行工具
    if xcode-select -p >/dev/null 2>&1; then
        success "Xcode Command Line Tools 已安装"
    else
        warning "Xcode Command Line Tools 未安装 (某些功能可能受限)"
    fi
    
    # 测试 macOS 路径配置
    local expected_paths=("/usr/local/bin" "/opt/homebrew/bin" "/usr/bin" "/bin")
    for path in "${expected_paths[@]}"; do
        if [[ ":$PATH:" == *":$path:"* ]]; then
            success "路径 $path 在 PATH 中"
        else
            if [[ -d "$path" ]]; then
                warning "路径 $path 存在但不在 PATH 中"
            else
                log "路径 $path 不存在 (可能正常)"
            fi
        fi
    done
    
    # 测试 macOS 环境变量
    if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
        success "HOMEBREW_PREFIX 环境变量已设置: $HOMEBREW_PREFIX"
    else
        warning "HOMEBREW_PREFIX 环境变量未设置"
    fi
    
    # 测试 macOS 特定目录
    local macos_dirs=("$HOME/Applications" "$HOME/Library" "/Applications" "/System")
    for dir in "${macos_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            success "macOS 目录存在: $dir"
        else
            error "macOS 目录缺失: $dir"
        fi
    done
}

# ========================================
# 6. 现代 CLI 工具测试
# ========================================
test_modern_cli_tools() {
    log "测试 6: 现代 CLI 工具兼容性 (macOS)"
    
    # 测试工具可用性
    local modern_tools=("fzf" "ripgrep" "fd" "bat" "eza" "jq" "tree")
    for tool in "${modern_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            success "现代工具 $tool 已安装"
            
            # 测试工具基本功能
            case "$tool" in
                "fzf")
                    if echo "test" | fzf --filter="test" >/dev/null 2>&1; then
                        success "fzf 功能测试通过"
                    fi
                    ;;
                "ripgrep")
                    if echo "test" | rg "test" >/dev/null 2>&1; then
                        success "ripgrep 功能测试通过"
                    fi
                    ;;
                "fd")
                    if fd --version >/dev/null 2>&1; then
                        success "fd 功能测试通过"
                    fi
                    ;;
                "bat")
                    if echo "test" | bat --plain >/dev/null 2>&1; then
                        success "bat 功能测试通过"
                    fi
                    ;;
                "eza")
                    if eza --version >/dev/null 2>&1; then
                        success "eza 功能测试通过"
                    fi
                    ;;
            esac
        else
            if command -v brew >/dev/null 2>&1 && brew search "$tool" | grep -q "^$tool$"; then
                warning "现代工具 $tool 未安装但可通过 Homebrew 获取"
            else
                warning "现代工具 $tool 不可用"
            fi
        fi
    done
}

# ========================================
# 7. 性能测试
# ========================================
test_performance() {
    log "测试 7: macOS Shell 启动性能"
    
    # 测试 Zsh 启动时间
    if command -v zsh >/dev/null 2>&1; then
        local zsh_times=()
        for i in {1..3}; do
            local start_time=$(python3 -c "import time; print(int(time.time() * 1000000))")
            zsh -c "exit" 2>/dev/null
            local end_time=$(python3 -c "import time; print(int(time.time() * 1000000))")
            local duration=$(( (end_time - start_time) / 1000 ))  # ms
            zsh_times+=("$duration")
        done
        
        local zsh_avg=$(( (${zsh_times[0]} + ${zsh_times[1]} + ${zsh_times[2]}) / 3 ))
        if [[ $zsh_avg -lt 500 ]]; then
            success "Zsh 启动性能良好: ${zsh_avg}ms"
        else
            warning "Zsh 启动较慢: ${zsh_avg}ms"
        fi
    fi
    
    # 测试 Bash 启动时间
    if command -v bash >/dev/null 2>&1; then
        local bash_times=()
        for i in {1..3}; do
            local start_time=$(python3 -c "import time; print(int(time.time() * 1000000))")
            bash -c "exit" 2>/dev/null
            local end_time=$(python3 -c "import time; print(int(time.time() * 1000000))")
            local duration=$(( (end_time - start_time) / 1000 ))  # ms
            bash_times+=("$duration")
        done
        
        local bash_avg=$(( (${bash_times[0]} + ${bash_times[1]} + ${bash_times[2]}) / 3 ))
        if [[ $bash_avg -lt 500 ]]; then
            success "Bash 启动性能良好: ${bash_avg}ms"
        else
            warning "Bash 启动较慢: ${bash_avg}ms"
        fi
    fi
}

# ========================================
# 执行所有测试
# ========================================
main() {
    # 清空日志文件
    > "$TEST_LOG"
    
    test_system_detection
    test_homebrew_integration
    test_chezmoi_templates
    test_shell_configs
    test_macos_specific_features
    test_modern_cli_tools
    test_performance
    
    # 测试结果汇总
    log "=========================================="
    log "测试完成: $TEST_NAME"
    log "总错误数: $ERRORS"
    
    if [[ $ERRORS -eq 0 ]]; then
        success "所有测试通过! macOS 环境兼容性良好"
        log "详细日志: $TEST_LOG"
        exit 0
    else
        error "发现 $ERRORS 个错误，需要修复"
        log "详细日志: $TEST_LOG"
        exit 1
    fi
}

# 检查是否在 macOS 环境中运行
if [[ "$(uname -s)" != "Darwin" ]]; then
    warning "当前不是 macOS 环境，某些测试可能不准确"
fi

# 运行测试
main "$@"