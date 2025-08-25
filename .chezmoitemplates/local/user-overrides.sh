# User Configuration Overrides
# This file allows users to override default configurations without modifying source code
# Place your personal configuration overrides here

# Personal Information Overrides
# Uncomment and modify as needed:
# export GIT_USER_NAME="Your Name"
# export GIT_USER_EMAIL="your.email@example.com"

# Tool Preferences
# Uncomment and modify as needed:
# export PREFERRED_EDITOR="code"  # Options: nvim, code, vim, nano
# export PREFERRED_SHELL="zsh"    # Options: zsh, bash
# export PREFERRED_TERMINAL="ghostty"  # Options: ghostty, alacritty, kitty

# Proxy Configuration Overrides
# Uncomment and modify as needed:
# export PROXY_ENABLED=true
# export PROXY_HOST="127.0.0.1"
# export PROXY_HTTP_PORT=7890
# export PROXY_SOCKS_PORT=7891

# Feature Toggles
# Uncomment and modify as needed:
# export ENABLE_AI_TOOLS=true
# export ENABLE_DOCKER=false
# export ENABLE_KUBERNETES=false

# Custom Aliases
# Add your personal aliases here:
# alias myproject="cd ~/projects/my-important-project"
# alias deploy="./scripts/deploy.sh"

# Custom Functions
# Add your personal functions here:
# my_custom_function() {
#     echo "This is my custom function"
# }

# Environment-specific Overrides
# These will only apply in specific environments
case "${CHEZMOI_ENVIRONMENT:-desktop}" in
    "desktop")
        # Desktop-specific user overrides
        # export DESKTOP_SPECIFIC_VAR="value"
        ;;
    "remote")
        # Remote-specific user overrides
        # export REMOTE_SPECIFIC_VAR="value"
        ;;
    "container")
        # Container-specific user overrides
        # export CONTAINER_SPECIFIC_VAR="value"
        ;;
    "wsl")
        # WSL-specific user overrides
        # export WSL_SPECIFIC_VAR="value"
        ;;
esac

# Platform-specific Overrides
{{- if eq .chezmoi.os "darwin" }}
# macOS-specific user overrides
# export MACOS_SPECIFIC_VAR="value"
{{- else if eq .chezmoi.os "linux" }}
# Linux-specific user overrides
# export LINUX_SPECIFIC_VAR="value"
{{- end }}

# Load user's personal configuration if it exists
if [[ -f "$HOME/.config/chezmoi/user-config.sh" ]]; then
    source "$HOME/.config/chezmoi/user-config.sh"
fi