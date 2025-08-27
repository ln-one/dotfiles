# ========================================
# 桌面环境特定配置
# ========================================
# 适用于具有图形界面的桌面环境，模块化加载

# 加载桌面基础配置
{{- includeTemplate "environments/desktop/base.sh" . }}

# 加载桌面UI配置
{{- includeTemplate "environments/desktop/ui-config.sh" . }}

# 加载桌面工具配置
{{- includeTemplate "environments/desktop/tools-config.sh" . }}

# 加载媒体配置
{{- includeTemplate "environments/desktop/media-config.sh" . }}

# 加载开发环境配置
{{- includeTemplate "environments/desktop/development.sh" . }}

# 加载系统集成配置
{{- includeTemplate "environments/desktop/system-integration.sh" . }}

