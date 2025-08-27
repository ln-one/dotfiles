# ========================================
# fzf 模糊搜索配置模板 (完全静态版本)
# ========================================
# fzf shell 集成和现有工具集成，避免重复造轮子

{{- if .features.enable_fzf }}

# fzf shell 集成 (静态生成)
{{- if .features.enable_fzf_new }}
# 使用新的 fzf 集成方式 (fzf 0.48.0+)
{{- if eq (base .chezmoi.targetFile) ".zshrc" }}
eval "$(fzf --zsh)"
{{- else if eq (base .chezmoi.targetFile) ".bashrc" }}
eval "$(fzf --bash)"
{{- end }}
{{- else }}
# 传统的 fzf 集成方式
{{- if eq .chezmoi.os "darwin" }}
# macOS Homebrew 路径
[ -f $(brew --prefix)/opt/fzf/shell/completion.zsh ] && source $(brew --prefix)/opt/fzf/shell/completion.zsh
[ -f $(brew --prefix)/opt/fzf/shell/key-bindings.zsh ] && source $(brew --prefix)/opt/fzf/shell/key-bindings.zsh
{{- else if eq .chezmoi.os "linux" }}
# Linux 路径
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
{{- end }}
{{- end }}

# 使用现有工具增强fzf，避免自定义实现
{{ includeTemplate "core/fzf-integrations.sh" . }}

# 必要的自定义函数 (无现有工具替代时)
{{- if not .features.enable_forgit }}
# 仅在没有forgit时提供基础Git分支切换
fbr() {
    local branches branch
    branches=$(git --no-pager branch -vv) &&
    branch=$(echo "$branches" | fzf +m) &&
    git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}
{{- end }}

{{- else }}
# fzf 功能已禁用
{{- end }}
