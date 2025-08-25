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
    
    # 配置 evalcache 设置
    export EVALCACHE_DIR="${EVALCACHE_DIR:-$HOME/.cache/evalcache}"
    
    # 确保缓存目录存在
    [[ ! -d "$EVALCACHE_DIR" ]] && mkdir -p "$EVALCACHE_DIR"
    
    # ========================================
    # 缓存工具初始化
    # ========================================
    
    # Starship 提示符初始化 (高优先级缓存)
    {{- if .features.enable_starship }}
    if command -v starship >/dev/null 2>&1; then
        _evalcache starship init zsh
    fi
    {{- end }}
    
    # fzf 模糊搜索初始化
    {{- if .features.enable_fzf }}
    if command -v fzf >/dev/null 2>&1; then
        # 检查是否支持新的 --zsh 选项
        if fzf --help 2>/dev/null | grep -q -- '--zsh'; then
            _evalcache fzf --zsh
        fi
    fi
    {{- end }}
    
    # zoxide 智能目录跳转初始化
    {{- if .features.enable_zoxide }}
    if command -v zoxide >/dev/null 2>&1; then
        _evalcache zoxide init zsh
    fi
    {{- end }}
    
    # ========================================
    # 版本管理工具缓存 (最大收益)
    # ========================================
    
    # pyenv Python 版本管理
    if command -v pyenv >/dev/null 2>&1; then
        _evalcache pyenv init -
        # 如果启用了 pyenv-virtualenv
        if command -v pyenv-virtualenv-init >/dev/null 2>&1; then
            _evalcache pyenv virtualenv-init -
        fi
    fi
    
    # rbenv Ruby 版本管理
    if command -v rbenv >/dev/null 2>&1; then
        _evalcache rbenv init -
    fi
    
    # fnm Node.js 版本管理
    if command -v fnm >/dev/null 2>&1; then
        _evalcache fnm env --use-on-cd
    fi
    
    # mise 多语言版本管理 (rtx 的继任者)
    if command -v mise >/dev/null 2>&1; then
        _evalcache mise activate zsh
    fi
    
    # nvm Node.js 版本管理 (如果使用)
    if command -v nvm >/dev/null 2>&1; then
        # nvm 比较特殊，需要特殊处理
        _evalcache nvm use default
    fi
    
    # ========================================
    # 包管理器环境设置
    # ========================================
    
    {{- if eq .chezmoi.os "linux" }}
    # Linux Homebrew 环境设置
    if [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
        _evalcache /home/linuxbrew/.linuxbrew/bin/brew shellenv
    fi
    {{- end }}
    
    # Conda 环境管理 (如果使用)
    if command -v conda >/dev/null 2>&1; then
        # Conda 初始化通常很慢，是 evalcache 的理想候选
        _evalcache conda shell.zsh hook
    fi
    
    # ========================================
    # 开发工具缓存
    # ========================================
    
    # direnv 环境变量管理
    if command -v direnv >/dev/null 2>&1; then
        _evalcache direnv hook zsh
    fi
    
    # thefuck 命令纠错工具
    if command -v thefuck >/dev/null 2>&1; then
        _evalcache thefuck --alias
    fi
    
    # gh GitHub CLI 补全
    if command -v gh >/dev/null 2>&1; then
        _evalcache gh completion -s zsh
    fi
    
    # kubectl Kubernetes CLI 补全
    if command -v kubectl >/dev/null 2>&1; then
        _evalcache kubectl completion zsh
    fi
    
    # docker CLI 补全
    if command -v docker >/dev/null 2>&1; then
        _evalcache docker completion zsh
    fi
    
    # ========================================
    # evalcache 管理函数
    # ========================================
    
    # 清理 evalcache 缓存
    evalcache-clear() {
        if [[ -d "$EVALCACHE_DIR" ]]; then
            echo "🧹 清理 evalcache 缓存目录: $EVALCACHE_DIR"
            rm -rf "$EVALCACHE_DIR"/*
            echo "✅ 缓存已清理"
        else
            echo "❌ 缓存目录不存在: $EVALCACHE_DIR"
        fi
    }
    
    # 显示 evalcache 状态
    evalcache-status() {
        echo "📊 Evalcache 状态报告"
        echo "缓存目录: $EVALCACHE_DIR"
        
        if [[ -d "$EVALCACHE_DIR" ]]; then
            local cache_count=$(find "$EVALCACHE_DIR" -name "*.cache" 2>/dev/null | wc -l)
            local cache_size=$(du -sh "$EVALCACHE_DIR" 2>/dev/null | cut -f1)
            
            echo "缓存文件数量: $cache_count"
            echo "缓存目录大小: $cache_size"
            echo ""
            echo "缓存文件列表:"
            find "$EVALCACHE_DIR" -name "*.cache" -exec basename {} .cache \; 2>/dev/null | sort
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
        
        local cache_file="$EVALCACHE_DIR/${tool}.cache"
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
    
    # 版本管理工具回退
    if command -v pyenv >/dev/null 2>&1; then
        eval "$(pyenv init -)"
    fi
    
    if command -v rbenv >/dev/null 2>&1; then
        eval "$(rbenv init -)"
    fi
    
    if command -v fnm >/dev/null 2>&1; then
        eval "$(fnm env --use-on-cd)"
    fi
    
    if command -v mise >/dev/null 2>&1; then
        eval "$(mise activate zsh)"
    fi
    
    {{- if eq .chezmoi.os "linux" }}
    if [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
    {{- end }}
fi

{{- else }}
# evalcache 功能已禁用，使用标准 eval 语句
{{- end }}