#!/bin/bash
# ========================================
# SSH 远程服务器环境测试脚本
# ========================================
# 测试 Chezmoi 配置在 SSH 远程服务器环境下的兼容性
# Requirements: 2.3 - SSH 远程服务器环境支持

set -euo pipefail

# 测试配置
TEST_NAME="SSH Remote Server Environment Test"
TEST_LOG="/tmp/chezmoi-ssh-test.log"
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
log "测试环境: $(uname -s) $(uname -r)"
log "主机名: $(hostname)"
log "用户: $(whoami)"

# ========================================
# 1. SSH 环境检测测试
# ========================================
test_ssh_environment_detection() {
    log "测试 1: SSH 环境检测"
    
    # 检查 SSH 连接环境变量
    if [[ -n "${SSH_CONNECTION:-}" ]]; then
        success "SSH_CONNECTION 环境变量存在: $SSH_CONNECTION"
        local ssh_info=(${SSH_CONNECTION})
        success "客户端: ${ssh_info[0]}:${ssh_info[1]} -> 服务器: ${ssh_info[2]}:${ssh_info[3]}"
    elif [[ -n "${SSH_CLIENT:-}" ]]; then
        success "SSH_CLIENT 环境变量存在: $SSH_CLIENT"
    elif [[ -n "${SSH_TTY:-}" ]]; then
        success "SSH_TTY 环境变量存在: $SSH_TTY"
    else
        warning "未检测到 SSH 环境变量 (可能不是通过 SSH 连接)"
    fi
    
    # 检查终端类型
    if [[ -n "${TERM:-}" ]]; then
        success "TERM 环境变量: $TERM"
        case "$TERM" in
            "xterm"*|"screen"*|"tmux"*)
                success "终端类型支持颜色输出"
                ;;
            "dumb")
                warning "终端类型不支持颜色输出"
                ;;
            *)
                log "终端类型: $TERM"
                ;;
        esac
    else
        error "TERM 环境变量未设置"
    fi
    
    # 检查是否在容器中
    if [[ -f /.dockerenv ]] || [[ -n "${CONTAINER:-}" ]]; then
        success "检测到容器环境"
    fi
    
    # 检查是否在 WSL 中
    if [[ -f /proc/version ]] && grep -q microsoft /proc/version; then
        success "检测到 WSL 环境"
    fi
}

# ========================================
# 2. 远程环境限制测试
# ========================================
test_remote_environment_constraints() {
    log "测试 2: 远程环境限制和适配"
    
    # 检查网络连接
    if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        success "网络连接正常"
    else
        warning "网络连接受限或无法访问外网"
    fi
    
    # 检查磁盘空间
    local disk_usage=$(df -h "$HOME" | awk 'NR==2 {print $5}' | sed 's/%//')
    if [[ $disk_usage -lt 90 ]]; then
        success "磁盘空间充足: ${disk_usage}% 已使用"
    else
        warning "磁盘空间不足: ${disk_usage}% 已使用"
    fi
    
    # 检查内存使用
    if command -v free >/dev/null 2>&1; then
        local mem_usage=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
        if [[ $mem_usage -lt 80 ]]; then
            success "内存使用正常: ${mem_usage}%"
        else
            warning "内存使用较高: ${mem_usage}%"
        fi
    fi
    
    # 检查用户权限
    if [[ $(id -u) -eq 0 ]]; then
        warning "当前用户是 root (不推荐)"
    else
        success "当前用户是普通用户: $(whoami)"
    fi
    
    # 检查 sudo 权限
    if sudo -n true 2>/dev/null; then
        success "用户有 sudo 权限"
    else
        warning "用户无 sudo 权限 (某些安装可能受限)"
    fi
}

