# ========================================
# Oh My Zsh 配置模板
# ========================================
# 现代化的 Oh My Zsh 配置，优化性能和功能
# 仅在 zsh 中执行

{{- if .features.enable_oh_my_zsh }}

# 确保只在 zsh 中执行 Oh My Zsh 配置
if [ -n "$ZSH_VERSION" ]; then
    # Oh My Zsh 安装路径
    export ZSH="$HOME/.oh-my-zsh"

# 主题配置
{{- if .features.enable_starship }}
# 使用 Starship 作为提示符，禁用 Oh My Zsh 主题
ZSH_THEME=""
{{- else }}
# 使用 Oh My Zsh 内置主题
{{- if eq .environment "remote" }}
ZSH_THEME="simple"  # 远程环境使用简洁主题
{{- else }}
ZSH_THEME="robbyrussell"  # 本地环境使用经典主题
{{- end }}
{{- end }}

# 插件配置 (按环境和功能启用，优化加载顺序)
plugins=(
    git                    # Git 集成 (轻量级，优先加载)
    {{- if eq .environment "desktop" }}
    {{- if .features.enable_node }}
    zsh-nvm                # NVM 支持 (lazy load)
    {{- end }}
    {{- if .features.enable_python }}
    python                 # Python 支持
    {{- end }}
    {{- if .features.enable_fzf }}
    fzf                    # fzf 集成
    {{- end }}
    {{- end }}
    zsh-autosuggestions    # 自动建议
    zsh-syntax-highlighting # 语法高亮 (最后加载)
)

# 性能优化配置
DISABLE_AUTO_UPDATE="true"           # 禁用自动更新 (由 Chezmoi 管理)
DISABLE_UPDATE_PROMPT="true"         # 禁用更新提示
COMPLETION_WAITING_DOTS="true"       # 显示补全等待点
HIST_STAMPS="yyyy-mm-dd"            # 历史时间戳格式

# 跳过权限检查以加速启动
ZSH_DISABLE_COMPFIX=true

# 优化补全系统 (将在 Oh My Zsh 加载后执行)
_optimize_completions() {
    # 设置补全缓存文件路径
    local compdump="${ZDOTDIR:-$HOME}/.zcompdump"
    
    # 预编译补全缓存文件
    if [[ -f "$compdump" ]]; then
        if [[ ! -f "$compdump.zwc" || "$compdump" -nt "$compdump.zwc" ]]; then
            zcompile "$compdump" 2>/dev/null || true
        fi
    fi
}

{{- if .features.enable_node }}
# zsh-nvm lazy load 配置 (大幅提升启动速度)
export NVM_LAZY_LOAD=true
export NVM_COMPLETION=true
export NVM_AUTO_USE=true
{{- end }}

# 加载 Oh My Zsh
source $ZSH/oh-my-zsh.sh

# 执行补全优化
_optimize_completions

fi  # 结束 zsh 检测

{{- else }}
# Oh My Zsh 功能已禁用
{{- end }}