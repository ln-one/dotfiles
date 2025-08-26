#!/bin/bash
# ========================================
# Ubuntu 环境测试脚本
# ========================================
# 测试 Chezmoi 配置在 Ubuntu 24.04 环境下的兼容性
# Requirements: 2.1 - Ubuntu 24.04 平台支持

set -euo pipefail

# 测试配置
TEST_NAME="Ubuntu Environment Test"
TEST_LOG="/tmp/chezmoi-ubuntu-test.log"
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
log "测试环境: $(lsb_release -d 2>/dev/null | cut -f2 || echo 'Unknown Linux')"
log "内核版本: $(uname -r)"
log "架构: $(uname -m)"

# ========================================
# 1. 系统环境检测测试
# ========================================
test_system_detection() {
    log "测试 1: 系统环境检测"
    
    # 检查操作系统检测
    if [[ "$(uname -s)" == "Linux" ]]; then
        success "操作系统检测正确: Linux"
    else
        error "操作系统检测错误: 期望 Linux, 实际 $(uname -s)"
    fi
    
    # 检查 Homebrew 包管理器 (统一包管理方式)
    if command -v brew >/dev/null 2>&1; then
        success "Homebrew 包管理器检测正确"
    else
        warning "Homebrew 未安装 (需要手动安装)"
    fi
    
    # 检查环境类型检测
    if [[ -n "${SSH_CONNECTION:-}" ]] || [[ -n "${SSH_CLIENT:-}" ]]; then
        success "环境类型检测: remote (SSH)"
    else
        success "环境类型检测: desktop/local"
    fi
    
    # 检查 WSL 检测
    if [[ -f /proc/version ]] && grep -q microsoft /proc/version; then
        success "WSL 环境检测正确"
    fi
}

# ========================================
# 2. Chezmoi 模板渲染测试
# ========================================
test_chezmoi_templates() {
    log "测试 2: Chezmoi 模板渲染"
    
    # 创建临时测试目录
    local test_dir=$(mktemp -d)
    local chezmoi_source="$test_dir/chezmoi-source"
    
    # 复制当前 chezmoi 配置到测试目录
    cp -r "$(pwd)" "$chezmoi_source"
    
    # 测试配置文件渲染
    if chezmoi --source "$chezmoi_source" execute-template < .chezmoi.toml.tmpl > /dev/null 2>&1; then
        success "Chezmoi 配置模板渲染成功"
    else
        error "Chezmoi 配置模板渲染失败"
    fi
    
    # 测试 zshrc 模板渲染
    if chezmoi --source "$chezmoi_source" execute-template < dot_zshrc.tmpl > /dev/null 2>&1; then
        success "Zsh 配置模板渲染成功"
    else
        error "Zsh 配置模板渲染失败"
    fi
    
    # 测试 bashrc 模板渲染
    if chezmoi --source "$chezmoi_source" execute-template < dot_bashrc.tmpl > /dev/null 2>&1; then
        success "Bash 配置模板渲染成功"
    else
        error "Bash 配置模板渲染失败"
    fi
    
    # 清理
    rm -rf "$test_dir"
}

# ========================================
# 3. Shell 配置测试
# ========================================
test_shell_configs() {
    log "测试 3: Shell 配置兼容性"
    
    # 测试 Bash 配置语法
    if bash -n dot_bashrc.tmpl 2>/dev/null; then
        success "Bash 配置语法检查通过"
    else
        error "Bash 配置语法错误"
    fi
    
    # 测试 Zsh 配置 (如果 zsh 可用)
    if command -v zsh >/dev/null 2>&1; then
        if zsh -n dot_zshrc.tmpl 2>/dev/null; then
            success "Zsh 配置语法检查通过"
        else
            error "Zsh 配置语法错误"
        fi
    else
        warning "Zsh 未安装，跳过 Zsh 配置测试"
    fi
}

# ========================================
# 4. Homebrew 包管理器测试
# ========================================
test_package_manager() {
    log "测试 4: Homebrew 统一包管理"
    
    # 测试 Homebrew 可用性
    if command -v brew >/dev/null 2>&1; then
        if brew --version >/dev/null 2>&1; then
            success "Homebrew 在 Linux 上正常工作"
            
            # 测试核心包是否可通过 Homebrew 安装
            local core_packages=("git" "curl" "wget" "unzip")
            for package in "${core_packages[@]}"; do
                if brew info "$package" >/dev/null 2>&1; then
                    success "核心包 $package 可通过 Homebrew 获取"
                else
                    warning "核心包 $package 在 Homebrew 中不可用"
                fi
            done
        else
            error "Homebrew 在 Linux 上异常"
        fi
    else
        warning "Homebrew 未安装 - 这是新的统一包管理要求"
        log "请手动安装 Homebrew: https://brew.sh"
    fi
}

