#!/usr/bin/env zsh
# Zim 框架配置加载模块
# 此文件负责初始化 Zim 框架，包括下载、安装和加载

# 确保只在 zsh 中执行 Zim 配置
if [[ -n "${ZSH_VERSION}" ]]; then
    # Zim 安装路径
    export ZIM_HOME="${ZDOTDIR:-${HOME}}/.zim"
    
    # 设置 Zim 性能优化选项
    zstyle ':zim:zmodule' use 'degit'
    
    # 禁用 Zim 版本检查以提高启动速度
    zstyle ':zim' disable-version-check yes
    
    # 自动下载和安装 Zim (如果不存在) - 静态配置
    if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
        echo "正在下载 Zim 框架管理器..."
        {{- if .features.enable_curl }}
        curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
            https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
        {{- else if .features.enable_wget }}
        mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
            https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
        {{- else }}
        echo "错误: 需要 curl 或 wget 来下载 Zim 框架管理器"
        return 1
        {{- end }}
    fi
    
    # 自动安装缺失模块并更新初始化脚本
    if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
        echo "正在初始化 Zim 模块..."
        source ${ZIM_HOME}/zimfw.zsh init -q
    fi
    
    # 初始化 Zim (如果已安装)
    if [[ -s ${ZIM_HOME}/init.zsh ]]; then
        source ${ZIM_HOME}/init.zsh
    else
        echo "警告: Zim 初始化脚本未找到，请运行 'zimfw install'"
        return 1
    fi
    
    # 避免补全冲突 - Zim 的 completion 模块会处理 compinit
    # 不在这里手动调用 compinit，让 Zim 管理补全系统
fi