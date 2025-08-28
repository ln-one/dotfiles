# ========================================
# Chezmoi 分层配置加载器 (Layered Configuration Loader)
# ========================================
# 实现四层配置架构：核心→平台→环境→用户
# 在 chezmoi apply 时静态确定配置，无运行时检测
# Requirements: 6.1, 6.2

# 基础颜色和分页器配置
export CLICOLOR=1
{{- if eq .chezmoi.os "linux" }}
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
{{- else if eq .chezmoi.os "darwin" }}
export LSCOLORS=ExFxCxDxBxegedabagacad
{{- end }}
export PAGER="less"

# ========================================
# 第0层：功能配置层 (Feature Configuration Layer)
# ========================================
# 中央功能配置 - 由chezmoi静态确定所有功能可用性
# 优先级：最高 (决定所有后续层的行为)

# 功能标志和静态配置
{{ includeTemplate "config/features-static.sh" . }}

# ========================================
# 第1层：核心配置层 (Core Layer)
# ========================================
# 所有环境通用的基础功能
# 优先级：最低 (被后续层覆盖)

# 核心环境变量和基础配置
{{ includeTemplate "core/environment.sh" . }}

# 通用别名定义 (完全静态版本)
{{ includeTemplate "core/aliases-static.sh" . }}

# 基础函数库
{{ includeTemplate "core/basic-functions.sh" . }}

# Shell 特定配置 (仅在对应 shell 中加载)
{{- if eq (base .chezmoi.targetFile) ".zshrc" }}
# Zsh 特定配置
# Shell 性能优化
{{ includeTemplate "core/zsh-performance-tweaks.sh" . }}

# Zsh 框架配置 - 根据特性标志选择框架
{{- if .features.enable_zim }}
# Zim 框架配置 (包含补全系统管理)
{{ includeTemplate "core/zim-config.sh" . }}
{{- else if .features.enable_oh_my_zsh }}
# Oh My Zsh 框架配置
{{ includeTemplate "core/oh-my-zsh-config.sh" . }}
{{- else }}
# 无框架模式 - 仅加载基础 Zsh 配置
# 基础补全系统 (仅在无框架模式下手动初始化)
autoload -Uz compinit
# 优化补全加载 - 每天只检查一次
local zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
if [[ $zcompdump(#qNmh+24) ]]; then
    compinit -d "$zcompdump"
else
    compinit -C -d "$zcompdump"
fi
{{- end }}
{{- end }}

# 初始化 zsh-defer (仅在zsh和启用 Zim 时，必须在 evalcache 之前)
{{- if and .features.enable_zim (eq (base .chezmoi.targetFile) ".zshrc") }}
{{ includeTemplate "core/zsh-defer-init.sh" . }}

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
{{- else }}

# 直接配置历史子字符串搜索键绑定（无 zsh-defer）
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
{{- end }}
{{- end }}

# Evalcache 配置 - 缓存 eval 语句以加速启动 (完全静态版本)
{{ includeTemplate "core/evalcache-config-static.sh" . }}

# 提示符配置 (Starship) - 支持多种 shell (静态版本)
{{ includeTemplate "core/starship-config.sh" . }}

# 智能目录跳转 (zoxide) - 支持多种 shell (完全静态版本)
{{ includeTemplate "core/zoxide-config-static.sh" . }}

# ========================================
# 第2层：平台配置层 (Platform Layer)
# ========================================
# 操作系统特定的配置和工具
# 优先级：中等 (覆盖核心配置)

{{- if eq .chezmoi.os "linux" }}
# Linux 平台特定功能
{{ includeTemplate "platforms/linux/proxy-functions.sh" . }}
{{ includeTemplate "platforms/linux/theme-functions.sh" . }}
{{- else if eq .chezmoi.os "darwin" }}
# macOS 平台特定功能
{{ includeTemplate "platforms/darwin/macos-specific.sh" . }}
{{- end }}

# ========================================
# 第3层：环境配置层 (Environment Layer)
# ========================================
# 运行环境特定的配置，由 chezmoi 模板变量静态确定
# 优先级：较高 (覆盖平台配置)

{{- if eq .environment "desktop" }}
# 桌面环境：完整功能配置 (静态版本)
{{ includeTemplate "environments/desktop-static.sh" . }}
{{- else if eq .environment "remote" }}
# 远程环境：轻量化配置
{{ includeTemplate "environments/remote.sh" . }}
{{- else if eq .environment "container" }}
# 容器环境：最小化配置
{{ includeTemplate "environments/container.sh" . }}
{{- else if eq .environment "wsl" }}
# WSL环境：混合优化配置
{{ includeTemplate "environments/wsl.sh" . }}
{{- else }}
# 默认环境：桌面配置
{{ includeTemplate "environments/desktop.sh" . }}
{{- end }}

# ========================================
# 第4层：用户配置层 (User Layer)
# ========================================
# 用户个人配置覆盖
# 优先级：最高 (覆盖所有其他配置)

# 4.1 加载用户本地配置覆盖 (如果存在)
{{- if stat (joinPath .chezmoi.sourceDir ".chezmoitemplates/local/user-overrides.sh") }}
{{ includeTemplate "local/user-overrides.sh" . }}
{{- end }}

# 4.2 加载用户本地环境配置 (如果存在)
{{- if stat (joinPath .chezmoi.sourceDir ".chezmoitemplates/local/local-config.sh") }}
{{ includeTemplate "local/local-config.sh" . }}
{{- end }}

# 4.3 加载外部用户配置文件 (按优先级顺序)
# 优先级：后加载的文件覆盖先加载的文件

# 4.3.1 系统级配置 (最低优先级)
if [[ -f "/etc/chezmoi/config.sh" ]]; then
    source "/etc/chezmoi/config.sh"
fi

# 4.3.2 用户配置目录中的配置
if [[ -f "$HOME/.config/chezmoi/config.sh" ]]; then
    source "$HOME/.config/chezmoi/config.sh"
fi

# 4.3.3 用户主目录中的配置 (高优先级)
if [[ -f "$HOME/.chezmoi.local.sh" ]]; then
    source "$HOME/.chezmoi.local.sh"
fi

# 4.3.4 项目根目录中的配置 (最高优先级)
# 这允许项目特定的配置覆盖
if [[ -f "$(pwd)/.chezmoi.local.sh" ]]; then
    source "$(pwd)/.chezmoi.local.sh"
fi

# 4.4 环境变量配置覆盖 (最终优先级)
# 允许通过环境变量进行最后的配置覆盖
if [[ -n "${CHEZMOI_USER_CONFIG:-}" ]]; then
    eval "$CHEZMOI_USER_CONFIG"
fi

# ========================================
# 配置加载完成
# ========================================
# 分层配置系统加载完成 (静态编译)
# 加载顺序：核心→平台→环境→用户
# 优先级：用户配置 > 环境配置 > 平台配置 > 核心配置

# 导出配置信息
export CHEZMOI_CONFIG_LOADED="true"
export CHEZMOI_CONFIG_LAYERS="core,platform,environment,user"
export CHEZMOI_PLATFORM="{{ .chezmoi.os }}"
export CHEZMOI_ENVIRONMENT="{{ .environment | default "desktop" }}"
