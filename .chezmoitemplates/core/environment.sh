# ========================================
# Environment Variables Configuration
# ========================================
# Managed by Chezmoi, dynamically generated based on platform and user config

# Basic color and pager configuration
export CLICOLOR=1
{{- if eq .chezmoi.os "linux" }}
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
{{- else if eq .chezmoi.os "darwin" }}
export LSCOLORS=ExFxCxDxBxegedabagacad
{{- end }}
export PAGER="less"

# Basic path variables
export USER_HOME="{{ .chezmoi.homeDir }}"
export CONFIG_DIR="{{ .paths.config }}"
export LOCAL_BIN="{{ .chezmoi.homeDir }}/.local/bin"

# Editor configuration
export EDITOR="{{ .preferences.editor }}"
export VISUAL="{{ .preferences.editor }}"

# Language and locale configuration
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"

# 1Password SSH Agent integration
# 1Password SSH Agent integration
{{- if .features.enable_1password }}
  {{- if eq .chezmoi.os "darwin" }}
    SSH_AGENT_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
  {{- else if eq .chezmoi.os "linux" }}
    SSH_AGENT_SOCK="$HOME/.1password/agent.sock"
  {{- end }}
  if [ -S "$SSH_AGENT_SOCK" ]; then
    export SSH_AUTH_SOCK="$SSH_AGENT_SOCK"
    {{- if .features.enable_ssh }}
      # Silently check SSH Agent status
      ssh-add -l >/dev/null 2>&1 || true
    {{- end }}
  fi
{{- end }}

{{- if eq .chezmoi.os "darwin" }}
  {{- if stat "/opt/homebrew" }}
    # Homebrew environment config (macOS)
    export HOMEBREW_PREFIX="/opt/homebrew"
  {{- end }}
{{- else if eq .chezmoi.os "linux" }}
  {{- if stat "/home/linuxbrew/.linuxbrew" }}
    # Homebrew environment config (Linux)
    export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
  {{- end }}
{{- end }}

# Homebrew environment initialization
{{- if eq .chezmoi.os "linux" }}
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
{{- else if eq .chezmoi.os "darwin" }}
eval "$(/opt/homebrew/bin/brew shellenv)"
{{- end }}

# Starship prompt configuration
{{- if .features.enable_starship }}
export STARSHIP_CONFIG="$HOME/.config/starship.toml"

{{- if eq .environment "remote" }}
# Remote environment optimization
export STARSHIP_CACHE="$HOME/.cache/starship"
mkdir -p "$HOME/.cache/starship"
{{- end }}
{{- end }}

# Platform-specific environment variables
{{- if eq .chezmoi.os "linux" }}
  # Linux specific configuration
  export XDG_CONFIG_HOME="$CONFIG_DIR"
  export XDG_DATA_HOME="$USER_HOME/.local/share"
  export XDG_CACHE_HOME="$USER_HOME/.cache"

  {{- if eq .environment "remote" }}
    # SSH remote server optimization
    export TERM="${TERM:-xterm-256color}"
  {{- end }}

{{- else if eq .chezmoi.os "darwin" }}
  # macOS specific configuration
  export HOMEBREW_NO_ANALYTICS=1
  export HOMEBREW_NO_AUTO_UPDATE=1
{{- end }}

# Development tool environment variables
{{- if .features.enable_ai_tools }}
  # AI tool configuration
  export OPENAI_API_BASE="${OPENAI_API_BASE:-}"
{{- end }}

{{- if and .features.enable_proxy .proxy.enabled }}
  # Proxy configuration
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

# Performance optimization configuration
{{- if eq .preferences.shell "zsh" }}
  # Zsh specific optimization
  export HISTSIZE=10000
  export SAVEHIST=10000
  export HISTFILE="$USER_HOME/.zsh_history"
  export HIST_STAMPS="yyyy-mm-dd"
{{- end }}

# Node.js version manager configuration
{{- if .features.enable_node }}
  # fnm (Fast Node Manager) path configuration
  # Note: fnm actual initialization is handled in evalcache-config.sh (supports defer)
  export FNM_PATH="$USER_HOME/.local/share/fnm"
  if [ -d "$FNM_PATH" ]; then
    export PATH="$FNM_PATH:$PATH"
  fi
{{- end }}

# Ensure config directories exist
[ ! -d "$CONFIG_DIR" ] && mkdir -p "$CONFIG_DIR"
[ ! -d "$LOCAL_BIN" ] && mkdir -p "$LOCAL_BIN"

{{- if .features.enable_1password }}
  # Load 1Password secrets (if file exists)
  if [ -f "$USER_HOME/.secrets" ]; then
    . "$USER_HOME/.secrets"
  fi
{{- end }}