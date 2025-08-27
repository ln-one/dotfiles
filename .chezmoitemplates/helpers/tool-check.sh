{{/*
工具检测辅助模板
===================================

用途：检测系统中是否存在指定工具，并根据检测结果执行相应操作

参数：
- tool: 要检测的工具名称（必需）
- feature: 功能开关，控制是否启用该工具（可选，默认true）
- found: 工具存在时执行的代码（可选）
- notFound: 工具不存在时执行的代码（可选）
- silent: 是否静默模式，不输出警告信息（可选，默认false）
- required: 是否为必需工具，影响错误信息的严重程度（可选，默认false）

使用示例：
{{ includeTemplate "helpers/tool-check.sh" (dict 
    "tool" "starship" 
    "feature" .features.enable_starship 
    "found" "eval \"$(starship init zsh)\"" 
) }}

{{ includeTemplate "helpers/tool-check.sh" (dict 
    "tool" "fzf" 
    "feature" .features.enable_fzf 
    "found" "source ~/.fzf.zsh" 
    "notFound" "echo \"建议安装 fzf 以获得更好的搜索体验\"" 
    "silent" false
) }}
*/}}

{{- $tool := .tool }}
{{- $feature := true }}
{{- if hasKey . "feature" }}{{- $feature = .feature }}{{- end }}
{{- $found := "" }}
{{- if hasKey . "found" }}{{- $found = .found }}{{- end }}
{{- $notFound := "" }}
{{- if hasKey . "notFound" }}{{- $notFound = .notFound }}{{- end }}
{{- $silent := false }}
{{- if hasKey . "silent" }}{{- $silent = .silent }}{{- end }}
{{- $required := false }}
{{- if hasKey . "required" }}{{- $required = .required }}{{- end }}

{{- if $feature }}
# 检测工具: {{ $tool }}
if command -v {{ $tool }} >/dev/null 2>&1; then
    {{- if $found }}
    {{ $found }}
    {{- end }}
{{- if or $notFound (not $silent) }}
else
    {{- if $notFound }}
    {{ $notFound }}
    {{- else if not $silent }}
        {{- if $required }}
    echo "❌ 必需工具 {{ $tool }} 未找到，请先安装" >&2
        {{- else }}
    echo "⚠️  工具 {{ $tool }} 未找到，相关功能将被禁用" >&2
        {{- end }}
    {{- end }}
{{- end }}
fi
{{- end }}
