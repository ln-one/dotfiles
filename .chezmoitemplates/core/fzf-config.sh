# ========================================
# fzf 模糊搜索配置模板
# ========================================
# 现代化的 fzf 配置，优化搜索体验

{{- if .features.enable_fzf }}

# fzf 环境变量配置
export FZF_DEFAULT_OPTS="
    --height 40%
    --layout=reverse
    --border
    --inline-info
    --preview-window=:hidden
    --preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | head -200))'
    --color=dark
    --color=fg:-1,bg:-1,hl:#c678dd,fg+:#ffffff,bg+:#4b5263,hl+:#d858fe
    --color=info:#98c379,prompt:#61afef,pointer:#be5046,marker:#e5c07b,spinner:#61afef,header:#61afef
"

# 使用更好的搜索工具 (如果可用)
{{- if lookPath "fd" }}
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
{{- else if lookPath "rg" }}
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
{{- else }}
export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/\.git/*" 2>/dev/null'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
{{- end }}

# fzf 预览选项
export FZF_CTRL_T_OPTS="
    --preview '([[ -f {} ]] && (bat --style=numbers --color=always {} 2>/dev/null || cat {} 2>/dev/null || echo {})) || ([[ -d {} ]] && (eza --tree --color=always {} 2>/dev/null || ls -la {} 2>/dev/null))'
    --bind 'ctrl-/:change-preview-window(down|hidden|)'
"

export FZF_ALT_C_OPTS="
    --preview 'eza --tree --color=always {} 2>/dev/null || tree -C {} 2>/dev/null || ls -la {} 2>/dev/null'
"

# 加载 fzf shell 集成
{{- if eq .chezmoi.os "darwin" }}
# macOS Homebrew 路径
if [ -f $(brew --prefix 2>/dev/null)/opt/fzf/shell/completion.zsh ]; then
    source $(brew --prefix)/opt/fzf/shell/completion.zsh
fi
if [ -f $(brew --prefix 2>/dev/null)/opt/fzf/shell/key-bindings.zsh ]; then
    source $(brew --prefix)/opt/fzf/shell/key-bindings.zsh
fi
{{- end }}

# Shell 特定的 fzf 集成
if [ -n "$ZSH_VERSION" ]; then
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
elif [ -n "$BASH_VERSION" ]; then
    [ -f ~/.fzf.bash ] && source ~/.fzf.bash
fi

# 自定义 fzf 函数
# 智能 cd 到目录
fcd() {
    local dir
    dir=$(find ${1:-.} -path '*/\.*' -prune -o -type d -print 2>/dev/null | fzf +m) &&
    cd "$dir"
}

# 搜索并编辑文件
fe() {
    local files
    IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
    [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

# 搜索历史命令
fh() {
    print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -E 's/ *[0-9]*\*? *//' | sed -E 's/\\/\\\\/g')
}

# 搜索并 kill 进程
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

# Git 相关 fzf 函数 (如果在 git 仓库中)
if git rev-parse --git-dir > /dev/null 2>&1; then
    # 搜索并切换 git 分支
    fgb() {
        local branches branch
        branches=$(git --no-pager branch -vv) &&
        branch=$(echo "$branches" | fzf +m) &&
        git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
    }
    
    # 搜索 git 提交历史
    fgl() {
        git log --graph --color=always \
            --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
        fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
            --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
    }
fi

{{- else }}
# fzf 功能已禁用
{{- end }}