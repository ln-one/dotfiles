#!/bin/bash
# ========================================
# Evalcache 测试脚本
# ========================================
# 测试 evalcache 的安装和性能效果

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# 检查 evalcache 安装
check_evalcache_installation() {
    log_info "检查 evalcache 安装状态..."
    
    if [[ -d "$HOME/.evalcache" ]]; then
        log_success "✅ evalcache 目录存在"
    else
        log_error "❌ evalcache 目录不存在"
        return 1
    fi
    
    if [[ -f "$HOME/.evalcache/evalcache.plugin.zsh" ]]; then
        log_success "✅ evalcache 插件文件存在"
    else
        log_error "❌ evalcache 插件文件不存在"
        return 1
    fi
    
    if [[ -d "$HOME/.cache/evalcache" ]]; then
        log_success "✅ evalcache 缓存目录存在"
    else
        log_warning "⚠️  evalcache 缓存目录不存在，将在首次使用时创建"
    fi
}

# 测试 evalcache 功能
test_evalcache_function() {
    log_info "测试 evalcache 功能..."
    
    # 临时加载 evalcache
    if [[ -f "$HOME/.evalcache/evalcache.plugin.zsh" ]]; then
        source "$HOME/.evalcache/evalcache.plugin.zsh"
        
        if command -v _evalcache >/dev/null 2>&1; then
            log_success "✅ _evalcache 函数可用"
        else
            log_error "❌ _evalcache 函数不可用"
            return 1
        fi
    else
        log_error "❌ 无法加载 evalcache 插件"
        return 1
    fi
}

# 测试工具缓存
test_tool_caching() {
    log_info "测试工具缓存功能..."
    
    # 测试 echo 命令（简单测试）
    log_info "测试基础缓存功能..."
    
    # 清理测试缓存
    local test_cache="$HOME/.cache/evalcache/echo.cache"
    [[ -f "$test_cache" ]] && rm "$test_cache"
    
    # 第一次运行（应该创建缓存）
    local start_time=$(date +%s%N)
    _evalcache echo "test cache"
    local first_run_time=$(($(date +%s%N) - start_time))
    
    if [[ -f "$test_cache" ]]; then
        log_success "✅ 缓存文件已创建"
    else
        log_error "❌ 缓存文件未创建"
        return 1
    fi
    
    # 第二次运行（应该使用缓存）
    start_time=$(date +%s%N)
    _evalcache echo "test cache"
    local second_run_time=$(($(date +%s%N) - start_time))
    
    log_info "第一次运行时间: ${first_run_time}ns"
    log_info "第二次运行时间: ${second_run_time}ns"
    
    if [[ $second_run_time -lt $first_run_time ]]; then
        log_success "✅ 缓存加速效果明显"
    else
        log_warning "⚠️  缓存效果不明显（可能是测试命令太简单）"
    fi
    
    # 清理测试缓存
    [[ -f "$test_cache" ]] && rm "$test_cache"
}

# 测试实际工具
test_real_tools() {
    log_info "测试实际工具缓存..."
    
    local tools=("starship" "zoxide" "fzf")
    
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            log_info "测试 $tool..."
            
            case "$tool" in
                "starship")
                    _evalcache starship init zsh >/dev/null 2>&1 && log_success "✅ $tool 缓存成功" || log_warning "⚠️  $tool 缓存可能失败"
                    ;;
                "zoxide")
                    _evalcache zoxide init zsh >/dev/null 2>&1 && log_success "✅ $tool 缓存成功" || log_warning "⚠️  $tool 缓存可能失败"
                    ;;
                "fzf")
                    if fzf --help 2>/dev/null | grep -q -- '--zsh'; then
                        _evalcache fzf --zsh >/dev/null 2>&1 && log_success "✅ $tool 缓存成功" || log_warning "⚠️  $tool 缓存可能失败"
                    else
                        log_info "跳过 $tool (不支持 --zsh 选项)"
                    fi
                    ;;
            esac
        else
            log_info "跳过 $tool (未安装)"
        fi
    done
}

# 显示缓存状态
show_cache_status() {
    log_info "显示缓存状态..."
    
    local cache_dir="$HOME/.cache/evalcache"
    
    if [[ -d "$cache_dir" ]]; then
        local cache_count=$(find "$cache_dir" -name "*.cache" 2>/dev/null | wc -l)
        local cache_size=$(du -sh "$cache_dir" 2>/dev/null | cut -f1 || echo "未知")
        
        echo ""
        echo "📊 缓存统计:"
        echo "  缓存目录: $cache_dir"
        echo "  缓存文件数: $cache_count"
        echo "  缓存大小: $cache_size"
        
        if [[ $cache_count -gt 0 ]]; then
            echo ""
            echo "📁 缓存文件列表:"
            find "$cache_dir" -name "*.cache" -exec basename {} .cache \; 2>/dev/null | sort | sed 's/^/  • /'
        fi
    else
        log_warning "缓存目录不存在"
    fi
}

# Shell 启动时间测试
benchmark_shell_startup() {
    log_info "测试 shell 启动时间..."
    
    echo ""
    echo "🚀 Shell 启动时间基准测试:"
    
    # 测试当前配置
    echo "当前配置 (使用 evalcache):"
    bash -c 'time zsh -i -c exit' 2>&1 | grep real | sed 's/^/  /'
    
    # 如果可能，测试不使用 evalcache 的情况
    if [[ -n "${EVALCACHE_DIR:-}" ]]; then
        echo ""
        echo "不使用 evalcache (临时禁用):"
        local temp_dir=$(mktemp -d)
        env EVALCACHE_DIR="$temp_dir" bash -c 'time zsh -i -c exit' 2>&1 | grep real | sed 's/^/  /'
        rm -rf "$temp_dir"
    fi
}

# 主函数
main() {
    echo "🧪 Evalcache 测试脚本"
    echo "===================="
    echo ""
    
    # 检查是否为 zsh
    if [[ -z "${ZSH_VERSION:-}" ]]; then
        log_warning "当前不是 zsh，evalcache 主要为 zsh 设计"
        echo "当前 shell: $SHELL"
        echo ""
    fi
    
    # 运行测试
    check_evalcache_installation || exit 1
    echo ""
    
    test_evalcache_function || exit 1
    echo ""
    
    test_tool_caching
    echo ""
    
    test_real_tools
    echo ""
    
    show_cache_status
    echo ""
    
    benchmark_shell_startup
    echo ""
    
    log_success "🎉 测试完成！"
    
    # 提供使用建议
    echo ""
    log_info "💡 使用建议:"
    echo "  • 运行 'evalcache-status' 查看详细缓存状态"
    echo "  • 运行 'evalcache-clear' 清理缓存"
    echo "  • 运行 'evalcache-benchmark' 进行性能测试"
    echo "  • 重启 shell 几次让所有工具生成缓存"
}

# 运行主函数
main "$@"