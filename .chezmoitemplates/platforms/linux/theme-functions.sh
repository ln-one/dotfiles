# ========================================
# Theme Management Functions
# ========================================
# WhiteSur 主题切换功能 (迁移自原 system-tools.sh)

{{- if and (eq .chezmoi.os "linux") (not (env "SSH_CONNECTION")) (lookPath "gsettings") }}
# Only load theme functions on Linux desktop with GNOME

# WhiteSur 主题配置
THEME_DIR="${THEME_DIR:-$HOME/.Theme/WhiteSur-gtk-theme}"
THEME_SCRIPT="$DOTFILES_DIR/scripts/tools/theme-manager.sh"

# Switch to dark theme (WhiteSur Dark)
dark() {
    echo "🌙 切换到暗色主题..."
    
    # 优先使用主题管理脚本
    if [[ -x "$THEME_SCRIPT" ]]; then
        echo "使用主题管理脚本切换到暗色主题..."
        "$THEME_SCRIPT" dark
        return $?
    fi
    
    # 备用方案：直接设置 WhiteSur 暗色主题
    if [[ -d "$THEME_DIR" ]] && command -v gsettings >/dev/null 2>&1; then
        echo "设置 WhiteSur 暗色主题..."
        
        # 进入主题目录并执行完整的主题切换流程
        (
            cd "$THEME_DIR" || { echo "❌ 无法进入主题目录"; return 1; }
            
            # 设置 GTK 和 Shell 主题
            gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark-blue' 2>/dev/null || true
            gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Dark-blue' 2>/dev/null || true
            
            # 运行主题安装脚本以应用链接
            if [[ -x "./install.sh" ]]; then
                echo "运行主题安装脚本..."
                ./install.sh -l 2>/dev/null || echo "⚠️  主题安装脚本执行失败"
            fi
            
            # 设置系统配色方案
            gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
            
            # 更新 fcitx5 主题（如果存在）
            local fcitx5_config="$HOME/.config/fcitx5/conf/classicui.conf"
            if command -v fcitx5 >/dev/null 2>&1 && [[ -f "$fcitx5_config" ]]; then
                sed -i "s/^Theme=.*/Theme=macOS-dark/" "$fcitx5_config" 2>/dev/null || true
                fcitx5 -r 2>/dev/null || true
            fi
        )
        
        echo "✅ 已切换到 WhiteSur 暗色主题"
    else
        echo "⚠️  WhiteSur 主题未安装，使用默认暗色主题"
        gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
    fi
}

# Switch to light theme (WhiteSur Light)
light() {
    echo "☀️ 切换到亮色主题..."
    
    # 优先使用主题管理脚本
    if [[ -x "$THEME_SCRIPT" ]]; then
        echo "使用主题管理脚本切换到亮色主题..."
        "$THEME_SCRIPT" light
        return $?
    fi
    
    # 备用方案：直接设置 WhiteSur 亮色主题
    if [[ -d "$THEME_DIR" ]] && command -v gsettings >/dev/null 2>&1; then
        echo "设置 WhiteSur 亮色主题..."
        
        # 进入主题目录并执行完整的主题切换流程
        (
            cd "$THEME_DIR" || { echo "❌ 无法进入主题目录"; return 1; }
            
            # 设置 GTK 和 Shell 主题
            gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Light-blue' 2>/dev/null || true
            gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Light-blue' 2>/dev/null || true
            
            # 运行主题安装脚本以应用链接（亮色模式）
            if [[ -x "./install.sh" ]]; then
                echo "运行主题安装脚本..."
                ./install.sh -l -c light 2>/dev/null || echo "⚠️  主题安装脚本执行失败"
            fi
            
            # 设置系统配色方案
            gsettings set org.gnome.desktop.interface color-scheme 'prefer-light' 2>/dev/null || true
            
            # 更新 fcitx5 主题（如果存在）
            local fcitx5_config="$HOME/.config/fcitx5/conf/classicui.conf"
            if command -v fcitx5 >/dev/null 2>&1 && [[ -f "$fcitx5_config" ]]; then
                sed -i "s/^Theme=.*/Theme=macOS-light/" "$fcitx5_config" 2>/dev/null || true
                fcitx5 -r 2>/dev/null || true
            fi
        )
        
        echo "✅ 已切换到 WhiteSur 亮色主题"
    else
        echo "⚠️  WhiteSur 主题未安装，使用默认亮色主题"
        gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-light' 2>/dev/null || true
    fi
}

# Show theme status
themestatus() {
    echo "🎨 主题状态检查:"
    echo ""
    
    # 优先使用主题管理脚本
    if [[ -x "$THEME_SCRIPT" ]]; then
        "$THEME_SCRIPT" status
        return
    fi
    
    # 备用方案：直接查询 gsettings
    if command -v gsettings >/dev/null 2>&1; then
        local gtk_theme=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'")
        local shell_theme=$(gsettings get org.gnome.shell.extensions.user-theme name 2>/dev/null | tr -d "'")
        local color_scheme=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null | tr -d "'")
        
        echo "🖥️  GNOME 主题:"
        echo "  GTK: ${gtk_theme:-未知}"
        echo "  Shell: ${shell_theme:-未知}"
        echo "  配色: ${color_scheme:-未知}"
        
        # 检查 WhiteSur 主题是否安装
        if [[ -d "$THEME_DIR" ]]; then
            echo "  WhiteSur: ✅ 已安装"
        else
            echo "  WhiteSur: ❌ 未安装"
        fi
        
        # 检查 fcitx5 主题
        local fcitx5_config="$HOME/.config/fcitx5/conf/classicui.conf"
        if [[ -f "$fcitx5_config" ]]; then
            local fcitx5_theme=$(grep "^Theme=" "$fcitx5_config" 2>/dev/null | cut -d'=' -f2 || echo "未设置")
            echo "  fcitx5: ${fcitx5_theme}"
        fi
    else
        echo "❌ gsettings 不可用"
    fi
}

{{- else }}
# Placeholder functions for non-GNOME environments
dark() {
    echo "ℹ️  WhiteSur 主题切换功能仅在 Linux GNOME 桌面环境中可用"
}

light() {
    echo "ℹ️  WhiteSur 主题切换功能仅在 Linux GNOME 桌面环境中可用"
}

themestatus() {
    echo "ℹ️  主题状态检查功能仅在 Linux GNOME 桌面环境中可用"
}
{{- end }}