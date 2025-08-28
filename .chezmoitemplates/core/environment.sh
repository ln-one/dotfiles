# 环境变量配置模板
# 由 Chezmoi 管理，根据平台和用户配置动态生成

# 基础路径变量 (Requirements: 2.4)
export USER_HOME="{{ .chezmoi.homeDir }}"
export CONFIG_DIR="{{ .paths.config }}"
export LOCAL_BIN="{{ .chezmoi.homeDir }}/.local/bin"

# 确保 ~/.local/bin 在 PATH 中
if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
    export PATH="$LOCAL_BIN:$PATH"
fi

# 编辑器配置
export EDITOR="{{ .preferences.editor }}"
export VISUAL="{{ .preferences.editor }}"

# 语言和区域配置 (Requirements: 2.4)
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"

{{- if .features.enable_1password }}
# SSH Agent 集成 (1Password) (Requirements: 7.2) - 静态配置
{{- if eq .chezmoi.os "darwin" }}
SSH_AGENT_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
{{- else if eq .chezmoi.os "linux" }}
SSH_AGENT_SOCK="$HOME/.1password/agent.sock"
{{- end }}
if [[ -S "$SSH_AGENT_SOCK" ]]; then
    export SSH_AUTH_SOCK="$SSH_AGENT_SOCK"
    {{- if .features.enable_ssh }}
    # 静默检查 SSH Agent 状态 (静态生成)
    ssh-add -l >/dev/null 2>&1 || true
    {{- end }}
fi
{{- end }}

{{- if eq .chezmoi.os "darwin" }}
{{- if stat "/opt/homebrew" }}
# Homebrew 环境配置 (macOS)
export HOMEBREW_PREFIX="/opt/homebrew"
{{- end }}
{{- else if eq .chezmoi.os "linux" }}
{{- if stat "/home/linuxbrew/.linuxbrew" }}
# Homebrew 环境配置 (Linux)
export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
{{- end }}
{{- end }}



# 平台特定环境变量
{{- if eq .chezmoi.os "linux" }}
# Linux 特定配置
export XDG_CONFIG_HOME="$CONFIG_DIR"
export XDG_DATA_HOME="$USER_HOME/.local/share"
export XDG_CACHE_HOME="$USER_HOME/.cache"

{{- if eq .environment "remote" }}
# SSH 远程服务器优化
export TERM="${TERM:-xterm-256color}"
{{- end }}

{{- else if eq .chezmoi.os "darwin" }}
# macOS 特定配置
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1

{{- end }}

# 开发工具环境变量
{{- if .features.enable_ai_tools }}
# AI 工具配置
export OPENAI_API_BASE="${OPENAI_API_BASE:-}"
{{- end }}

{{- if and .features.enable_proxy .proxy.enabled }}
# 代理配置
{{- $http_proxy := .proxy.http_proxy | default "" }}
{{- $https_proxy := .proxy.https_proxy | default "" }}
{{- $socks_proxy := .proxy.socks_proxy | default "" }}
{{- if $http_proxy }}
export HTTP_PROXY="{{ $http_proxy }}"
export http_proxy="{{ $http_proxy }}"
{{- end }}
{{- if $https_proxy }}
export HTTPS_PROXY="{{ $https_proxy }}"
export https_proxy="{{ $https_proxy }}"
{{- end }}
{{- if $socks_proxy }}
export SOCKS_PROXY="{{ $socks_proxy }}"
export socks_proxy="{{ $socks_proxy }}"
{{- end }}
export NO_PROXY="localhost,127.0.0.1,::1,.local"
export no_proxy="$NO_PROXY"
{{- end }}

# 性能优化配置
{{- if eq .preferences.shell "zsh" }}
# Zsh 特定优化
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE="$USER_HOME/.zsh_history"
export HIST_STAMPS="yyyy-mm-dd"
{{- end }}

# Node.js 版本管理器配置
{{- if .features.enable_node }}
# fnm (Fast Node Manager) 路径配置
# 注意: fnm 的实际初始化在 evalcache-config.sh 中处理（支持 defer）
export FNM_PATH="$USER_HOME/.local/share/fnm"
if [[ -d "$FNM_PATH" ]]; then
    export PATH="$FNM_PATH:$PATH"
