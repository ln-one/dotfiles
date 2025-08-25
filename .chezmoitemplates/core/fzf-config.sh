# ========================================
# fzf 模糊搜索配置模板
# ========================================
# fzf shell 集成和自定义函数
# 环境变量配置已移至 environment.sh

{{- if .features.enable_fzf }}

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