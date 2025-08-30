# ========================================
# Zim Framework Configuration
# ========================================
# Only execute Zim config in zsh
if [[ -n "${ZSH_VERSION}" ]]; then
    export ZIM_HOME="${ZDOTDIR:-${HOME}}/.zim"

    # Zim performance optimization
    zstyle ':zim:zmodule' use 'degit'
    zstyle ':zim' disable-version-check yes

    # Download and install Zim if not present
    if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
        echo "Downloading Zim framework manager..."
        {{- if .features.enable_curl }}
        curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
            https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
        {{- else if .features.enable_wget }}
        mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
            https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
        {{- else }}
        echo "Error: curl or wget is required to download Zim framework manager"
        return 1
        {{- end }}
    fi

    # Install missing modules and update init script
    if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
        echo "Initializing Zim modules..."
        source ${ZIM_HOME}/zimfw.zsh init -q
    fi

    # Initialize Zim if installed
    if [[ -s ${ZIM_HOME}/init.zsh ]]; then
        source ${ZIM_HOME}/init.zsh
    else
        echo "Warning: Zim init script not found, please run 'zimfw install'"
        return 1
    fi

    # Do not call compinit here; let Zim manage completion system
fi