# ========================================
# Zsh Performance Tweaks
# ========================================
# Further optimize zsh startup performance
# Execute only in zsh


# Ensure execution only in zsh
if [ -n "$ZSH_VERSION" ]; then
    # Increase history file size, limit in-memory history
    HISTSIZE=50000
    SAVEHIST=10000

    # History options
    setopt HIST_EXPIRE_DUPS_FIRST
    setopt HIST_IGNORE_DUPS
    setopt HIST_IGNORE_ALL_DUPS
    setopt HIST_FIND_NO_DUPS
    setopt HIST_SAVE_NO_DUPS
    setopt HIST_REDUCE_BLANKS
    setopt HIST_VERIFY

    # Asynchronous loading optimization (for Starship prompt)
    # Starship is fast enough, no extra instant prompt config needed

    # Delay loading of non-critical functions
    autoload -Uz add-zsh-hook

    # Precompile common zsh config files
    _compile_zsh_files() {
        local file
        for file in ~/.zshrc ~/.zshenv ~/.zprofile ~/.zlogin ~/.zlogout; do
            if [[ -f "$file" && -r "$file" ]]; then
                if [[ ! -f "${file}.zwc" || "$file" -nt "${file}.zwc" ]]; then
                    zcompile "$file" 2>/dev/null || true
                fi
            fi
        done
    }

    # Compile in background, non-blocking
    add-zsh-hook precmd _compile_zsh_files
fi