# ========================================
# macOS Specific Configuration
# ========================================
# macOS 平台特定的配置和功能
# 仅在 macOS 环境中加载

{{- if eq .chezmoi.os "darwin" }}

# ========================================
# macOS 环境变量配置
# ========================================

# Homebrew 配置优化
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1

# macOS 特定的颜色配置
export LSCOLORS=ExFxCxDxBxegedabagacad

# ========================================
# macOS 特定别名
# ========================================

# 系统管理
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES && killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO && killall Finder'

# 应用程序快捷方式
alias code='open -a "Visual Studio Code"'
alias finder='open -a Finder'

# 系统信息
alias cpu='sysctl -n machdep.cpu.brand_string'
alias memory='system_profiler SPMemoryDataType'

# ========================================
# macOS 特定函数
# ========================================

# 获取 macOS 版本信息
macos_version() {
    echo "🍎 macOS 系统信息:"
    echo "版本: $(sw_vers -productVersion)"
    echo "构建: $(sw_vers -buildVersion)"
    echo "名称: $(sw_vers -productName)"
}

# App Store 应用管理 (需要 mas)
{{- if .features.enable_mas }}
# 列出已安装的 App Store 应用
mas_list() {
    echo "📱 已安装的 App Store 应用:"
    mas list
}

# 更新所有 App Store 应用
mas_upgrade() {
    echo "🔄 更新所有 App Store 应用..."
    mas upgrade
}

# 搜索 App Store 应用
mas_search() {
    if [[ -z "$1" ]]; then
        echo "用法: mas_search <应用名称>"
        return 1
    fi
    echo "🔍 搜索 App Store 应用: $1"
    mas search "$1"
}
{{- end }}

# Homebrew Cask 应用管理
# 列出已安装的 Cask 应用
cask_list() {
    echo "📦 已安装的 Homebrew Cask 应用:"
    brew list --cask
    }
    
    # 更新所有 Cask 应用
    cask_upgrade() {
        echo "🔄 更新所有 Homebrew Cask 应用..."
        brew upgrade --cask
    }
    
    # 搜索 Cask 应用
    cask_search() {
        if [[ -z "$1" ]]; then
            echo "用法: cask_search <应用名称>"
            return 1
        fi
        echo "🔍 搜索 Homebrew Cask 应用: $1"
        brew search --cask "$1"
    }
    
    # 清理 Homebrew 缓存
    brew_cleanup() {
        echo "🧹 清理 Homebrew 缓存..."
        brew cleanup
        brew autoremove
        echo "✅ Homebrew 清理完成"
    }
fi

# 应用配置备份 (需要 mackup)
{{- if .features.enable_mackup }}
# 备份应用配置
backup_configs() {
    echo "💾 备份应用配置..."
    mackup backup
}

# 恢复应用配置
restore_configs() {
    echo "📥 恢复应用配置..."
    mackup restore
}
{{- end }}
    
    # 列出支持的应用
    mackup_list() {
        echo "📋 Mackup 支持的应用:"
        mackup list
    }
fi

# ========================================
# macOS 系统优化函数
# ========================================

# 显示隐藏文件
show_hidden() {
    defaults write com.apple.finder AppleShowAllFiles YES
    killall Finder
    echo "✅ 已显示隐藏文件"
}

# 隐藏隐藏文件
hide_hidden() {
    defaults write com.apple.finder AppleShowAllFiles NO
    killall Finder
    echo "✅ 已隐藏隐藏文件"
}

# 重置 Dock
reset_dock() {
    echo "🔄 重置 Dock 到默认设置..."
    defaults delete com.apple.dock
    killall Dock
    echo "✅ Dock 已重置"
}

# 清理系统缓存
clean_system() {
    echo "🧹 清理系统缓存..."
    
    # 清理用户缓存
    if [[ -d "$HOME/Library/Caches" ]]; then
        echo "清理用户缓存..."
        find "$HOME/Library/Caches" -type f -atime +7 -delete 2>/dev/null || true
    fi
    
    # 清理下载文件夹中的旧文件
    if [[ -d "$HOME/Downloads" ]]; then
        echo "清理下载文件夹中 30 天前的文件..."
        find "$HOME/Downloads" -type f -atime +30 -delete 2>/dev/null || true
    fi
    
    # 清理垃圾桶
    echo "清空垃圾桶..."
    osascript -e 'tell application "Finder" to empty trash' 2>/dev/null || true
    
    echo "✅ 系统清理完成"
}

# ========================================
# macOS 开发环境配置
# ========================================

# Xcode 命令行工具检查
check_xcode_tools() {
    if xcode-select -p >/dev/null 2>&1; then
        echo "✅ Xcode 命令行工具已安装: $(xcode-select -p)"
    else
        echo "❌ Xcode 命令行工具未安装"
        echo "运行以下命令安装: xcode-select --install"
    fi
}

# 显示系统资源使用情况
system_status() {
    echo "🖥️  macOS 系统状态:"
    echo ""
    
    # CPU 信息
    echo "💻 CPU: $(sysctl -n machdep.cpu.brand_string)"
    
    # 内存使用情况
    echo "🧠 内存使用情况:"
    vm_stat | grep -E "(Pages free|Pages active|Pages inactive|Pages speculative|Pages wired down)" | \
    while read line; do
        echo "   $line"
    done
    
    # 磁盘使用情况
    echo "💾 磁盘使用情况:"
    df -h / | tail -1 | awk '{print "   使用: " $3 " / " $2 " (" $5 ")"}'
    
    # 系统负载
    echo "⚡ 系统负载: $(uptime | awk -F'load averages:' '{print $2}')"
    
    # 网络连接
    if command -v netstat >/dev/null 2>&1; then
        local connections=$(netstat -an | grep ESTABLISHED | wc -l | tr -d ' ')
        echo "🌐 活跃网络连接: $connections"
    fi
}

{{- else }}
# 非 macOS 环境的占位函数
macos_version() {
    echo "ℹ️  此功能仅在 macOS 环境中可用"
}

mas_list() {
    echo "ℹ️  Mac App Store 功能仅在 macOS 环境中可用"
}

cask_list() {
    echo "ℹ️  Homebrew Cask 功能仅在 macOS 环境中可用"
}

backup_configs() {
    echo "ℹ️  Mackup 配置备份功能仅在 macOS 环境中可用"
}

show_hidden() {
    echo "ℹ️  Finder 配置功能仅在 macOS 环境中可用"
}

clean_system() {
    echo "ℹ️  macOS 系统清理功能仅在 macOS 环境中可用"
}

system_status() {
    echo "ℹ️  macOS 系统状态功能仅在 macOS 环境中可用"
}
{{- end }}