# ========================================
# 3. 基础工具可用性测试
# ========================================
test_basic_tools_availability() {
    log "测试 3: 远程环境基础工具可用性"
    
    # 必需的基础工具
    local essential_tools=("bash" "sh" "cat" "grep" "sed" "awk" "curl" "wget" "git")
    for tool in "${essential_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            success "基础工具 $tool 可用"
        else
            error "基础工具 $tool 不可用"
        fi
    done
    
    # 编辑器可用性
    local editors=("vim" "vi" "nano" "emacs")
    local editor_found=false
    for editor in "${editors[@]}"; do
        if command -v "$editor" >/dev/null 2>&1; then
            success "编辑器 $editor 可用"
            editor_found=true
            break
        fi
    done
    
    if [[ "$editor_found" == false ]]; then
        error "没有找到可用的编辑器"
    fi
    
    # 压缩工具
    local compression_tools=("tar" "gzip" "unzip")
    for tool in "${compression_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            success "压缩工具 $tool 可用"
        else
            warning "压缩工具 $tool 不可用"
        fi
    done
}

# ========================================
# 4. Chezmoi 远程配置测试
# ========================================
test_chezmoi_remote_config() {
    log "测试 4: Chezmoi 远程环境配置"
    
    # 创建临时测试目录
    local test_dir=$(mktemp -d)
    local chezmoi_source="$test_dir/chezmoi-source"
    
    # 复制当前 chezmoi 配置到测试目录
    cp -r "$(pwd)" "$chezmoi_source"
    
    # 测试远程环境配置渲染
    if chezmoi --source "$chezmoi_source" execute-template < .chezmoi.toml.tmpl > "$test_dir/config.toml" 2>&1; then
        success "Chezmoi 配置模板渲染成功"
        
        # 验证远程环境检测
        if grep -q 'environment = "remote"' "$test_dir/config.toml"; then
            success "远程环境检测正确"
        else
            # 如果不是通过 SSH 连接，这是正常的
            if [[ -n "${SSH_CONNECTION:-}${SSH_CLIENT:-}" ]]; then
                error "远程环境检测失败"
            else
                log "非 SSH 环境，远程检测跳过"
            fi
        fi
        
    else
        error "Chezmoi 配置模板渲染失败"
    fi
    
    # 测试远程优化的 shell 配置
    if chezmoi --source "$chezmoi_source" execute-template < dot_bashrc.tmpl > "$test_dir/bashrc" 2>&1; then
        success "远程 Bash 配置渲染成功"
        
        # 检查远程优化配置
        if grep -q "# 远程环境" "$test_dir/bashrc"; then
            success "远程环境优化配置存在"
        fi
        
        # 检查简化的别名
        if grep -q "alias ll=" "$test_dir/bashrc"; then
            success "基础别名配置存在"
        fi
        
    else
        error "远程 Bash 配置渲染失败"
    fi
    
    # 清理
    rm -rf "$test_dir"
}

# ========================================
# 5. 网络和下载测试
# ========================================
test_network_and_downloads() {
    log "测试 5: 网络连接和下载能力"
    
    # 测试 GitHub 连接
    if curl -s --connect-timeout 10 https://api.github.com/zen >/dev/null 2>&1; then
        success "GitHub API 连接正常"
    else
        warning "GitHub API 连接失败 (可能影响 Chezmoi 同步)"
    fi
    
    # 测试 Homebrew 安装脚本下载 (不实际安装)
    if curl -s --connect-timeout 10 -I https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | grep -q "200 OK"; then
        success "Homebrew 安装脚本可访问"
    else
        warning "Homebrew 安装脚本不可访问"
    fi
    
    # 测试 Chezmoi 二进制下载
    if curl -s --connect-timeout 10 -I https://get.chezmoi.io | grep -q "200 OK"; then
        success "Chezmoi 安装脚本可访问"
    else
        warning "Chezmoi 安装脚本不可访问"
    fi
    
    # 测试 DNS 解析
    if nslookup github.com >/dev/null 2>&1; then
        success "DNS 解析正常"
    else
        warning "DNS 解析可能有问题"
    fi
}

