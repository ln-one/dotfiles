# ========================================
# Chezmoi Layered Configuration Loader
# ========================================

# 1. Core Layer: Common base features for all environments (lowest priority)
{{ includeTemplate "core/environment.sh" . }}
{{ includeTemplate "core/aliases.sh" . }}
{{ includeTemplate "core/functions.sh" . }}
{{ includeTemplate "core/fzf.sh" . }}

# 2. Platform Layer: OS-specific configuration and tools (medium priority)
{{- if eq .chezmoi.os "linux" }}
{{ includeTemplate "platforms/linux/proxy-functions.sh" . }}
{{ includeTemplate "platforms/linux/theme-functions.sh" . }}
{{- else if eq .chezmoi.os "darwin" }}
{{ includeTemplate "platforms/darwin/macos-specific.sh" . }}
{{- end }}

# 3. Environment Layer: Environment-specific configuration (higher priority)
{{- if eq .environment "desktop" }}
{{ includeTemplate "environments/desktop.sh" . }}
{{- else if eq .environment "remote" }}
{{ includeTemplate "environments/remote.sh" . }}
{{- else }}
{{ includeTemplate "environments/desktop.sh" . }}
{{- end }}

# 4. User Layer: User overrides (highest priority)
{{- if stat (joinPath .chezmoi.sourceDir ".chezmoitemplates/local/user-overrides.sh") }}
{{ includeTemplate "local/user-overrides.sh" . }}
{{- end }}
{{- if stat (joinPath .chezmoi.sourceDir ".chezmoitemplates/local/local-config.sh") }}
{{ includeTemplate "local/local-config.sh" . }}
{{- end }}

# External user config files (in order of increasing priority)
if [[ -f "/etc/chezmoi/config.sh" ]]; then
    source "/etc/chezmoi/config.sh"
fi
if [[ -f "$HOME/.config/chezmoi/config.sh" ]]; then
    source "$HOME/.config/chezmoi/config.sh"
fi
if [[ -f "$HOME/.chezmoi.local.sh" ]]; then
    source "$HOME/.chezmoi.local.sh"
fi
if [[ -f "$(pwd)/.chezmoi.local.sh" ]]; then
    source "$(pwd)/.chezmoi.local.sh"
fi

# Environment variable config override (final priority)
if [[ -n "${CHEZMOI_USER_CONFIG:-}" ]]; then
    eval "$CHEZMOI_USER_CONFIG"
fi

# Export config info
export CHEZMOI_CONFIG_LOADED="true"
export CHEZMOI_CONFIG_LAYERS="core,platform,environment,user"
export CHEZMOI_PLATFORM="{{ .chezmoi.os }}"
export CHEZMOI_ENVIRONMENT="{{ .environment | default "desktop" }}"
