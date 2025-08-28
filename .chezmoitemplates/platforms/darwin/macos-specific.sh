# ========================================
# macOS Specific Configuration
# ========================================

{{- if eq .chezmoi.os "darwin" }}
# Homebrew configuration
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1

# macOS color settings
export LSCOLORS=ExFxCxDxBxegedabagacad

# Alias for memory info
alias memory='system_profiler SPMemoryDataType'
{{- end }}