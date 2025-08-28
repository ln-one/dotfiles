# ========================================
# Evalcache 性能优化配置 (完全静态版本)
# ========================================
# 基于功能标志的静态配置，完全消除运行时检测
# 所有工具检测由chezmoi在编译时决定
# 延迟加载语法高亮以加速启动 - 静态配置

{{- if .features.enable_zsh_defer }}
    # 手动安装和延迟加载 zsh-syntax-highlighting
    if [[ ! -d "${ZIM_HOME}/modules/zsh-syntax-highlighting" ]]; then
        # 如果模块不存在，先安装
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZIM_HOME}/modules/zsh-syntax-highlighting" 2>/dev/null || true
    fi

    # 延迟加载语法高亮
    if [[ -f "${ZIM_HOME}/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
        zsh-defer source "${ZIM_HOME}/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    fi

    # 延迟加载补全系统
    zsh-defer -c '
        # 初始化补全系统
{{- else }}
    # 直接加载语法高亮（无 zsh-defer）
    if [[ -f "${ZIM_HOME}/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
        source "${ZIM_HOME}/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    fi

    # 直接初始化补全系统
{{- end }}
        autoload -Uz compinit

        # 优化补全加载 - 每天只检查一次
        local zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
        if [[ $zcompdump(#qNmh+24) ]]; then
            compinit -d "$zcompdump"
        else
            compinit -C -d "$zcompdump"
        fi

        # 加载 Zim 补全模块
        if [[ -f "${ZIM_HOME}/modules/completion/init.zsh" ]]; then
            source "${ZIM_HOME}/modules/completion/init.zsh"
        fi
{{- if .features.enable_zsh_defer }}
    '

    # 延迟配置历史子字符串搜索键绑定
    zsh-defer -c '
        # 配置历史子字符串搜索的键绑定
        if [[ -n "${widgets[history-substring-search-up]}" ]]; then
            # 绑定上下箭头键到历史子字符串搜索
            bindkey "^[[A" history-substring-search-up      # 上箭头
            bindkey "^[[B" history-substring-search-down    # 下箭头

            # 兼容不同终端的键码
            bindkey "^[OA" history-substring-search-up      # 上箭头 (某些终端)
            bindkey "^[OB" history-substring-search-down    # 下箭头 (某些终端)

            # 在 vi 模式下也启用
            bindkey -M vicmd "k" history-substring-search-up
            bindkey -M vicmd "j" history-substring-search-down
        fi
    '
{{- end }}



{{- if .features.enable_evalcache }}
    {{- if eq (base .chezmoi.targetFile) ".zshrc" }}
        # 加载 evalcache 插件 (仅限 Zsh)
        if [[ -f "$HOME/.evalcache/evalcache.plugin.zsh" ]]; then
            source "$HOME/.evalcache/evalcache.plugin.zsh"
        fi

        # Evalcache 静态配置
        # ========================================
        # 立即初始化的工具 (高优先级)
        # ========================================

        {{- if .features.enable_starship }}
            # Starship 提示符 (最高优先级)
            _evalcache starship init zsh
        {{- end }}

        # ========================================
        # 延迟初始化的工具 (静态配置)
        # ========================================

        {{- if .features.enable_zsh_defer }}
            # zsh-defer 可用，使用延迟初始化
            # Python 环境管理 (延迟初始化)
            {{- if .features.enable_pyenv }}
                zsh-defer -a _evalcache pyenv init --path
                zsh-defer -a _evalcache pyenv init -
                zsh-defer -a _evalcache pyenv virtualenv-init -
            {{- end }}

            # Ruby 环境管理 (延迟初始化)
            {{- if .features.enable_rbenv }}
                zsh-defer -a _evalcache rbenv init -
            {{- end }}

            # Node.js 环境管理 (延迟初始化)
            {{- if .features.enable_fnm }}
                # Node.js 环境管理 (延迟初始化，静默模式)
                zsh-defer -a _evalcache fnm env
            {{- end }}

            # 工具版本管理器 (延迟初始化)
            {{- if .features.enable_mise }}
                zsh-defer -a _evalcache mise activate zsh
            {{- end }}

        {{- else }}
            # 无 zsh-defer 时的直接初始化
            {{- if .features.enable_pyenv }}
                _evalcache pyenv init --path
                _evalcache pyenv init -
                _evalcache pyenv virtualenv-init -
            {{- end }}

            {{- if .features.enable_rbenv }}
                _evalcache rbenv init -
            {{- end }}

            {{- if .features.enable_fnm }}
                # Node.js 环境管理 (静默模式)
                _evalcache fnm env
            {{- end }}

            {{- if .features.enable_mise }}
                _evalcache mise activate zsh
            {{- end }}
        {{- end }}

        # ========================================
        # 其他工具的延迟初始化 (静态配置)
        # ========================================

        {{- if .features.enable_conda }}
            # Conda 环境管理 (延迟初始化)
            {{- if .features.enable_zsh_defer }}
                zsh-defer -a _evalcache conda shell.zsh hook
            {{- else }}
                _evalcache conda shell.zsh hook
            {{- end }}
        {{- end }}

        {{- if .features.enable_zoxide }}
            # Zoxide 智能目录跳转 (延迟初始化)
            {{- if .features.enable_zsh_defer }}
                {{- if eq (base .chezmoi.targetFile) ".zshrc" }}
                    zsh-defer -a _evalcache zoxide init zsh
                {{- else if eq (base .chezmoi.targetFile) ".bashrc" }}
                    _evalcache zoxide init bash
                {{- end }}
            {{- else }}
                {{- if eq (base .chezmoi.targetFile) ".zshrc" }}
                    _evalcache zoxide init zsh
                {{- else if eq (base .chezmoi.targetFile) ".bashrc" }}
                    _evalcache zoxide init bash
                {{- end }}
            {{- end }}
        {{- end }}

        # ========================================
        # 补全系统延迟初始化 (静态配置)
        # ========================================

        {{- if .features.enable_zsh_defer }}
            # 延迟加载常用工具的补全
            {{- if .features.enable_docker }}
                zsh-defer -a compdef _docker docker
            {{- end }}

            {{- if .features.enable_kubectl }}
                zsh-defer -a compdef _kubectl kubectl
            {{- end }}
        {{- else }}
            # 直接加载补全（无 zsh-defer）
            {{- if .features.enable_docker }}
                compdef _docker docker
            {{- end }}

            {{- if .features.enable_kubectl }}
                compdef _kubectl kubectl
            {{- end }}
        {{- end }}

    {{- else }}
        # Evalcache 功能已禁用，使用直接初始化
        {{- if eq (base .chezmoi.targetFile) ".zshrc" }}
            # ZSH 直接初始化
            {{- if .features.enable_starship }}
                eval "$(starship init zsh)"
            {{- end }}

            {{- if .features.enable_zoxide }}
                eval "$(zoxide init zsh)"
            {{- end }}
        {{- end }}

        {{- if .features.enable_fzf }}
            eval "$(fzf --zsh)"
        {{- end }}
    {{- end }}

{{- end }}

{{- if .features.enable_fzf }}
eval "$(fzf --zsh)"
{{- end }}

