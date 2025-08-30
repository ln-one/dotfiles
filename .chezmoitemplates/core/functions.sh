# ========================================
# Basic Utility Functions
# ========================================

# Create directory and enter it
mkcd() {
    if [ -z "$1" ]; then
        echo "Usage: mkcd <directory>"
        return 1
    fi
    mkdir -p "$1" && cd "$1"
    echo "Created and entered directory: $1"
}

# Extract various archive files
{{- if .features.enable_atool }}
# Use atool for advanced archive handling
alias extract='atool --extract --subdir'
alias compress='apack'
{{- else }}
# Fallback simple extract function
extract() {
    if [ -f "$1" ]; then
        case $1 in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}
{{- end }}

# System info (only defined in non-remote environments)
{{- if ne .environment "remote" }}
sysinfo() {
    echo "=== System Information ==="
    echo "OS: {{ .chezmoi.os }}"
    echo "Architecture: {{ .chezmoi.arch }}"
    echo "Hostname: {{ .chezmoi.hostname }}"
    echo "Shell: $SHELL"
    echo "User: $USER"
    echo "Home: $HOME"
    echo "PWD: $PWD"
    echo "=========================="
}
{{- end }}