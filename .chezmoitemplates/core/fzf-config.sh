# ========================================
# fzf 模糊搜索配置模板
# ========================================
# fzf shell 集成和自定义函数
# 环境变量配置已移至 environment.sh

{{- if .features.enable_fzf }}

# 加载 fzf shell 集成 (使用新的 --zsh 选项，需要 fzf 0.48.0+)
if command -v fzf >/dev/null 2>&1; then
    # 检查 fzf 版本是否支持新的集成选项
    if fzf --help 2>/dev/null | grep -q -- '--zsh'; then
        # 使用新的 fzf 集成方式 (fzf 0.48.0+)
        # 使用 zsh-defer 延迟加载以加速启动
        if [ -n "$ZSH_VERSION" ]; then
            if command -v zsh-defer >/dev/null 2>&1; then
                zsh-defer eval "$(fzf --zsh)"
            else
                eval "$(fzf --zsh)"
            fi
        elif [ -n "$BASH_VERSION" ]; then
            # Bash 不支持 zsh-defer，直接加载
            eval "$(fzf --bash)"
        fi
    else
        # 回退到传统的集成方式 (旧版本 fzf)
        {{- if eq .chezmoi.os "darwin" }}
        # macOS Homebrew 路径 - 使用 zsh-defer 延迟加载
        if command -v zsh-defer >/dev/null 2>&1; then
            if [ -f $(brew --prefix 2>/dev/null)/opt/fzf/shell/completion.zsh ]; then
                zsh-defer source $(brew --prefix)/opt/fzf/shell/completion.zsh
            fi
            if [ -f $(brew --prefix 2>/dev/null)/opt/fzf/shell/key-bindings.zsh ]; then
                zsh-defer source $(brew --prefix)/opt/fzf/shell/key-bindings.zsh
            fi
        else
            # 回退到直接加载
            if [ -f $(brew --prefix 2>/dev/null)/opt/fzf/shell/completion.zsh ]; then
                source $(brew --prefix)/opt/fzf/shell/completion.zsh
            fi
            if [ -f $(brew --prefix 2>/dev/null)/opt/fzf/shell/key-bindings.zsh ]; then
                source $(brew --prefix)/opt/fzf/shell/key-bindings.zsh
            fi
        fi
        {{- end }}
        
        # Shell 特定的 fzf 集成 (传统方式)
        if [ -n "$ZSH_VERSION" ]; then
            if command -v zsh-defer >/dev/null 2>&1; then
                [ -f ~/.fzf.zsh ] && zsh-defer source ~/.fzf.zsh
            else
                [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
            fi
        elif [ -n "$BASH_VERSION" ]; then
            [ -f ~/.fzf.bash ] && source ~/.fzf.bash
        fi
    fi
fi

# 自定义 fzf 函数 (利用新版本功能)
# 智能 cd 到目录 (增强版)
fcd() {
    local dir
    {{- if lookPath "fd" }}
    dir=$(fd --type d --hidden --follow --exclude .git ${1:-.} | fzf \
        --preview 'eza --tree --level=2 --color=always {} 2>/dev/null || tree -C -L 2 {} 2>/dev/null || ls -la {}' \
        --preview-window='right:50%:wrap' \
        --bind='ctrl-/:change-preview-window(down,50%|right,50%|hidden|)' \
        --header='Select directory to cd into')
    {{- else }}
    dir=$(find ${1:-.} -path '*/\.*' -prune -o -type d -print 2>/dev/null | fzf \
        --preview 'ls -la {}' \
        --preview-window='right:50%:wrap' \
        --header='Select directory to cd into')
    {{- end }}
    [[ -n "$dir" ]] && cd "$dir"
}

# 搜索并编辑文件 (增强版)
fe() {
    local files
    {{- if lookPath "fd" }}
    IFS=$'\n' files=($(fd --type f --hidden --follow --exclude .git ${1:-.} | fzf \
        --multi \
        --preview 'bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || cat {} 2>/dev/null' \
        --preview-window='right:60%:wrap' \
        --bind='ctrl-/:change-preview-window(down,60%|right,60%|hidden|)' \
        --bind='ctrl-y:execute-silent(echo {} | pbcopy)' \
        --header='Select files to edit (Tab to select multiple)'))
    {{- else }}
    IFS=$'\n' files=($(fzf --query="$1" --multi --select-1 --exit-0 \
        --preview 'cat {} 2>/dev/null' \
        --preview-window='right:60%:wrap' \
        --header='Select files to edit'))
    {{- end }}
    [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

# 搜索历史命令 (增强版)
fh() {
    local cmd
    cmd=$(fc -l 1 | fzf \
        --tac \
        --no-sort \
        --exact \
        --preview 'echo {}' \
        --preview-window='down:3:wrap' \
        --bind='ctrl-/:toggle-preview' \
        --bind='ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort' \
        --header='Press CTRL-Y to copy command, ENTER to execute' | \
        sed -E 's/ *[0-9]*\*? *//' | sed -E 's/\\/\\\\/g')
    [[ -n "$cmd" ]] && print -z "$cmd"
}

# 搜索并 kill 进程 (增强版)
fkill() {
    local pid signal=${1:-TERM}
    if [ "$UID" != "0" ]; then
        pid=$(ps -f -u $UID | sed 1d | fzf \
            --multi \
            --header="Select processes to kill with SIG${signal}" \
            --preview 'echo "Process details:" && echo {} | awk "{print \"PID: \" \$2 \"\\nCMD: \" \$8}"' \
            --preview-window='down:4:wrap' | awk '{print $2}')
    else
        pid=$(ps -ef | sed 1d | fzf \
            --multi \
            --header="Select processes to kill with SIG${signal}" \
            --preview 'echo "Process details:" && echo {} | awk "{print \"PID: \" \$2 \"\\nUser: \" \$1 \"\\nCMD: \" \$8}"' \
            --preview-window='down:4:wrap' | awk '{print $2}')
    fi

    if [[ -n "$pid" ]]; then
        echo "Killing processes: $pid"
        echo "$pid" | xargs kill -${signal}
    fi
}

# Git 相关 fzf 函数 (增强版)
# 搜索并切换 git 分支
fgb() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Not in a git repository"
        return 1
    fi
    
    local branch
    branch=$(git branch -a --color=always | grep -v '/HEAD\s' | sort | fzf \
        --ansi \
        --multi \
        --tac \
        --preview-window='right:70%' \
        --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -'$LINES \
        --bind='ctrl-/:change-preview-window(down|hidden|)' \
        --header='Select branch to checkout') &&
    git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# 搜索 git 提交历史 (增强版)
fgl() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Not in a git repository"
        return 1
    fi
    
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index \
        --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | head -1 | xargs git show --color=always' \
        --preview-window='right:60%' \
        --bind='ctrl-/:change-preview-window(down|hidden|)' \
        --bind='ctrl-s:toggle-sort' \
        --bind='ctrl-y:execute-silent(grep -o "[a-f0-9]\{7,\}" <<< {} | head -1 | pbcopy)' \
        --header='Press CTRL-Y to copy hash, ENTER to show commit'
}

# 搜索 git 文件历史
fgf() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Not in a git repository"
        return 1
    fi
    
    local file
    file=$(git ls-files | fzf \
        --preview 'git log --color=always --oneline {} | head -20' \
        --preview-window='right:50%' \
        --bind='ctrl-/:change-preview-window(down|hidden|)' \
        --header='Select file to view git history') &&
    git log --follow --color=always --oneline "$file" |
    fzf --ansi --no-sort \
        --preview "echo {} | cut -d' ' -f1 | xargs git show --color=always" \
        --preview-window='right:60%' \
        --bind='ctrl-/:change-preview-window(down|hidden|)'
}

# Docker 容器管理 (如果安装了 Docker)
{{- if lookPath "docker" }}
# 选择并连接到 Docker 容器
fdc() {
    local container
    container=$(docker ps --format "table {{`{{.Names}}`}}\t{{`{{.Image}}`}}\t{{`{{.Status}}`}}" | fzf \
        --header-lines=1 \
        --preview 'docker inspect {1}' \
        --preview-window='right:60%:wrap' \
        --bind='ctrl-/:change-preview-window(down|hidden|)' \
        --header='Select container to connect to') &&
    docker exec -it $(echo "$container" | awk '{print $1}') /bin/bash
}

# 选择并删除 Docker 容器
fdrm() {
    local containers
    containers=$(docker ps -a --format "table {{`{{.Names}}`}}\t{{`{{.Image}}`}}\t{{`{{.Status}}`}}" | fzf \
        --header-lines=1 \
        --multi \
        --preview 'docker inspect {1}' \
        --preview-window='right:60%:wrap' \
        --bind='ctrl-/:change-preview-window(down|hidden|)' \
        --header='Select containers to remove (Tab for multiple)') &&
    echo "$containers" | awk '{print $1}' | xargs docker rm -f
}
{{- end }}

# 系统服务管理 (systemd)
{{- if and (eq .chezmoi.os "linux") (lookPath "systemctl") }}
# 选择并管理 systemd 服务
fss() {
    local service action
    service=$(systemctl list-units --type=service --all --no-legend | fzf \
        --preview 'systemctl status {1}' \
        --preview-window='right:60%:wrap' \
        --bind='ctrl-/:change-preview-window(down|hidden|)' \
        --header='Select service to manage') &&
    action=$(echo -e "start\nstop\nrestart\nreload\nenable\ndisable\nstatus" | fzf \
        --header="Select action for $(echo $service | awk '{print $1}')") &&
    sudo systemctl "$action" $(echo "$service" | awk '{print $1}')
}
{{- end }}



{{- else }}
# fzf 功能已禁用
{{- end }}