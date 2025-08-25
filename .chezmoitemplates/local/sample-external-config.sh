#!/bin/bash
# Sample External Configuration File
# Copy this file to one of the following locations to customize your configuration:
#
# Priority (highest to lowest):
# 1. $(pwd)/.chezmoi.local.sh          - Project-specific configuration
# 2. $HOME/.chezmoi.local.sh           - User home directory configuration  
# 3. $HOME/.config/chezmoi/config.sh   - User config directory
# 4. /etc/chezmoi/config.sh            - System-wide configuration
#
# Example usage:
# cp .chezmoitemplates/local/sample-external-config.sh ~/.chezmoi.local.sh
# Edit ~/.chezmoi.local.sh with your personal settings

# ========================================
# Personal Information
# ========================================
export GIT_USER_NAME="Your Name"
export GIT_USER_EMAIL="your.email@example.com"

# ========================================
# Tool Preferences
# ========================================
export PREFERRED_EDITOR="code"        # Options: nvim, code, vim, nano
export PREFERRED_SHELL="zsh"          # Options: zsh, bash
export PREFERRED_TERMINAL="ghostty"   # Options: ghostty, alacritty, kitty
export PREFERRED_BROWSER="firefox"    # Options: firefox, chrome, safari

# ========================================
# Proxy Configuration
# ========================================
export PROXY_ENABLED=true
export PROXY_HOST="127.0.0.1"
export PROXY_HTTP_PORT=7890
export PROXY_SOCKS_PORT=7891

# ========================================
# Development Environment
# ========================================
export LOCAL_PROJECTS_DIR="$HOME/projects"
export LOCAL_WORK_DIR="$HOME/work"

# Node.js version preference
export LOCAL_NODE_VERSION="20"

# Python version preference  
export LOCAL_PYTHON_VERSION="3.11"

# Go version preference
export LOCAL_GO_VERSION="1.21"

# ========================================
# Feature Toggles
# ========================================
export ENABLE_AI_TOOLS=true
export ENABLE_DOCKER=true
export ENABLE_KUBERNETES=false
export ENABLE_THEME_SWITCHING=true

# ========================================
# Custom Aliases
# ========================================
alias myproject="cd $LOCAL_PROJECTS_DIR/my-important-project"
alias work="cd $LOCAL_WORK_DIR"
alias deploy="./scripts/deploy.sh"
alias logs="docker logs -f"

# Git aliases
alias gst="git status"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gp="git push"
alias gl="git pull"

# ========================================
# Custom Functions
# ========================================

# Quick project navigation
proj() {
    if [[ $# -eq 0 ]]; then
        cd "$LOCAL_PROJECTS_DIR"
    else
        cd "$LOCAL_PROJECTS_DIR/$1"
    fi
}

# Quick work navigation
work() {
    if [[ $# -eq 0 ]]; then
        cd "$LOCAL_WORK_DIR"
    else
        cd "$LOCAL_WORK_DIR/$1"
    fi
}

# Docker cleanup function
docker-cleanup() {
    echo "Cleaning up Docker containers and images..."
    docker container prune -f
    docker image prune -f
    docker volume prune -f
    docker network prune -f
}

# ========================================
# Environment-Specific Overrides
# ========================================

# Override configurations based on detected environment
case "${CHEZMOI_ENVIRONMENT:-desktop}" in
    "desktop")
        # Desktop-specific overrides
        export ENABLE_GUI_TOOLS=true
        ;;
    "remote")
        # Remote-specific overrides
        export ENABLE_GUI_TOOLS=false
        export PROXY_ENABLED=false  # Disable proxy in remote environments
        ;;
    "container")
        # Container-specific overrides
        export ENABLE_GUI_TOOLS=false
        export ENABLE_DOCKER=false  # Don't need Docker in Docker
        ;;
    "wsl")
        # WSL-specific overrides
        export ENABLE_GUI_TOOLS=false
        export WSL_INTEGRATION=true
        ;;
esac

# ========================================
# Platform-Specific Overrides
# ========================================

case "${CHEZMOI_PLATFORM:-linux}" in
    "darwin")
        # macOS-specific overrides
        export PREFERRED_PACKAGE_MANAGER="brew"
        alias ls="ls -G"
        ;;
    "linux")
        # Linux-specific overrides
        export PREFERRED_PACKAGE_MANAGER="apt"
        alias ls="ls --color=auto"
        ;;
esac

# ========================================
# Custom PATH Extensions
# ========================================

# Add custom directories to PATH
custom_paths=(
    "$HOME/.local/bin"
    "$HOME/bin"
    "$HOME/.cargo/bin"
    "$HOME/go/bin"
    "$LOCAL_PROJECTS_DIR/scripts"
)

for custom_path in "${custom_paths[@]}"; do
    if [[ -d "$custom_path" ]] && [[ ":$PATH:" != *":$custom_path:"* ]]; then
        export PATH="$custom_path:$PATH"
    fi
done

# ========================================
# Load Additional Configuration
# ========================================

# Load machine-specific configuration if it exists
if [[ -f "$HOME/.config/chezmoi/machine-specific.sh" ]]; then
    source "$HOME/.config/chezmoi/machine-specific.sh"
fi

# Load project-specific configuration if we're in a project directory
if [[ -f "$(pwd)/.project-config.sh" ]]; then
    source "$(pwd)/.project-config.sh"
fi

echo "External configuration loaded from: ${BASH_SOURCE[0]}"