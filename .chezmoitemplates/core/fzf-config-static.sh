# ========================================
# fzf 模糊搜索配置模板 (完全静态版本)
# ========================================
# fzf shell 集成和自定义函数，无运行时检测

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

# 自定义 fzf 函数
# 智能 cd 到目录
fcd() {
    local dir
    {{- if .features.enable_fd }}
    dir=$(fd --type d --hidden --follow --exclude .git ${1:-.} | fzf \
        --preview 'eza --tree --level=2 --color=always {} 2>/dev/null || ls -la {}' \
        --preview-window='right:50%:wrap' \
        --header='Select directory to cd into')
    {{- else }}
    dir=$(find ${1:-.} -path '*/\.*' -prune -o -type d -print 2>/dev/null | fzf \
        --preview 'ls -la {}' \
        --preview-window='right:50%:wrap' \
        --header='Select directory to cd into')
    {{- end }}
    [[ -n "$dir" ]] && cd "$dir"
}

# 搜索并编辑文件
fe() {
    local files
    {{- if .features.enable_fd }}
    IFS=$'\n' files=($(fd --type f --hidden --follow --exclude .git ${1:-.} | fzf \
        --multi \
        --preview 'bat --style=numbers --color=always --line-range :500 {}' \
        --preview-window='right:60%:wrap' \
        --header='Select file(s) to edit'))
    {{- else }}
    IFS=$'\n' files=($(find ${1:-.} -type f 2>/dev/null | fzf \
        --multi \
        --preview 'head -500 {}' \
        --preview-window='right:60%:wrap' \
        --header='Select file(s) to edit'))
    {{- end }}
    [[ -n "$files" ]] && ${EDITOR:-vi} "${files[@]}"
}

# 进程管理
fkill() {
    local pid
    if [ "$UID" != "0" ]; then
        pid=$(ps -f -u $UID | sed 1d | fzf -m | awk '{print $2}')
    else
        pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    fi
    
    if [ "x$pid" != "x" ]; then
        echo $pid | xargs kill -${1:-9}
    fi
}

# Git 分支切换
fbr() {
    local branches branch
    branches=$(git --no-pager branch -vv) &&
    branch=$(echo "$branches" | fzf +m) &&
    git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}

# Git 提交历史浏览
fshow() {
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
        --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}

{{- else }}
# fzf 功能已禁用
{{- end }}
