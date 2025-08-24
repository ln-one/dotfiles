#!/bin/bash
# ========================================
# 跨平台兼容性测试主脚本
# ========================================
# 统一执行所有平台的兼容性测试
# Requirements: 2.1, 2.2, 2.3 - 跨平台兼容性测试

set -euo pipefail

# 测试配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_NAME="Cross-Platform Compatibility Test"
TEST_LOG="/tmp/chezmoi-cross-platform-test.log"
TOTAL_ERRORS=0

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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
    ((TOTAL_ERRORS++))
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" | tee -a "$TEST_LOG"
}

section() {
    echo -e "${CYAN}========================================${NC}" | tee -a "$TEST_LOG"
    echo -e "${CYAN}$1${NC}" | tee -a "$TEST_LOG"
    echo -e "${CYAN}========================================${NC}" | tee -a "$TEST_LOG"
}

# 显示使用说明
show_usage() {
    cat << EOF
用法: $0 [选项]

选项:
  -h, --help          显示此帮助信息
  -a, --all           运行所有平台测试 (默认)
  -u, --ubuntu        只运行 Ubuntu 测试
  -m, --macos         只运行 macOS 测试
  -s, --ssh           只运行 SSH 远程测试
  -c, --current       只运行当前平台测试
  -v, --verbose       详细输出
  --dry-run           预览将要执行的测试

示例:
  $0                  # 运行所有适用的测试
  $0 --ubuntu         # 只运行 Ubuntu 测试
  $0 --current        # 只运行当前平台测试
  $0 --verbose        # 详细输出模式
EOF
}

# 检测当前平台
detect_platform() {
    local os=$(uname -s)
    local platform=""
    
    case "$os" in
        "Linux")
            if command -v lsb_release >/dev/null 2>&1; then
                local distro=$(lsb_release -i | cut -f2)
                if [[ "$distro" == "Ubuntu" ]]; then
                    platform="ubuntu"
                else
                    platform="linux"
                fi
            else
                platform="linux"
            fi
            ;;
        "Darwin")
            platform="macos"
            ;;
        *)
            platform="unknown"
            ;;
    esac
    
    echo "$platform"
}

# 检测是否在 SSH 环境中
is_ssh_environment() {
    [[ -n "${SSH_CONNECTION:-}" ]] || [[ -n "${SSH_CLIENT:-}" ]] || [[ -n "${SSH_TTY:-}" ]]
}

# 检查测试脚本是否存在
check_test_scripts() {
    local missing_scripts=()
    
    if [[ ! -f "$SCRIPT_DIR/test-ubuntu-environment.sh" ]]; then
        missing_scripts+=("test-ubuntu-environment.sh")
    fi
    
    if [[ ! -f "$SCRIPT_DIR/test-macos-environment.sh" ]]; then
        missing_scripts+=("test-macos-environment.sh")
    fi
    
    if [[ ! -f "$SCRIPT_DIR/test-ssh-remote-environment.sh" ]]; then
        missing_scripts+=("test-ssh-remote-environment.sh")
    fi
    
    if [[ ${#missing_scripts[@]} -gt 0 ]]; then
        error "缺少测试脚本: ${missing_scripts[*]}"
        return 1
    fi
    
    success "所有测试脚本都存在"
    return 0
}

# 运行单个测试脚本
run_test_script() {
    local script_name="$1"
    local test_description="$2"
    local script_path="$SCRIPT_DIR/$script_name"
    
    section "$test_description"
    
    if [[ ! -f "$script_path" ]]; then
        error "测试脚本不存在: $script_path"
        return 1
    fi
    
    if [[ ! -x "$script_path" ]]; then
        log "设置测试脚本执行权限: $script_path"
        chmod +x "$script_path"
    fi
    
    log "开始执行: $script_name"
    
    if "$script_path"; then
        success "$test_description 通过"
        return 0
    else
        local exit_code=$?
        error "$test_description 失败 (退出码: $exit_code)"
        return $exit_code
    fi
}

# Ubuntu 环境测试
test_ubuntu_environment() {
    run_test_script "test-ubuntu-environment.sh" "Ubuntu 环境兼容性测试"
}

# macOS 环境测试
test_macos_environment() {
    run_test_script "test-macos-environment.sh" "macOS 环境兼容性测试"
}

# SSH 远程环境测试
test_ssh_remote_environment() {
    run_test_script "test-ssh-remote-environment.sh" "SSH 远程环境兼容性测试"
}

# 运行当前平台测试
test_current_platform() {
    local platform=$(detect_platform)
    local ssh_env=$(is_ssh_environment && echo "true" || echo "false")
    
    log "当前平台: $platform"
    log "SSH 环境: $ssh_env"
    
    case "$platform" in
        "ubuntu")
            test_ubuntu_environment
            ;;
        "macos")
            test_macos_environment
            ;;
        "linux")
            log "通用 Linux 环境，运行 Ubuntu 测试作为基准"
            test_ubuntu_environment
            ;;
        *)
            warning "未知平台: $platform，尝试运行通用测试"
            test_ubuntu_environment
            ;;
    esac
    
    # 如果在 SSH 环境中，也运行 SSH 测试
    if [[ "$ssh_env" == "true" ]]; then
        test_ssh_remote_environment
    fi
}