# ========================================
# 5. 现代 CLI 工具测试
# ========================================
test_modern_cli_tools() {
    log "测试 5: 现代 CLI 工具兼容性"
    
    # 测试工具可用性 (使用 Homebrew 标准命令名)
    local modern_tools=("fzf" "ripgrep" "fd" "bat" "eza")
    for tool in "${modern_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            success "现代工具 $tool 已安装"
        else
            # 注意: 现在统一通过 Homebrew 管理，不再检查 apt 包
            warning "现代工具 $tool 未安装 (应通过 Homebrew 安装)"
        fi
    done
}

# ========================================
# 6. 环境变量和路径测试
# ========================================
test_environment_variables() {
    log "测试 6: 环境变量和路径配置"
    
    # 测试基础环境变量
    if [[ -n "${HOME:-}" ]]; then
        success "HOME 环境变量正确设置: $HOME"
    else
        error "HOME 环境变量未设置"
    fi
    
    if [[ -n "${USER:-}" ]]; then
        success "USER 环境变量正确设置: $USER"
    else
        error "USER 环境变量未设置"
    fi
    
    # 测试路径配置
    if [[ ":$PATH:" == *":/usr/local/bin:"* ]]; then
        success "/usr/local/bin 在 PATH 中"
    else
        warning "/usr/local/bin 不在 PATH 中"
    fi
    
    # 测试 XDG 目录
    if [[ -n "${XDG_CONFIG_HOME:-}" ]] || [[ -d "$HOME/.config" ]]; then
        success "XDG 配置目录可用"
    else
        warning "XDG 配置目录不可用"
    fi
}

# ========================================
# 7. 性能测试
# ========================================
test_performance() {
    log "测试 7: Shell 启动性能"
    
    # 测试 Bash 启动时间
    local bash_times=()
    for i in {1..3}; do
        local start_time=$(date +%s%N)
        bash -c "exit" 2>/dev/null
        local end_time=$(date +%s%N)
        local duration=$(( (end_time - start_time) / 1000000 ))  # ms
        bash_times+=("$duration")
    done
    
    local bash_avg=$(( (${bash_times[0]} + ${bash_times[1]} + ${bash_times[2]}) / 3 ))
    if [[ $bash_avg -lt 500 ]]; then
        success "Bash 启动性能良好: ${bash_avg}ms"
    else
        warning "Bash 启动较慢: ${bash_avg}ms"
    fi
    
    # 测试 Zsh 启动时间 (如果可用)
    if command -v zsh >/dev/null 2>&1; then
        local zsh_times=()
        for i in {1..3}; do
            local start_time=$(date +%s%N)
            zsh -c "exit" 2>/dev/null
            local end_time=$(date +%s%N)
            local duration=$(( (end_time - start_time) / 1000000 ))  # ms
            zsh_times+=("$duration")
        done
        
        local zsh_avg=$(( (${zsh_times[0]} + ${zsh_times[1]} + ${zsh_times[2]}) / 3 ))
        if [[ $zsh_avg -lt 500 ]]; then
            success "Zsh 启动性能良好: ${zsh_avg}ms"
        else
            warning "Zsh 启动较慢: ${zsh_avg}ms"
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
    test_chezmoi_templates
    test_shell_configs
    test_package_manager
    test_modern_cli_tools
    test_environment_variables
    test_performance
    
    # 测试结果汇总
    log "=========================================="
    log "测试完成: $TEST_NAME"
    log "总错误数: $ERRORS"
    
    if [[ $ERRORS -eq 0 ]]; then
        success "所有测试通过! Ubuntu 环境兼容性良好"
        log "详细日志: $TEST_LOG"
        exit 0
    else
        error "发现 $ERRORS 个错误，需要修复"
        log "详细日志: $TEST_LOG"
        exit 1
    fi
}

# 检查是否在 Ubuntu 环境中运行
if ! command -v lsb_release >/dev/null 2>&1 || ! lsb_release -i | grep -q Ubuntu; then
    warning "当前不是 Ubuntu 环境，某些测试可能不准确"
fi

# 运行测试
main "$@"