fi
{{- end }}

# fzf 模糊搜索工具配置
{{- if .features.enable_fzf }}
# fzf 环境变量配置 (优化为新版本 fzf 0.48.0+)
export FZF_DEFAULT_OPTS="
    --height 40%
    --layout=reverse
    --border=rounded
    --info=inline-right
    --marker='▶'
    --pointer='◆'
    --separator='─'
    --scrollbar='│'
    --preview-window=:hidden
    --bind='ctrl-/:toggle-preview'
    --bind='ctrl-u:preview-page-up'
    --bind='ctrl-d:preview-page-down'
    --bind='ctrl-f:preview-page-down'
    --bind='ctrl-b:preview-page-up'
    --color=dark
    --color=fg:-1,bg:-1,hl:#c678dd,fg+:#ffffff,bg+:#4b5263,hl+:#d858fe
    --color=info:#98c379,prompt:#61afef,pointer:#be5046,marker:#e5c07b,spinner:#61afef,header:#61afef
    --color=border:#4b5263,separator:#4b5263,scrollbar:#4b5263
"

# 使用 Homebrew 安装的搜索工具
{{- if or (stat "/opt/homebrew") (stat "/home/linuxbrew/.linuxbrew") }}
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --strip-cwd-prefix'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git --strip-cwd-prefix'
{{- else }}
export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/\.git/*" 2>/dev/null'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
{{- end }}

# fzf 预览选项 (使用 Homebrew 安装的工具)
{{- if or (stat "/opt/homebrew") (stat "/home/linuxbrew/.linuxbrew") }}
export FZF_CTRL_T_OPTS="
    --preview '([[ -f {} ]] && (bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || cat {} 2>/dev/null || echo {})) || ([[ -d {} ]] && (eza --tree --level=2 --color=always {} 2>/dev/null || tree -C -L 2 {} 2>/dev/null || ls -la {} 2>/dev/null))'
    --preview-window='right:50%:wrap'
    --bind='ctrl-/:change-preview-window(down,50%|right,50%|hidden|)'
    --bind='ctrl-y:execute-silent(echo {} | pbcopy)'
"

export FZF_ALT_C_OPTS="
    --preview 'eza --tree --level=2 --color=always {} 2>/dev/null || tree -C -L 2 {} 2>/dev/null || ls -la {} 2>/dev/null'
    --preview-window='right:50%:wrap'
    --bind='ctrl-/:change-preview-window(down,50%|right,50%|hidden|)'
"
{{- else }}
export FZF_CTRL_T_OPTS="
    --preview '([[ -f {} ]] && (bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || cat {} 2>/dev/null || echo {})) || ([[ -d {} ]] && (eza --tree --level=2 --color=always {} 2>/dev/null || tree -C -L 2 {} 2>/dev/null || ls -la {} 2>/dev/null))'
    --preview-window='right:50%:wrap'
    --bind='ctrl-/:change-preview-window(down,50%|right,50%|hidden|)'
    --bind='ctrl-y:execute-silent(echo {} | pbcopy)'
"

export FZF_ALT_C_OPTS="
    --preview 'eza --tree --level=2 --color=always {} 2>/dev/null || tree -C -L 2 {} 2>/dev/null || ls -la {} 2>/dev/null'
    --preview-window='right:50%:wrap'
    --bind='ctrl-/:change-preview-window(down,50%|right,50%|hidden|)'
"
{{- end }}

# Git 集成的 fzf 选项
export FZF_CTRL_R_OPTS="
    --preview 'echo {}'
    --preview-window='down:3:wrap'
    --bind='ctrl-/:toggle-preview'
    --bind='ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
    --color='header:italic'
    --header='Press CTRL-Y to copy command into clipboard'
"
{{- end }}

# 确保配置目录存在
[[ ! -d "$CONFIG_DIR" ]] && mkdir -p "$CONFIG_DIR"
[[ ! -d "$LOCAL_BIN" ]] && mkdir -p "$LOCAL_BIN"

{{- if .features.enable_1password }}
# 加载 1Password 密钥 (如果文件存在)
if [[ -f "$USER_HOME/.secrets" ]]; then
    source "$USER_HOME/.secrets"
fi
{{- end }}