# ========================================
# 6. Shell 配置和性能测试
# ========================================
test_shell_performance() {
    log "测试 6: 远程环境 Shell 性能"
    
    # 测试 Bash 启动时间 (远程环境通常较慢)
    local bash_times=()
    for i in {1..3}; do
        local start_time=$(date +%s%N)
        bash -c "exit" 2>/dev/null
        local end_time=$(date +%s%N)
        local duration=$(( (end_time - start_time) / 1000000 ))  # ms
        bash_times+=("$duration")
    done
    
    local bash_avg=$(( (${bash_times[0]} + ${bash_times[1]} + ${bash_times[2]}) / 3 ))
    # 远程环境允许更长的启动时间
    if [[ $bash_avg -lt 1000 ]]; then
        success "Bash 启动性能良好: ${bash_avg}ms"
    elif [[ $bash_avg -lt 2000 ]]; then
        warning "Bash 启动较慢但可接受: ${bash_avg}ms"
    else
        error "Bash 启动过慢: ${bash_avg}ms"
    fi
    
    # 测试 Zsh (如果可用)
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
        if [[ $zsh_avg -lt 1000 ]]; then
            success "Zsh 启动性能良好: ${zsh_avg}ms"
        elif [[ $zsh_avg -lt 2000 ]]; then
            warning "Zsh 启动较慢但可接受: ${zsh_avg}ms"
        else
            error "Zsh 启动过慢: ${zsh_avg}ms"
        fi
    else
        log "Zsh 不可用 (远程环境常见)"
    fi
}

# ========================================
# 7. 安全和权限测试
# ========================================
test_security_and_permissions() {
    log "测试 7: 远程环境安全和权限"
    
    # 检查 HOME 目录权限
    local home_perms=$(stat -c "%a" "$HOME" 2>/dev/null || stat -f "%A" "$HOME" 2>/dev/null)
    if [[ "$home_perms" == "700" ]] || [[ "$home_perms" == "755" ]]; then
        success "HOME 目录权限正确: $home_perms"
    else
        warning "HOME 目录权限: $home_perms (可能需要调整)"
    fi
    
    # 检查 SSH 密钥目录
    if [[ -d "$HOME/.ssh" ]]; then
        local ssh_perms=$(stat -c "%a" "$HOME/.ssh" 2>/dev/null || stat -f "%A" "$HOME/.ssh" 2>/dev/null)
        if [[ "$ssh_perms" == "700" ]]; then
            success "SSH 目录权限正确: $ssh_perms"
        else
            warning "SSH 目录权限: $ssh_perms (应该是 700)"
        fi
    fi
    
    # 检查 umask 设置
    local current_umask=$(umask)
    if [[ "$current_umask" == "0022" ]] || [[ "$current_umask" == "022" ]]; then
        success "umask 设置合理: $current_umask"
    else
        warning "umask 设置: $current_umask (可能需要调整)"
    fi
    
    # 检查环境变量安全
    if [[ -z "${HISTFILE:-}" ]] || [[ "$HISTFILE" == "/dev/null" ]]; then
        warning "历史文件被禁用 (安全但可能影响使用体验)"
    else
        success "历史文件正常: ${HISTFILE:-默认}"
    fi
}

# ========================================
# 执行所有测试
# ========================================
main() {
    # 清空日志文件
    > "$TEST_LOG"
    
    test_ssh_environment_detection
    test_remote_environment_constraints
    test_basic_tools_availability
    test_chezmoi_remote_config
    test_network_and_downloads
    test_shell_performance
    test_security_and_permissions
    
    # 测试结果汇总
    log "=========================================="
    log "测试完成: $TEST_NAME"
    log "总错误数: $ERRORS"
    
    if [[ $ERRORS -eq 0 ]]; then
        success "所有测试通过! SSH 远程环境兼容性良好"
        log "详细日志: $TEST_LOG"
        exit 0
    else
        error "发现 $ERRORS 个错误，需要修复"
        log "详细日志: $TEST_LOG"
        exit 1
    fi
}

# 运行测试
main "$@"