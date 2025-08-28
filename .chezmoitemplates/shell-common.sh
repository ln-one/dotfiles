# ========================================
# Chezmoi 分层配置加载器 (Layered Configuration Loader)
# ========================================

# ========================================
# 第1层：核心配置层 (Core Layer)
# ========================================
# 所有环境通用的基础功能
# 优先级：最低 (被后续层覆盖)

# 核心环境变量和基础配置
{{ includeTemplate "core/environment.sh" . }}

# 通用别名定义 (完全静态版本)
{{ includeTemplate "core/aliases.sh" . }}

# 基础函数库
{{ includeTemplate "core/functions.sh" . }}



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
