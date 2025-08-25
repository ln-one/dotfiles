# ========================================
# Evalcache 配置 - 缓存 eval 语句输出以加速 shell 启动
# ========================================
# 使用 evalcache 插件缓存常用工具的初始化输出
# GitHub: https://github.com/mroth/evalcache

{{- if .features.enable_evalcache }}

# 检查并加载 evalcache
if [[ -f "$HOME/.evalcache/evalcache.plugin.zsh" ]]; then
    # 加载 evalcache 插件
    source "$HOME/.evalcache/evalcache.plugin.zsh"
fi

# 检查 evalcache 是否可用
if command -v _evalcache >/dev/null 2>&1; then
    
    # 配置 evalcache 设置 (使用 evalcache 的标准环境变量)
    export ZSH_EVALCACHE_DIR="${ZSH_EVALCACHE_DIR:-$HOME/.zsh-evalcache}"
    
    # 确保缓存目录存在
    [[ ! -d "$ZSH_EVALCACHE_DIR" ]] && mkdir -p "$ZSH_EVALCACHE_DIR"
    
    # ========================================
    # 高优先级工具缓存 (最大收益)
    # ========================================
    
    # 只缓存真正慢的工具，避免过度缓存
    
    # Starship 提示符初始化 (通常最慢，优先缓存)
    {{- if .features.enable_starship }}
    if command -v starship >/dev/null 2>&1; then
        _evalcache starship init zsh
    fi
    {{- end }}
    
    # ========================================
    # 版本管理工具缓存 (最大收益)
    # ========================================
    
    # ========================================
    # 版本管理工具 - 使用 zsh-defer 延迟加载
    # ========================================
    
    # 检查 zsh-defer 是否可用
    if command -v zsh-defer >/dev/null 2>&1; then
        # pyenv Python 版本管理 (延迟加载)
        if command -v pyenv >/dev/null 2>&1; then
            zsh-defer _evalcache pyenv init -
            # pyenv-virtualenv 也延迟加载
            if command -v pyenv-virtualenv-init >/dev/null 2>&1; then
                zsh-defer _evalcache pyenv virtualenv-init -
            fi
        fi
        
        # rbenv Ruby 版本管理 (延迟加载)
        if command -v rbenv >/dev/null 2>&1; then
            zsh-defer _evalcache rbenv init -
        fi
        
        # fnm Node.js 版本管理 (延迟加载)
        if command -v fnm >/dev/null 2>&1; then
            zsh-defer _evalcache fnm env --use-on-cd
        fi
        
        # mise 多语言版本管理 (延迟加载)
        if command -v mise >/dev/null 2>&1; then
            zsh-defer _evalcache mise activate zsh
        fi
    else
        # 回退到原来的 evalcache 方式
        # pyenv Python 版本管理 (通常很慢)
        if command -v pyenv >/dev/null 2>&1; then
            _evalcache pyenv init -
            # pyenv-virtualenv 通常也很慢
            if command -v pyenv-virtualenv-init >/dev/null 2>&1; then
                _evalcache pyenv virtualenv-init -
            fi
        fi
        
        # rbenv Ruby 版本管理 (通常很慢)
        if command -v rbenv >/dev/null 2>&1; then
            _evalcache rbenv init -
        fi
        
        # fnm Node.js 版本管理 (性能优化版本)
        if command -v fnm >/dev/null 2>&1; then
            # fnm 的 --use-on-cd 选项会创建钩子函数，导致性能问题
            # 使用更轻量的初始化方式
            eval "$(fnm env)"
            
            # 手动添加路径而不是使用自动切换钩子
            export PATH="$HOME/.fnm:$PATH"
            
            # 如果需要自动切换功能，可以手动启用（但会影响性能）
            # eval "$(fnm env --use-on-cd)"
        fi
        
        # mise 多语言版本管理 (如果真的很慢才缓存)
        if command -v mise >/dev/null 2>&1; then
            _evalcache mise activate zsh
        fi
    fi
    
    # ========================================
    # 包管理器环境设置 (通常很慢)
    # ========================================
    
    {{- if eq .chezmoi.os "linux" }}
    # Linux Homebrew 环境设置 - 使用 zsh-defer 延迟加载
    if command -v zsh-defer >/dev/null 2>&1; then
        if [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
            zsh-defer _evalcache /home/linuxbrew/.linuxbrew/bin/brew shellenv
        fi
    else
        # 回退到原来的 evalcache 方式
        if [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
            _evalcache /home/linuxbrew/.linuxbrew/bin/brew shellenv
        fi
    fi
    {{- end }}
    
    # Conda 环境管理 (通常非常慢)
    if command -v conda >/dev/null 2>&1; then
        _evalcache conda shell.zsh hook
    fi
    
    # ========================================
    # 快速工具直接 eval (不缓存)
    # ========================================
    
    # 这些工具通常很快，缓存反而可能更慢
    
    # fzf 模糊搜索初始化 (通常很快，不缓存)
    {{- if .features.enable_fzf }}
    if command -v fzf >/dev/null 2>&1; then
        if fzf --help 2>/dev/null | grep -q -- '--zsh'; then
            eval "$(fzf --zsh)"
        fi
    fi
    {{- end }}
    
    # zoxide 智能目录跳转初始化 (通常很快，不缓存)
    {{- if .features.enable_zoxide }}
    if command -v zoxide >/dev/null 2>&1; then
        eval "$(zoxide init zsh)"
    fi
    {{- end }}
    
    # direnv 环境变量管理 (通常很快，不缓存)
    if command -v direnv >/dev/null 2>&1; then
        eval "$(direnv hook zsh)"
    fi
    
    # ========================================
    # 其他开发工具 (按需缓存)
    # ========================================
    
    # thefuck 命令纠错工具 - 使用 zsh-defer 延迟加载
    if command -v zsh-defer >/dev/null 2>&1; then
        if command -v thefuck >/dev/null 2>&1; then
            zsh-defer _evalcache thefuck --alias
        fi
    else
        # 回退到原来的 evalcache 方式
        if command -v thefuck >/dev/null 2>&1; then
            _evalcache thefuck --alias
        fi
    fi
    
    # ========================================
    # CLI 工具补全 - 使用 zsh-defer 延迟加载
    # ========================================
    
    # 检查 zsh-defer 是否可用
    if command -v zsh-defer >/dev/null 2>&1; then
        # gh GitHub CLI 补全 (延迟加载)
        if command -v gh >/dev/null 2>&1; then
            zsh-defer _evalcache gh completion -s zsh
        fi
        
        # kubectl Kubernetes CLI 补全 (延迟加载)
        if command -v kubectl >/dev/null 2>&1; then
            zsh-defer _evalcache kubectl completion zsh
        fi
        
        # docker CLI 补全 (延迟加载)
        if command -v docker >/dev/null 2>&1; then
            zsh-defer _evalcache docker completion zsh
        fi
    else
        # 回退到原来的 evalcache 方式
        # gh GitHub CLI 补全 (补全通常较慢，可以缓存)
        if command -v gh >/dev/null 2>&1; then
            _evalcache gh completion -s zsh
        fi
        
        # kubectl Kubernetes CLI 补全 (补全通常很慢，强烈建议缓存)
        if command -v kubectl >/dev/null 2>&1; then
            _evalcache kubectl completion zsh
        fi
        
        # docker CLI 补全 (补全通常较慢，可以缓存)
        if command -v docker >/dev/null 2>&1; then
            _evalcache docker completion zsh
        fi
    fi
    
    # ========================================
    # evalcache 管理函数
    # ========================================
    
    # 清理 evalcache 缓存
    evalcache-clear() {
        if [[ -d "$ZSH_EVALCACHE_DIR" ]]; then
            echo "🧹 清理 evalcache 缓存目录: $ZSH_EVALCACHE_DIR"
            rm -rf "$ZSH_EVALCACHE_DIR"/*
            echo "✅ 缓存已清理，重启 shell 生效"
        else
            echo "❌ 缓存目录不存在: $ZSH_EVALCACHE_DIR"
        fi
    }
    
    # 诊断 evalcache 性能问题
    evalcache-diagnose() {
        echo "🔍 Evalcache 性能诊断"
        echo "===================="
        
        if [[ -d "$ZSH_EVALCACHE_DIR" ]]; then
            echo "缓存目录: $ZSH_EVALCACHE_DIR"
            
            # 检查缓存文件
            local cache_files=($(find "$ZSH_EVALCACHE_DIR" -type f 2>/dev/null))
            echo "缓存文件数量: ${#cache_files[@]}"
            
            if [[ ${#cache_files[@]} -gt 0 ]]; then
                echo ""
                echo "📁 缓存文件详情:"
                for file in "${cache_files[@]}"; do
                    local basename=$(basename "$file")
                    local size=$(du -h "$file" 2>/dev/null | cut -f1)
                    local mtime=$(stat -c %y "$file" 2>/dev/null | cut -d' ' -f1)
                    echo "  • $basename (${size}, 修改: $mtime)"
                done
                
                # 检查异常大的缓存文件
                echo ""
                echo "🚨 大缓存文件 (>1KB):"
                find "$ZSH_EVALCACHE_DIR" -type f -size +1k -exec ls -lh {} \; 2>/dev/null | \
                    awk '{print "  • " $9 " (" $5 ")"}' || echo "  无"
            fi
        else
            echo "❌ 缓存目录不存在"
        fi
        
        echo ""
        echo "💡 建议:"
        echo "  • 如果有大缓存文件，考虑不缓存对应工具"
        echo "  • 运行 'evalcache-clear' 清理所有缓存"
        echo "  • 使用 'time zsh -i -c exit' 测试启动时间"
    }
    
    # 显示 evalcache 状态
    evalcache-status() {
        echo "📊 Evalcache 状态报告"
        echo "缓存目录: $ZSH_EVALCACHE_DIR"
        
        if [[ -d "$ZSH_EVALCACHE_DIR" ]]; then
            local cache_count=$(find "$ZSH_EVALCACHE_DIR" -type f 2>/dev/null | wc -l)
            local cache_size=$(du -sh "$ZSH_EVALCACHE_DIR" 2>/dev/null | cut -f1)
            
            echo "缓存文件数量: $cache_count"
            echo "缓存目录大小: $cache_size"
            echo ""
            echo "缓存文件列表:"
            find "$ZSH_EVALCACHE_DIR" -type f -exec basename {} \; 2>/dev/null | sort
        else
            echo "❌ 缓存目录不存在"
        fi
    }
    
    # 重新生成特定工具的缓存
    evalcache-refresh() {
        local tool="$1"
        if [[ -z "$tool" ]]; then
            echo "用法: evalcache-refresh <tool>"
            echo "示例: evalcache-refresh starship"
            return 1
        fi
        
        # evalcache 使用工具名作为文件名，不一定有 .cache 扩展名
        local cache_file="$ZSH_EVALCACHE_DIR/${tool}"
        if [[ -f "$cache_file" ]]; then
            echo "🔄 刷新 $tool 的缓存..."
            rm "$cache_file"
            echo "✅ 缓存已删除，下次启动时将重新生成"
        else
            echo "❌ 未找到 $tool 的缓存文件"
        fi
    }
    
    # 管理函数已定义，无需导出
    
else
    # evalcache 未安装时的提示和回退
    echo "⚠️  evalcache 未安装，使用标准 eval 语句"
    echo "💡 安装 evalcache 以加速 shell 启动:"
    echo "   git clone https://github.com/mroth/evalcache ~/.evalcache"
    echo "   或运行: chezmoi apply 来自动安装"
    
    # 回退到标准 eval 语句
    {{- if .features.enable_starship }}
    if command -v starship >/dev/null 2>&1; then
        eval "$(starship init zsh)"
    fi
    {{- end }}
    
    {{- if .features.enable_fzf }}
    if command -v fzf >/dev/null 2>&1; then
        if fzf --help 2>/dev/null | grep -q -- '--zsh'; then
            eval "$(fzf --zsh)"
        fi
    fi
    {{- end }}
    
    {{- if .features.enable_zoxide }}
    if command -v zoxide >/dev/null 2>&1; then
        eval "$(zoxide init zsh)"
    fi
    {{- end }}
    
    # 版本管理工具回退 (无 evalcache 时)
    if command -v pyenv >/dev/null 2>&1; then
        eval "$(pyenv init -)"
    fi
    
    if command -v rbenv >/dev/null 2>&1; then
        eval "$(rbenv init -)"
    fi
    
    if command -v fnm >/dev/null 2>&1; then
        eval "$(fnm env)"
        export PATH="$HOME/.fnm:$PATH"
    fi
    
    if command -v mise >/dev/null 2>&1; then
        eval "$(mise activate zsh)"
    fi
    
    {{- if eq .chezmoi.os "linux" }}
    if [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
    {{- end }}
    
    # 其他开发工具回退 (无 evalcache 时)
    if command -v thefuck >/dev/null 2>&1; then
        eval "$(thefuck --alias)"
    fi
    
    {{- if eq .chezmoi.os "linux" }}
    # Linux Homebrew 环境设置回退
    if [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
    {{- end }}
    
    if command -v gh >/dev/null 2>&1; then
        eval "$(gh completion -s zsh)"
    fi
    
    if command -v kubectl >/dev/null 2>&1; then
        eval "$(kubectl completion zsh)"
    fi
    
    if command -v docker >/dev/null 2>&1; then
        eval "$(docker completion zsh)"
    fi
fi

{{- else }}
# evalcache 功能已禁用，使用标准 eval 语句
{{- end }}