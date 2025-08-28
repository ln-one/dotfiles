#!/bin/bash

export GIT_USER_NAME="Your Name"
export GIT_USER_EMAIL="your.email@example.com"

export PREFERRED_EDITOR="code"
export PREFERRED_SHELL="zsh"
export PREFERRED_TERMINAL="ghostty"
export PREFERRED_BROWSER="firefox"

export PROXY_ENABLED=true
export PROXY_HOST="127.0.0.1"
export PROXY_HTTP_PORT=7890
export PROXY_SOCKS_PORT=7891

export LOCAL_PROJECTS_DIR="$HOME/projects"
export LOCAL_WORK_DIR="$HOME/work"
export LOCAL_NODE_VERSION="20"
export LOCAL_PYTHON_VERSION="3.11"
export LOCAL_GO_VERSION="1.21"

export ENABLE_AI_TOOLS=true
export ENABLE_DOCKER=true
export ENABLE_KUBERNETES=false
export ENABLE_THEME_SWITCHING=true

alias myproject="cd $LOCAL_PROJECTS_DIR/my-important-project"
alias work="cd $LOCAL_WORK_DIR"
alias deploy="./scripts/deploy.sh"
alias logs="docker logs -f"
alias gst="git status"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gp="git push"
alias gl="git pull"

proj() {
    if [[ $# -eq 0 ]]; then
        cd "$LOCAL_PROJECTS_DIR"
    else
        cd "$LOCAL_PROJECTS_DIR/$1"
    fi
}

work() {
    if [[ $# -eq 0 ]]; then
        cd "$LOCAL_WORK_DIR"
    else
        cd "$LOCAL_WORK_DIR/$1"
    fi
}

docker-cleanup() {
    echo "Cleaning up Docker containers and images..."
    docker container prune -f
    docker image prune -f
    docker volume prune -f
    docker network prune -f
}

case "${CHEZMOI_ENVIRONMENT:-desktop}" in
    "desktop")
        export ENABLE_GUI_TOOLS=true
        ;;
    "remote")
        export ENABLE_GUI_TOOLS=false
        export PROXY_ENABLED=false
        ;;
    "container")
        export ENABLE_GUI_TOOLS=false
        export ENABLE_DOCKER=false
        ;;
    "wsl")
        export ENABLE_GUI_TOOLS=false
        export WSL_INTEGRATION=true
        ;;
esac

case "${CHEZMOI_PLATFORM:-linux}" in
    "darwin")
        export PREFERRED_PACKAGE_MANAGER="brew"
        alias ls="ls -G"
        ;;
    "linux")
        export PREFERRED_PACKAGE_MANAGER="apt"
        alias ls="ls --color=auto"
        ;;
esac

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

if [[ -f "$HOME/.config/chezmoi/machine-specific.sh" ]]; then
    source "$HOME/.config/chezmoi/machine-specific.sh"
fi

if [[ -f "$(pwd)/.project-config.sh" ]]; then
    source "$(pwd)/.project-config.sh"
fi

echo "External configuration loaded from: ${BASH_SOURCE[0]}"