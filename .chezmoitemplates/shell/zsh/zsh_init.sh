# ========================================
# Evalcache performance optimization
# ========================================

{{- if .features.enable_zsh_defer }}
# Initialize zsh-defer if available
if [[ -n "${ZSH_VERSION}" ]]; then
    if [[ -f "${ZIM_HOME}/modules/zsh-defer/zsh-defer.plugin.zsh" ]]; then
        source "${ZIM_HOME}/modules/zsh-defer/zsh-defer.plugin.zsh"
    else
        echo "zsh-defer not found, please run 'zimfw install'"
    fi
fi
{{- end }}

{{- if .features.enable_zsh_defer }}


    # Manually install and defer load zsh-syntax-highlighting
    if [[ ! -d "${ZIM_HOME}/modules/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZIM_HOME}/modules/zsh-syntax-highlighting" 2>/dev/null || true
    fi

    # Defer load syntax highlighting
    if [[ -f "${ZIM_HOME}/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
        zsh-defer source "${ZIM_HOME}/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    fi

    # Defer load completion system
    zsh-defer -c '
        # Initialize completion system
{{- else }}
    # Directly load syntax highlighting (no zsh-defer)
    if [[ -f "${ZIM_HOME}/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
        source "${ZIM_HOME}/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    fi

    # Directly initialize completion system
{{- end }}
        autoload -Uz compinit

        # Optimize completion loading - check once per day
        local zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
        if [[ $zcompdump(#qNmh+24) ]]; then
            compinit -d "$zcompdump"
        else
            compinit -C -d "$zcompdump"
        fi

        # Load Zim completion module
        if [[ -f "${ZIM_HOME}/modules/completion/init.zsh" ]]; then
            source "${ZIM_HOME}/modules/completion/init.zsh"
        fi
{{- if .features.enable_zsh_defer }}
    '

    # Defer history substring search key bindings
    zsh-defer -c '
        # Configure key bindings for history substring search
        if [[ -n "${widgets[history-substring-search-up]}" ]]; then
            # Bind arrow keys to history substring search
            bindkey "^[[A" history-substring-search-up
            bindkey "^[[B" history-substring-search-down

            # Compatibility for different terminal keycodes
            bindkey "^[OA" history-substring-search-up
            bindkey "^[OB" history-substring-search-down

            # Enable in vi mode
            bindkey -M vicmd "k" history-substring-search-up
            bindkey -M vicmd "j" history-substring-search-down
        fi
    '
{{- end }}



{{- if .features.enable_evalcache }}
    {{- if eq (base .chezmoi.targetFile) ".zshrc" }}
        # Load evalcache plugin (Zsh only)
        if [[ -f "$HOME/.evalcache/evalcache.plugin.zsh" ]]; then
            source "$HOME/.evalcache/evalcache.plugin.zsh"
        fi

        # Evalcache static config
        # ========================================
        # Tools to initialize immediately (high priority)
        # ========================================

        {{- if .features.enable_starship }}
            # Starship prompt (highest priority)
            _evalcache starship init zsh
        {{- end }}

        # ========================================
        # Deferred initialization tools (static config)
        # ========================================

        {{- if .features.enable_zsh_defer }}
            # zsh-defer available, use deferred init
            # Python env management (deferred)
            {{- if .features.enable_pyenv }}
                zsh-defer -a _evalcache pyenv init --path
                zsh-defer -a _evalcache pyenv init -
            {{- end }}
            
            {{- if .features.enable_fuck }}
                zsh-defer -a _evalcache thefuck --alias
            {{- end }}

            # Ruby env management (deferred)
            {{- if .features.enable_rbenv }}
                zsh-defer -a _evalcache rbenv init -
            {{- end }}
        
            # Node.js env management (deferred, silent)
            {{- if .features.enable_fnm }}
                zsh-defer -a _evalcache fnm env
            {{- end }}

            # Tool version manager (deferred)
            {{- if .features.enable_mise }}
                zsh-defer -a _evalcache mise activate zsh
            {{- end }}

        {{- else }}
            # Direct init without zsh-defer
            {{- if .features.enable_pyenv }}
                _evalcache pyenv init --path
                _evalcache pyenv init -
            {{- end }}

            {{- if .features.enable_rbenv }}
                _evalcache rbenv init -
            {{- end }}

            {{- if .features.enable_fnm }}
                _evalcache fnm env
            {{- end }}

            {{- if .features.enable_mise }}
                _evalcache mise activate zsh
            {{- end }}
        {{- end }}

        # ========================================
        # Other tools deferred initialization (static config)
        # ========================================

        {{- if .features.enable_conda }}
            # Conda env management (deferred)
            {{- if .features.enable_zsh_defer }}
                zsh-defer -a _evalcache conda shell.zsh hook
            {{- else }}
                _evalcache conda shell.zsh hook
            {{- end }}
        {{- end }}

        {{- if .features.enable_zoxide }}
            # Zoxide smart directory jumping (deferred)
            {{- if .features.enable_zsh_defer }}
                {{- if eq (base .chezmoi.targetFile) ".zshrc" }}
                    zsh-defer -a _evalcache zoxide init zsh
                {{- else if eq (base .chezmoi.targetFile) ".bashrc" }}
                    _evalcache zoxide init bash
                {{- end }}
            {{- else }}
                {{- if eq (base .chezmoi.targetFile) ".zshrc" }}
                    _evalcache zoxide init zsh
                {{- else if eq (base .chezmoi.targetFile) ".bashrc" }}
                    _evalcache zoxide init bash
                {{- end }}
            {{- end }}
        {{- end }}

        # ========================================
        # Completion system deferred initialization (static config)
        # ========================================

        {{- if .features.enable_zsh_defer }}
            # Defer loading completions for common tools
            {{- if .features.enable_docker }}
                zsh-defer -a compdef _docker docker
            {{- end }}

            {{- if .features.enable_kubectl }}
                zsh-defer -a compdef _kubectl kubectl
            {{- end }}
        {{- else }}
            # Directly load completions (no zsh-defer)
            {{- if .features.enable_docker }}
                compdef _docker docker
            {{- end }}

            {{- if .features.enable_kubectl }}
                compdef _kubectl kubectl
            {{- end }}
        {{- end }}

    {{- else }}
        # Evalcache disabled, use direct initialization
        {{- if eq (base .chezmoi.targetFile) ".zshrc" }}
            # ZSH direct initialization
            {{- if .features.enable_starship }}
                eval "$(starship init zsh)"
            {{- end }}

            {{- if .features.enable_zoxide }}
                eval "$(zoxide init zsh)"
            {{- end }}
        {{- end }}

        {{- if .features.enable_fzf }}
            eval "$(fzf --zsh)"
        {{- end }}
    {{- end }}

{{- end }}

{{- if .features.enable_fzf }}
eval "$(fzf --zsh)"
{{- end }}