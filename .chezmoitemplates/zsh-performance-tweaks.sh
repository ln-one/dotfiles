# ========================================
# Zsh 性能优化脚本
# ========================================
# 进一步优化 zsh 启动性能

{{- if .features.enable_oh_my_zsh }}

# 设置更大的历史文件，但限制内存中的历史
HISTSIZE=50000
SAVEHIST=10000

# 优化历史记录
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# 异步加载优化 (针对 Starship 提示符)
# Starship 本身已经很快，无需额外的即时提示配置

# 延迟加载非关键功能
autoload -Uz add-zsh-hook

# 预编译常用脚本
_compile_zsh_files() {
    local file
    for file in ~/.zshrc ~/.zshenv ~/.zprofile ~/.zlogin ~/.zlogout; do
        if [[ -f "$file" && -r "$file" ]]; then
            if [[ ! -f "${file}.zwc" || "$file" -nt "${file}.zwc" ]]; then
                zcompile "$file" 2>/dev/null || true
            fi
        fi
    done
}

# 在后台编译文件，不阻塞启动
add-zsh-hook precmd _compile_zsh_files

{{- end }}