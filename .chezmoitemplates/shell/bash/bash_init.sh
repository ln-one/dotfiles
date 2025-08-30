# ========================================
# Bash Shell Initialization
# ========================================

{{- if .features.enable_starship }}
# Starship prompt
eval "$(starship init bash)"
{{- end }}

{{- if .features.enable_zoxide }}
# Zoxide smart directory jumping
eval "$(zoxide init bash)"
{{- end }}

{{- if .features.enable_fzf }}
# FZF fuzzy finder
eval "$(fzf --bash)"
{{- end }}

{{- if .features.enable_conda }}
# Conda environment management
eval "$(conda shell.bash hook)"
{{- end }}