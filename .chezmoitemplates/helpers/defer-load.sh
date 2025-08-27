{{/*
延迟加载辅助模板
===================================

用途：使用 zsh-defer 延迟加载命令以提高 shell 启动速度

参数：
- command: 要延迟执行的命令（必需）
- fallback: 如果 zsh-defer 不可用时的备选方案（可选，默认使用原命令）
- condition: 执行条件（可选，默认true）
- delay: 延迟时间（秒，可选）
- priority: 优先级（可选）

使用示例：
{{ includeTemplate "helpers/defer-load.sh" (dict 
    "command" "eval \"$(starship init zsh)\"" 
    "condition" .features.enable_starship 
) }}

{{ includeTemplate "helpers/defer-load.sh" (dict 
    "command" "source ~/.fzf.zsh" 
    "fallback" "echo \"FZF 配置已跳过\"" 
    "delay" "0.1"
) }}
*/}}

{{- $command := .command }}
{{- $fallback := $command }}
{{- if hasKey . "fallback" }}{{- $fallback = .fallback }}{{- end }}
{{- $condition := true }}
{{- if hasKey . "condition" }}{{- $condition = .condition }}{{- end }}
{{- $delay := "" }}
{{- if hasKey . "delay" }}{{- $delay = .delay }}{{- end }}
{{- $priority := "" }}
{{- if hasKey . "priority" }}{{- $priority = .priority }}{{- end }}

{{- if $condition }}
# 延迟加载: {{ $command | regexReplaceAll "\"" "'" | trunc 50 }}...
if command -v zsh-defer >/dev/null 2>&1; then
    {{- if $delay }}
    zsh-defer -t {{ $delay }}{{ if $priority }} -p {{ $priority }}{{ end }} {{ $command }}
    {{- else if $priority }}
    zsh-defer -p {{ $priority }} {{ $command }}
    {{- else }}
    zsh-defer {{ $command }}
    {{- end }}
else
    # zsh-defer 不可用，直接执行
    {{ $fallback }}
fi
{{- end }}
