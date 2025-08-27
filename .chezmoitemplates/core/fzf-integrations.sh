# ========================================
# FZF 现有工具集成 (避免重复造轮子)
# ========================================
# 使用成熟的fzf增强工具而非自定义实现

{{- if .features.enable_fzf }}

# forgit - Git的fzf增强 (替代自定义git函数)
{{- if and .features.enable_git .features.enable_forgit }}
{{- if stat (joinPath (env "HOMEBREW_PREFIX" | default "/opt/homebrew") "share/forgit/forgit.plugin.zsh") }}
# forgit已通过Homebrew安装
{{- if eq .chezmoi.os "darwin" }}
source "/opt/homebrew/share/forgit/forgit.plugin.zsh"
{{- else if eq .chezmoi.os "linux" }}
source "/home/linuxbrew/.linuxbrew/share/forgit/forgit.plugin.zsh"
{{- end }}
{{- else if stat (joinPath .chezmoi.homeDir ".forgit/forgit.plugin.zsh") }}
# forgit手动安装在home目录
source "${HOME}/.forgit/forgit.plugin.zsh"
{{- end }}
{{- end }}

# fzf-tab - 更好的补全体验 (替代自定义补全)
{{- if eq (base .chezmoi.targetFile) ".zshrc" }}
{{- if stat (joinPath (env "ZIM_HOME" | default (joinPath .chezmoi.homeDir ".zim")) "modules/fzf-tab/fzf-tab.plugin.zsh") }}
# 通过Zim安装的fzf-tab
source "${ZIM_HOME}/modules/fzf-tab/fzf-tab.plugin.zsh"
{{- else if stat (joinPath (env "HOMEBREW_PREFIX" | default "/opt/homebrew") "share/fzf-tab/fzf-tab.plugin.zsh") }}
# 通过Homebrew安装的fzf-tab  
{{- if eq .chezmoi.os "darwin" }}
source "/opt/homebrew/share/fzf-tab/fzf-tab.plugin.zsh"
{{- else if eq .chezmoi.os "linux" }}
source "/home/linuxbrew/.linuxbrew/share/fzf-tab/fzf-tab.plugin.zsh"
{{- end }}
{{- end }}
{{- end }}

# fd集成 (替代自定义find函数)
{{- if .features.enable_fd }}
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
{{- end }}

# 使用bat作为preview (替代自定义preview)
{{- if .features.enable_bat }}
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {}'"
{{- end }}

{{- else }}
# fzf功能已禁用
{{- end }}
