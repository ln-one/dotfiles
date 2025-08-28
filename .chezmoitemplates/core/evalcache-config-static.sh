# ========================================
# Evalcache 性能优化配置 (完全静态版本)
# ========================================
# 基于功能标志的静态配置，完全消除运行时检测
# 所有工具检测由chezmoi在编译时决定

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
    
    # Homebrew 环境 (延迟初始化)
    {{- if eq .chezmoi.os "linux" }}
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    {{- else if eq .chezmoi.os "darwin" }}
    eval "$(/opt/homebrew/bin/brew shellenv)"
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
    
    # Homebrew 环境
    {{- if eq .chezmoi.os "linux" }}
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    {{- else if eq .chezmoi.os "darwin" }}
    eval "$(/opt/homebrew/bin/brew shellenv)"
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

{{- else if eq (base .chezmoi.targetFile) ".bashrc" }}
# ========================================
# Bash 直接初始化配置 (无 evalcache)
# ========================================

{{- if .features.enable_starship }}
# Starship 提示符
eval "$(starship init bash)"
{{- end }}

{{- if .features.enable_zoxide }}
# Zoxide 智能目录跳转
eval "$(zoxide init bash)"
{{- end }}

{{- if .features.enable_fzf }}
# FZF 模糊搜索
eval "$(fzf --bash)"
{{- end }}

# Homebrew 环境 (总是启用)
{{- if eq .chezmoi.os "linux" }}
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
{{- else if eq .chezmoi.os "darwin" }}
eval "$(/opt/homebrew/bin/brew shellenv)"
{{- end }}

{{- if .features.enable_conda }}
# Conda 环境管理
eval "$(conda shell.bash hook)"
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



{{- else if eq (base .chezmoi.targetFile) ".bashrc" }}
# Bash 直接初始化
{{- if .features.enable_starship }}
eval "$(starship init bash)"
{{- end }}

{{- if .features.enable_zoxide }}
eval "$(zoxide init bash)"
{{- end }}


# Homebrew 环境 (总是启用)
{{- if eq .chezmoi.os "linux" }}
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
{{- else if eq .chezmoi.os "darwin" }}
eval "$(/opt/homebrew/bin/brew shellenv)"
{{- end }}

{{- if .features.enable_conda }}
eval "$(conda shell.bash hook)"
{{- end }}

{{- end }}
{{- end }}

{{- if eq (base .chezmoi.targetFile) ".zshrc" }}
{{- if .features.enable_fzf }}
eval "$(fzf --zsh)"
{{- end }}

{{- else if eq (base .chezmoi.targetFile) ".bashrc" }}
{{- if .features.enable_fzf }}
eval "$(fzf --bash)"
{{- end }}
{{- end }}