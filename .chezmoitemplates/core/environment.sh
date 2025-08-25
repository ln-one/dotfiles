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
# SSH Agent 集成 (1Password) (Requirements: 7.2)
{{- if eq .chezmoi.os "darwin" }}
SSH_AGENT_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
{{- else if eq .chezmoi.os "linux" }}
SSH_AGENT_SOCK="$HOME/.1password/agent.sock"
{{- end }}
if [[ -S "$SSH_AGENT_SOCK" ]]; then
    export SSH_AUTH_SOCK="$SSH_AGENT_SOCK"
    # 验证 1Password SSH Agent 是否可用
    if command -v ssh-add >/dev/null 2>&1; then
        # 静默检查 SSH Agent 状态
        ssh-add -l >/dev/null 2>&1 || true
    fi
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

{{- if or (stat "/opt/homebrew") (stat "/home/linuxbrew/.linuxbrew") }}
export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX"
export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"
export MANPATH="$HOMEBREW_PREFIX/share/man${MANPATH+:$MANPATH}:"
export INFOPATH="$HOMEBREW_PREFIX/share/info:${INFOPATH:-}"
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
{{- if .proxy.http_port }}
export HTTP_PROXY="http://{{ .proxy.host }}:{{ .proxy.http_port }}"
export HTTPS_PROXY="http://{{ .proxy.host }}:{{ .proxy.http_port }}"
{{- end }}
{{- if .proxy.socks_port }}
export SOCKS_PROXY="socks5://{{ .proxy.host }}:{{ .proxy.socks_port }}"
{{- end }}
export NO_PROXY="localhost,127.0.0.1,::1,.local"

# 小写版本
export http_proxy="$HTTP_PROXY"
export https_proxy="$HTTPS_PROXY"
export socks_proxy="$SOCKS_PROXY"
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

# 确保配置目录存在
[[ ! -d "$CONFIG_DIR" ]] && mkdir -p "$CONFIG_DIR"
[[ ! -d "$LOCAL_BIN" ]] && mkdir -p "$LOCAL_BIN"

{{- if .features.enable_1password }}
# 加载 1Password 密钥 (如果文件存在)
if [[ -f "$USER_HOME/.secrets" ]]; then
    source "$USER_HOME/.secrets"
fi
{{- end }}