{{- if .features.enable_starship }}
    # Starship 提示符
    eval "$(starship init bash)"
{{- end }}

{{- if .features.enable_zoxide }}
    # Zoxide 智能目录跳转
    eval "$(zoxide init bash)"
{{- end }}

{{- if .features.enable_fzf }}
    # FZF 模糊搜索
    eval "$(fzf --bash)"
{{- end }}

{{- if .features.enable_conda }}
    # Conda 环境管理
    eval "$(conda shell.bash hook)"
{{- end }}