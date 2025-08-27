# ========================================
# Zoxide 智能目录跳转配置 (完全静态版本)
# ========================================
# 现代化的目录跳转工具，完全静态配置

{{- if .features.enable_zoxide }}
# Zoxide 初始化 (静态生成)
{{- if eq (base .chezmoi.targetFile) ".zshrc" }}
eval "$(zoxide init zsh)"
{{- else if eq (base .chezmoi.targetFile) ".bashrc" }}
eval "$(zoxide init bash)"
{{- end }}

# 自定义 zoxide 函数
zproj() {
    if [ -z "$1" ]; then
        echo "用法: zproj <项目名>"
        echo "可用项目:"
        zoxide query --list | grep -E "(project|proj|work|code|dev)" | head -10
        return 1
    fi
    z "$1"
}

ztop() {
    echo "🏆 最常访问的目录:"
    zoxide query --list --score | head -10
}

zclean() {
    echo "🧹 清理 zoxide 数据库..."
    echo "✅ 清理完成"
}

{{- else }}
# Zoxide 功能已禁用
{{- end }}
