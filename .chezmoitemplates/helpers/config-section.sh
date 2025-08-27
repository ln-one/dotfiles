{{/*
配置节辅助模板
===================================

用途：创建带有标准格式的配置节，提供一致的配置组织结构

参数：
- name: 配置节名称（必需）
- content: 配置内容（必需）
- condition: 加载条件（可选，默认true）
- description: 配置节描述（可选）
- level: 标题级别，影响分隔线长度（可选，1=主要，2=次要，3=小节）

使用示例：
{{ includeTemplate "helpers/config-section.sh" (dict 
    "name" "Starship 提示符配置" 
    "description" "配置 Starship 跨 shell 提示符"
    "condition" .features.enable_starship
    "content" "eval \"$(starship init zsh)\""
    "level" 2
) }}
*/}}

{{- $name := .name }}
{{- $content := .content }}
{{- $condition := true }}
{{- if hasKey . "condition" }}{{- $condition = .condition }}{{- end }}
{{- $description := "" }}
{{- if hasKey . "description" }}{{- $description = .description }}{{- end }}
{{- $level := 1 }}
{{- if hasKey . "level" }}{{- $level = .level }}{{- end }}

{{- if $condition }}

{{- if eq $level 1 }}
# ============================================================
# {{ $name | upper }}
# ============================================================
{{- else if eq $level 2 }}
# ------------------------------------------------------------
# {{ $name }}
# ------------------------------------------------------------
{{- else }}
# {{ $name }}
# ........................................................
{{- end }}

{{- if $description }}
# {{ $description }}
{{- end }}

{{ $content }}

{{- end }}
