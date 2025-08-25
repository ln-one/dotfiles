# ========================================
# 共享 Shell 配置模板 (模块化设计)
# ========================================
# 这个文件作为模块加载器，按需加载各个功能模块
# 由 Chezmoi 模板系统管理

{{/* 注意：环境变量现在由 environment.sh 模板统一管理 */}}
# ========================================
# 颜色支持配置
# ========================================
export CLICOLOR=1
{{- if eq .chezmoi.os "linux" }}
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
{{- else if eq .chezmoi.os "darwin" }}
export LSCOLORS=ExFxCxDxBxegedabagacad
{{- end }}

# 分页器配置
export PAGER="less"

{{/* 模块化加载各个功能 */}}
# ========================================
# 模块化功能加载
# ========================================

# 加载核心别名模块
{{ includeTemplate "core/aliases.sh" . }}

# 加载基础函数模块
{{ includeTemplate "core/basic-functions.sh" . }}

# 加载平台特定配置
{{- if eq .chezmoi.os "linux" }}
# Linux 平台特定功能
{{ includeTemplate "platforms/linux/proxy-functions.sh" . }}
{{ includeTemplate "platforms/linux/theme-functions.sh" . }}
{{- else if eq .chezmoi.os "darwin" }}
# macOS 平台特定功能
{{ includeTemplate "platforms/darwin/macos-specific.sh" . }}
{{- end }}

# 加载 fzf 模糊搜索配置
{{ includeTemplate "core/fzf-config.sh" . }}

# 加载 zoxide 智能目录跳转配置
{{ includeTemplate "core/zoxide-config.sh" . }}

# ========================================
# Shell 配置完成
# ========================================
# 所有功能模块已通过 includeTemplate 加载
