# Local Environment Configuration
# This file contains configuration specific to the local machine/environment
# It's designed to handle machine-specific settings that shouldn't be in version control

# Local Machine Information
# These can be set via chezmoi data or environment variables
{{- if hasKey . "local" }}
{{- if hasKey .local "machine_name" }}
export LOCAL_MACHINE_NAME="{{ .local.machine_name }}"
{{- end }}
{{- if hasKey .local "work_directory" }}
export LOCAL_WORK_DIR="{{ .local.work_directory }}"
{{- end }}
{{- if hasKey .local "projects_directory" }}
export LOCAL_PROJECTS_DIR="{{ .local.projects_directory }}"
{{- end }}
{{- end }}

# Local Network Configuration
{{- if hasKey . "local" }}
{{- if hasKey .local "proxy" }}
{{- if .local.proxy.enabled }}
# Proxy configuration from chezmoi data
export PROXY_ENABLED=true
export PROXY_HOST="{{ .local.proxy.host | default "127.0.0.1" }}"
export PROXY_HTTP_PORT="{{ .local.proxy.http_port | default 7890 }}"
export PROXY_SOCKS_PORT="{{ .local.proxy.socks_port | default 7891 }}"
{{- end }}
{{- end }}
{{- end }}

# Local Development Environment
{{- if hasKey . "local" }}
{{- if hasKey .local "development" }}
{{- if hasKey .local.development "node_version" }}
export LOCAL_NODE_VERSION="{{ .local.development.node_version }}"
{{- end }}
{{- if hasKey .local.development "python_version" }}
export LOCAL_PYTHON_VERSION="{{ .local.development.python_version }}"
{{- end }}
{{- if hasKey .local.development "go_version" }}
export LOCAL_GO_VERSION="{{ .local.development.go_version }}"
{{- end }}
{{- end }}
{{- end }}

# Local Tool Preferences
{{- if hasKey . "local" }}
{{- if hasKey .local "tools" }}
{{- if hasKey .local.tools "editor" }}
export PREFERRED_EDITOR="{{ .local.tools.editor }}"
{{- end }}
{{- if hasKey .local.tools "browser" }}
export PREFERRED_BROWSER="{{ .local.tools.browser }}"
{{- end }}
{{- if hasKey .local.tools "terminal" }}
export PREFERRED_TERMINAL="{{ .local.tools.terminal }}"
{{- end }}
{{- end }}
{{- end }}

# Local Path Extensions
# Add local bin directories to PATH if they exist
local_paths=(
    "$HOME/.local/bin"
    "$HOME/bin"
    "$HOME/.cargo/bin"
    "$HOME/go/bin"
    {{- if hasKey . "local" }}
    {{- if hasKey .local "custom_paths" }}
    {{- range .local.custom_paths }}
    "{{ . }}"
    {{- end }}
    {{- end }}
    {{- end }}
)

for local_path in "${local_paths[@]}"; do
    if [[ -d "$local_path" ]] && [[ ":$PATH:" != *":$local_path:"* ]]; then
        export PATH="$local_path:$PATH"
    fi
done



# Local Functions
# Function to quickly navigate to local projects
if [[ -n "${LOCAL_PROJECTS_DIR:-}" ]] && [[ -d "$LOCAL_PROJECTS_DIR" ]]; then
    proj() {
        if [[ $# -eq 0 ]]; then
            cd "$LOCAL_PROJECTS_DIR"
        else
            cd "$LOCAL_PROJECTS_DIR/$1"
        fi
    }
    
    # Tab completion for proj function
    if [[ -n "$ZSH_VERSION" ]]; then
        _proj() {
            local projects=("$LOCAL_PROJECTS_DIR"/*)
            projects=("${projects[@]##*/}")
            compadd "${projects[@]}"
        }
        
        # 延迟注册补全函数，确保 compinit 已经执行 (静态生成)
        {{- if and (eq (base .chezmoi.targetFile) ".zshrc") .features.enable_zsh_defer }}
        zsh-defer -t 1.0 compdef _proj proj
        {{- else if eq (base .chezmoi.targetFile) ".zshrc" }}
        # 如果没有 zsh-defer，直接注册补全
        compdef _proj proj
        {{- end }}
    fi
fi

# Local Environment Detection and Adaptation
detect_local_capabilities() {
    # Detect if we're in a development container
    if [[ -f "/.dockerenv" ]] || [[ -f "/run/.containerenv" ]]; then
        export LOCAL_IS_CONTAINER=true
    fi
    
    # Detect if we have GUI capabilities
    if [[ -n "${DISPLAY:-}" ]] || [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
        export LOCAL_HAS_GUI=true
    fi
    
    # Detect available package managers (静态生成)
    {{- if lookPath "brew" }}
    export LOCAL_HAS_BREW=true
    {{- end }}
    
    # Detect container runtime (静态生成)
    {{- if .features.enable_docker }}
    export LOCAL_HAS_DOCKER=true
    {{- end }}
    
    {{- if lookPath "podman" }}
    export LOCAL_HAS_PODMAN=true
    {{- end }}
}

# Run local capability detection
detect_local_capabilities

# Load machine-specific configuration if it exists
# This allows for per-machine customization without affecting the main config
local_config_files=(
    "$HOME/.config/chezmoi/local.sh"
    "$HOME/.chezmoi.local.sh"
    "$(dirname "${BASH_SOURCE[0]}")/../../../.chezmoi.local.sh"
)

for config_file in "${local_config_files[@]}"; do
    if [[ -f "$config_file" ]]; then
        source "$config_file"
        break
    fi
done