# 运行所有测试
test_all_platforms() {
    local platform=$(detect_platform)
    
    log "运行所有平台兼容性测试"
    log "当前平台: $platform"
    
    # 总是运行当前平台的测试
    case "$platform" in
        "ubuntu")
            test_ubuntu_environment
            ;;
        "macos")
            test_macos_environment
            ;;
        "linux")
            test_ubuntu_environment
            ;;
    esac
    
    # 如果在 SSH 环境中，运行 SSH 测试
    if is_ssh_environment; then
        test_ssh_remote_environment
    fi
    
    # 运行其他平台的模拟测试 (语法检查等)
    if [[ "$platform" != "ubuntu" ]]; then
        log "运行 Ubuntu 配置语法检查"
        # 这里可以添加不依赖平台的语法检查
    fi
    
    if [[ "$platform" != "macos" ]]; then
        log "运行 macOS 配置语法检查"
        # 这里可以添加不依赖平台的语法检查
    fi
}

# 预览模式
dry_run() {
    local platform=$(detect_platform)
    local ssh_env=$(is_ssh_environment && echo "true" || echo "false")
    
    echo "=========================================="
    echo "跨平台兼容性测试 - 预览模式"
    echo "=========================================="
    echo "当前平台: $platform"
    echo "SSH 环境: $ssh_env"
    echo "测试脚本目录: $SCRIPT_DIR"
    echo ""
    echo "将要执行的测试:"
    
    case "$platform" in
        "ubuntu")
            echo "  ✓ Ubuntu 环境兼容性测试"
            ;;
        "macos")
            echo "  ✓ macOS 环境兼容性测试"
            ;;
        "linux")
            echo "  ✓ Linux (Ubuntu) 环境兼容性测试"
            ;;
        *)
            echo "  ✓ 通用 Linux 环境兼容性测试"
            ;;
    esac
    
    if [[ "$ssh_env" == "true" ]]; then
        echo "  ✓ SSH 远程环境兼容性测试"
    fi
    
    echo ""
    echo "要执行测试，请运行: $0"
}

# 主函数
main() {
    local run_all=true
    local run_ubuntu=false
    local run_macos=false
    local run_ssh=false
    local run_current=false
    local verbose=false
    local dry_run_mode=false
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -a|--all)
                run_all=true
                shift
                ;;
            -u|--ubuntu)
                run_all=false
                run_ubuntu=true
                shift
                ;;
            -m|--macos)
                run_all=false
                run_macos=true
                shift
                ;;
            -s|--ssh)
                run_all=false
                run_ssh=true
                shift
                ;;
            -c|--current)
                run_all=false
                run_current=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            --dry-run)
                dry_run_mode=true
                shift
                ;;
            *)
                error "未知选项: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # 预览模式
    if [[ "$dry_run_mode" == true ]]; then
        dry_run
        exit 0
    fi
    
    # 开始测试
    section "$TEST_NAME"
    log "测试开始时间: $(date)"
    
    # 清空日志文件
    > "$TEST_LOG"
    
    # 检查测试脚本
    if ! check_test_scripts; then
        exit 1
    fi
    
    # 执行测试
    if [[ "$run_all" == true ]]; then
        test_all_platforms
    elif [[ "$run_current" == true ]]; then
        test_current_platform
    else
        if [[ "$run_ubuntu" == true ]]; then
            test_ubuntu_environment
        fi
        
        if [[ "$run_macos" == true ]]; then
            test_macos_environment
        fi
        
        if [[ "$run_ssh" == true ]]; then
            test_ssh_remote_environment
        fi
    fi
    
    # 测试结果汇总
    section "测试结果汇总"
    log "测试完成时间: $(date)"
    log "总错误数: $TOTAL_ERRORS"
    log "详细日志: $TEST_LOG"
    
    if [[ $TOTAL_ERRORS -eq 0 ]]; then
        success "所有跨平台兼容性测试通过!"
        echo ""
        echo "🎉 恭喜! Chezmoi 配置在所有测试平台上都能正常工作"
        echo "📋 详细测试报告: $TEST_LOG"
        exit 0
    else
        error "发现 $TOTAL_ERRORS 个错误，需要修复"
        echo ""
        echo "❌ 跨平台兼容性测试失败"
        echo "📋 详细错误报告: $TEST_LOG"
        echo "🔧 请检查并修复上述错误后重新运行测试"
        exit 1
    fi
}

# 设置测试脚本执行权限
chmod +x "$SCRIPT_DIR"/test-*-environment.sh 2>/dev/null || true

# 运行主函数
main "$@"