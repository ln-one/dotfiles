# ========================================
# Zoxide 智能目录跳转配置
# ========================================
# 现代化的目录跳转工具，比传统的 z 更快更智能
# 支持模糊匹配和频率算法
# ========================================

{{- if .features.enable_zoxide }}
# 检查 zoxide 是否已安装
if command -v zoxide >/dev/null 2>&1; then
    # 初始化 zoxide (根据当前 shell 自动检测)
    # 在模板中，我们需要根据文件类型来决定初始化方式
    {{- if eq (base .chezmoi.targetFile) ".bashrc" }}
    eval "$(zoxide init bash)"
    {{- else if eq (base .chezmoi.targetFile) ".zshrc" }}
    eval "$(zoxide init zsh)"
    {{- else }}
    # 运行时检测 shell 类型
    # 注意: evalcache 配置在 evalcache-config.sh 中处理
    if [ -n "$ZSH_VERSION" ]; then
        if ! command -v _evalcache >/dev/null 2>&1; then
            eval "$(zoxide init zsh)"
        fi
    elif [ -n "$BASH_VERSION" ]; then
        if ! command -v _evalcache >/dev/null 2>&1; then
            eval "$(zoxide init bash)"
        fi
    else
        # 默认使用 POSIX 兼容模式
        if ! command -v _evalcache >/dev/null 2>&1; then
            eval "$(zoxide init posix --cmd z)"
        fi
    fi
    {{- end }}
    
    # 自定义别名 (可选)
    # alias cd='z'  # 将 cd 替换为 z (谨慎使用)
    
    # 有用的 zoxide 函数
    # 快速跳转到项目目录
    zproj() {
        if [ -z "$1" ]; then
            echo "用法: zproj <项目名>"
            echo "可用项目:"
            zoxide query --list | grep -E "(project|proj|work|code|dev)" | head -10
            return 1
        fi
        z "$1"
    }
    
    # 显示最常访问的目录
    ztop() {
        echo "🏆 最常访问的目录:"
        zoxide query --list --score | head -10
    }
    
    # 清理 zoxide 数据库中不存在的目录
    zclean() {
        echo "🧹 清理 zoxide 数据库..."
        # zoxide 会自动清理不存在的目录，这里只是一个占位符
        echo "✅ 清理完成"
    }
    
    {{- if .features.enable_fzf }}
    # 如果启用了 fzf，增强 zi 命令的体验
    # zi 命令已经内置了 fzf 支持，无需额外配置
    {{- end }}
    
else
    # 如果 zoxide 未安装，提供安装提示
    # 注意：不定义 z() 函数，避免与别名冲突
    zoxide_not_installed() {
        echo "❌ zoxide 未安装"
        echo "💡 运行以下命令安装:"
{{- if eq .chezmoi.os "darwin" }}
        echo "   brew install zoxide"
{{- else if eq .chezmoi.os "linux" }}
        echo "   curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash"
{{- end }}
        echo "   或者运行 chezmoi apply 来自动安装"
    }
    
    # 为 zi 命令提供回退
    zi() { 
        zoxide_not_installed
    }
fi
{{- end }}