# ========================================
# 中央功能配置系统 (完全静态版本)
# ========================================
# 所有功能由chezmoi在模板编译时静态决定，无运行时检测
# 基于 .chezmoi.toml.tmpl 中的工具配置和系统环境

# ========================================
# 功能标志定义
# ========================================
# 根据系统环境和工具配置静态确定功能可用性

{{- /* 编辑器和IDE功能 */ -}}
{{- $has_vscode := false -}}
{{- $has_nvim := false -}}
{{- $has_idea := false -}}

{{- /* 桌面工具功能 */ -}}
{{- $has_nautilus := false -}}
{{- $has_firefox := false -}}
{{- $has_vlc := false -}}
{{- $has_xclip := false -}}
{{- $has_notify_send := false -}}
{{- $has_gnome_session := false -}}

{{- /* Git工具功能 */ -}}
{{- $has_gitk := false -}}

{{- /* 开发工具功能 */ -}}
{{- $has_pyenv := false -}}
{{- $has_rbenv := false -}}
{{- $has_fnm := false -}}
{{- $has_mise := false -}}
{{- $has_conda := false -}}
{{- $has_docker := false -}}
{{- $has_kubectl := false -}}

{{- /* CLI工具功能 */ -}}
{{- $has_eza := false -}}
{{- $has_exa := false -}}

{{- /* 根据操作系统和环境类型设置功能标志 */ -}}
{{- if eq .chezmoi.os "linux" -}}
  {{- if eq .environment "desktop" -}}
    {{- $has_vscode = true -}}
    {{- $has_nvim = true -}}
    {{- $has_nautilus = true -}}
    {{- $has_firefox = true -}}
    {{- $has_vlc = true -}}
    {{- $has_xclip = true -}}
    {{- $has_notify_send = true -}}
    {{- $has_gnome_session = true -}}
    {{- $has_gitk = true -}}
    {{- $has_pyenv = true -}}
    {{- $has_fnm = true -}}
    {{- $has_docker = true -}}
    {{- $has_eza = true -}}
  {{- else if eq .environment "remote" -}}
    {{- $has_nvim = true -}}
    {{- $has_gitk = true -}}
    {{- $has_pyenv = true -}}
    {{- $has_fnm = true -}}
    {{- $has_eza = true -}}
  {{- end -}}
{{- else if eq .chezmoi.os "darwin" -}}
  {{- if eq .environment "desktop" -}}
    {{- $has_vscode = true -}}
    {{- $has_nvim = true -}}
    {{- $has_firefox = true -}}
    {{- $has_vlc = true -}}
    {{- $has_gitk = true -}}
    {{- $has_pyenv = true -}}
    {{- $has_rbenv = true -}}
    {{- $has_fnm = true -}}
    {{- $has_docker = true -}}
    {{- $has_kubectl = true -}}
    {{- $has_eza = true -}}
  {{- end -}}
{{- end -}}

# ========================================
# 功能配置导出
# ========================================
# 供其他模板使用的功能标志

# 编辑器功能
export FEATURE_VSCODE={{- if $has_vscode }}true{{- else }}false{{- end }}
export FEATURE_NVIM={{- if $has_nvim }}true{{- else }}false{{- end }}
export FEATURE_IDEA={{- if $has_idea }}true{{- else }}false{{- end }}

# 桌面工具功能
export FEATURE_NAUTILUS={{- if $has_nautilus }}true{{- else }}false{{- end }}
export FEATURE_FIREFOX={{- if $has_firefox }}true{{- else }}false{{- end }}
export FEATURE_VLC={{- if $has_vlc }}true{{- else }}false{{- end }}

# 系统集成功能
export FEATURE_XCLIP={{- if $has_xclip }}true{{- else }}false{{- end }}
export FEATURE_NOTIFY={{- if $has_notify_send }}true{{- else }}false{{- end }}
export FEATURE_GNOME_SESSION={{- if $has_gnome_session }}true{{- else }}false{{- end }}

# Git工具功能
export FEATURE_GITK={{- if $has_gitk }}true{{- else }}false{{- end }}

# 开发工具功能
export FEATURE_PYENV={{- if $has_pyenv }}true{{- else }}false{{- end }}
export FEATURE_RBENV={{- if $has_rbenv }}true{{- else }}false{{- end }}
export FEATURE_FNM={{- if $has_fnm }}true{{- else }}false{{- end }}
export FEATURE_MISE={{- if $has_mise }}true{{- else }}false{{- end }}
export FEATURE_CONDA={{- if $has_conda }}true{{- else }}false{{- end }}
export FEATURE_DOCKER={{- if $has_docker }}true{{- else }}false{{- end }}
export FEATURE_KUBECTL={{- if $has_kubectl }}true{{- else }}false{{- end }}

# CLI工具功能
export FEATURE_EZA={{- if $has_eza }}true{{- else }}false{{- end }}
export FEATURE_EXA={{- if $has_exa }}true{{- else }}false{{- end }}

# ========================================
# 静态别名配置
# ========================================
# 基于功能标志的静态别名定义

{{- if $has_vscode }}
# VS Code 别名
alias edit='code'
alias c='code .'
alias code.='code .'
export EDITOR="code --wait"
export VISUAL="code --wait" 
export GIT_EDITOR="code --wait"
{{- else if $has_nvim }}
# Neovim 别名
alias edit='nvim'
export EDITOR="nvim"
export VISUAL="nvim"
export GIT_EDITOR="nvim"
{{- end }}

{{- if eq .chezmoi.os "linux" }}
  {{- if $has_nautilus }}
# Nautilus 文件管理器
alias fm='nautilus'
alias files='nautilus'
  {{- end }}

  {{- if $has_firefox }}
# Firefox 浏览器
alias browser='firefox'
  {{- end }}

  {{- if $has_vlc }}
# VLC 媒体播放器
alias video='vlc'
alias media='vlc'
  {{- end }}

  {{- if $has_xclip }}
# 剪贴板集成
alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'
  {{- end }}

  {{- if $has_gnome_session }}
# GNOME 会话管理
alias logout='gnome-session-quit --logout'
alias reboot='gnome-session-quit --reboot'  
alias shutdown='gnome-session-quit --power-off'
  {{- end }}

{{- else if eq .chezmoi.os "darwin" }}
# macOS 应用启动器
alias fm='open'
alias files='open'
alias browser='open -a "Firefox" || open -a "Safari"'
alias video='open -a "VLC" || open -a "QuickTime Player"'
{{- end }}

{{- if $has_gitk }}
# Git GUI
alias gitgui='gitk --all &'
{{- end }}
