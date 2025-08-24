# ========================================
# Oh My Zsh 配置模板
# ========================================
# 现代化的 Oh My Zsh 配置，优化性能和功能

{{- if .features.enable_oh_my_zsh }}

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

# 插件配置 (按环境和功能启用)
plugins=(
    git                    # Git 集成
    {{- if eq .environment "desktop" }}
    docker                 # Docker 支持 (仅桌面环境)
    {{- if .features.enable_node }}
    npm                    # Node.js/npm 支持
    zsh-nvm                # NVM 支持 (lazy load)
    {{- end }}
    {{- if .features.enable_python }}
    python                 # Python 支持
    pip                    # pip 支持
    {{- end }}
    {{- end }}
    {{- if .features.enable_fzf }}
    fzf                    # fzf 集成
    {{- end }}
    zsh-autosuggestions    # 自动建议
    zsh-syntax-highlighting # 语法高亮
)

# 性能优化配置
DISABLE_AUTO_UPDATE="true"           # 禁用自动更新 (由 Chezmoi 管理)
DISABLE_UPDATE_PROMPT="true"         # 禁用更新提示
COMPLETION_WAITING_DOTS="true"       # 显示补全等待点
HIST_STAMPS="yyyy-mm-dd"            # 历史时间戳格式

{{- if .features.enable_node }}
# zsh-nvm lazy load 配置
export NVM_LAZY_LOAD=true
{{- end }}

# 加载 Oh My Zsh
source $ZSH/oh-my-zsh.sh

{{- else }}
# Oh My Zsh 功能已禁用
{{- end }}