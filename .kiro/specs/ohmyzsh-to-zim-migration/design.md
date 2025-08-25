# Design Document

## Overview

本设计文档描述了如何在现有的 Chezmoi 分层配置系统中，将 Oh My Zsh 框架替换为 Zim 框架，同时保持最小化修改原则。设计重点是利用现有的完善模块化架构，仅替换必要的 Zsh 框架相关组件。

### 核心设计原则

1. **最小化修改**：仅修改与 Oh My Zsh 直接相关的配置文件
2. **保持架构**：完全保留现有的四层配置架构
3. **功能对等**：确保 Zim 提供与 Oh My Zsh 相同的功能
4. **向后兼容**：通过特性标志支持两种框架的切换

## Architecture

### 现有架构保持不变

```
.chezmoitemplates/
├── core/
│   ├── environment.sh          # 保持不变
│   ├── aliases.sh              # 保持不变  
│   ├── basic-functions.sh      # 保持不变
│   ├── fzf-config.sh          # 保持不变
│   ├── starship-config.sh     # 保持不变
│   ├── zoxide-config.sh       # 保持不变
│   ├── zsh-performance-tweaks.sh # 保持不变
│   └── oh-my-zsh-config.sh    # 替换为 zim-config.sh
├── platforms/                  # 保持不变
├── environments/               # 保持不变
├── local/                      # 保持不变
└── shell-common.sh            # 最小修改（仅更新模板引用）
```

### Zim 框架集成设计

#### 1. Zim 配置文件结构

Zim 使用以下配置文件：
- `~/.zimrc` - 模块配置文件（通过 `dot_zimrc.tmpl` 生成）
- `~/.zshrc` - 主配置文件（已存在，需要修改 Zim 初始化部分）
- `${ZIM_HOME}/init.zsh` - Zim 生成的静态初始化脚本

#### 2. 模块映射关系

| Oh My Zsh 插件 | Zim 模块 | 说明 |
|---------------|----------|------|
| git | utility | Git 别名和函数（包含在 utility 模块中） |
| zsh-autosuggestions | zsh-users/zsh-autosuggestions | 自动建议 |
| zsh-syntax-highlighting | zsh-users/zsh-syntax-highlighting | 语法高亮 |
| fzf | fzf | 模糊搜索集成（需要单独安装 fzf） |
| python | 无直接对应 | 通过现有的环境配置处理 |

#### 3. Zim 核心模块

| 模块名 | 功能 | 对应 Oh My Zsh 功能 |
|--------|------|-------------------|
| environment | 设置合理的 Zsh 内置环境选项 | Oh My Zsh 默认设置 |
| input | 正确的按键绑定 | Oh My Zsh 按键配置 |
| utility | 实用别名和函数，为 ls、grep、less 添加颜色 | Oh My Zsh git 插件 + 其他工具 |
| completion | 智能和广泛的 tab 补全 | Oh My Zsh 补全系统 |

## Components and Interfaces

### 1. Zim 配置模块 (zim-config.sh)

替换现有的 `oh-my-zsh-config.sh`，提供相同的功能接口：

```bash
# 新文件：.chezmoitemplates/core/zim-config.sh
# 功能：初始化 Zim 框架
# 关键组件：
# - 设置 ZIM_HOME 环境变量
# - 自动下载 zimfw.zsh（如果缺失）
# - 自动安装/更新模块和初始化脚本
# - 加载 ${ZIM_HOME}/init.zsh
```

### 2. Zimrc 配置文件

```bash
# 新文件：dot_zimrc.tmpl  
# 功能：定义 Zim 模块配置
# 内容：zmodule 调用来定义要初始化的模块
# 特点：不在 Zsh 启动时被 source，仅用于配置 zimfw 插件管理器
```

### 3. Zim 安装脚本

```bash
# 新文件：run_once_install-zim.sh.tmpl
# 功能：确保 Zim 框架正确安装
# 内容：检查并安装 Zim，设置必要的目录结构
```

### 3. 特性标志扩展

在现有的 `.chezmoi.toml.tmpl` 中修改特性标志：

```toml
[data.features]
  enable_oh_my_zsh = false    # 禁用 Oh My Zsh
  enable_zim = true           # 启用 Zim
  # 保持现有的其他特性标志
  enable_starship = true      # 继续使用 Starship（Zim 兼容）
  enable_fzf = true          # 继续使用 fzf（Zim 有对应模块）
  enable_zoxide = true       # 继续使用 zoxide（独立于框架）
```

### 4. Zim 配置文件路径

```toml
[data.zim]
  config_file = "${ZDOTDIR:-${HOME}}/.zimrc"  # 默认配置文件位置
  home_dir = "${ZDOTDIR:-${HOME}}/.zim"       # Zim 安装目录
```

### 4. Shell 加载器修改

在 `shell-common.sh` 中的最小修改：

```bash
# 原来：
{{ includeTemplate "core/oh-my-zsh-config.sh" . }}

# 修改为：
{{- if .features.enable_oh_my_zsh }}
{{ includeTemplate "core/oh-my-zsh-config.sh" . }}
{{- else if .features.enable_zim }}
{{ includeTemplate "core/zim-config.sh" . }}
{{- end }}
```

## Data Models

### 1. Zim 模块配置模型

```bash
# ~/.zimrc 文件内容结构（通过 dot_zimrc.tmpl 生成）

# 核心模块
zmodule environment
zmodule input  
zmodule utility

{{- if not .features.enable_starship }}
# 如果不使用 Starship，使用 Zim 内置提示符
zmodule duration-info
zmodule git-info
zmodule asciiship
{{- end }}

{{- if .features.enable_fzf }}
# fzf 集成（需要 fzf 已安装）
zmodule fzf
{{- end }}

# 补全系统
zmodule zsh-users/zsh-completions --fpath src
zmodule completion

# 必须最后加载的模块
zmodule zsh-users/zsh-syntax-highlighting
zmodule zsh-users/zsh-autosuggestions
```

### 2. 环境检测模型

保持现有的环境检测逻辑：

```bash
# 继续使用现有的环境变量
{{- if eq .environment "remote" }}
# 远程环境配置
{{- else if eq .environment "desktop" }}
# 桌面环境配置
{{- end }}
```

## Error Handling

### 1. Zim 框架检测和自动安装

```bash
# 在 zim-config.sh 中实现
# 设置 ZIM_HOME
export ZIM_HOME="${ZDOTDIR:-${HOME}}/.zim"

# 自动下载 zimfw 插件管理器（如果缺失）
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
            https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
    elif command -v wget >/dev/null 2>&1; then
        mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
            https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
    else
        echo "Error: Neither curl nor wget available for Zim installation"
        return 1
    fi
fi
```

### 2. 自动模块管理

```bash
# 自动安装缺失模块并更新初始化脚本
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
    source ${ZIM_HOME}/zimfw.zsh init
fi

# 加载初始化脚本
if [[ -f "${ZIM_HOME}/init.zsh" ]]; then
    source "${ZIM_HOME}/init.zsh"
else
    echo "Warning: Zim initialization script not found"
    return 1
fi
```

### 3. 配置验证

```bash
# 验证关键功能是否正常
_verify_zim_config() {
    local errors=0
    
    # 检查 Git 别名
    if ! alias | grep -q "git"; then
        echo "Warning: Git aliases not loaded"
        ((errors++))
    fi
    
    # 检查自动建议
    if ! zle -l | grep -q "autosuggest"; then
        echo "Warning: Autosuggestions not loaded"
        ((errors++))
    fi
    
    return $errors
}
```

## Testing Strategy

### 1. 功能对等测试

```bash
# 测试脚本：验证 Zim 配置与 Oh My Zsh 功能对等
test_git_aliases() {
    # 验证 Git 别名是否存在
    alias | grep -E "^(ga|gst|gco|gp)="
}

test_autosuggestions() {
    # 验证自动建议功能
    zle -l | grep autosuggest
}

test_syntax_highlighting() {
    # 验证语法高亮功能
    zle -l | grep syntax-highlighting
}
```

### 2. 环境兼容性测试

```bash
# 测试不同环境下的配置加载
test_remote_environment() {
    CHEZMOI_ENVIRONMENT="remote" source ~/.zshrc
    # 验证远程环境特定配置
}

test_desktop_environment() {
    CHEZMOI_ENVIRONMENT="desktop" source ~/.zshrc
    # 验证桌面环境特定配置
}
```

### 3. 性能基准测试

```bash
# 测试 shell 启动时间
test_startup_time() {
    time zsh -i -c exit
}
```

## Implementation Phases

### Phase 1: 准备阶段
- 修改 `.chezmoi.toml.tmpl` 中的特性标志
- 创建 `dot_zimrc.tmpl` 配置文件
- 创建 `run_once_install-zim.sh.tmpl` 安装脚本

### Phase 2: 核心替换
- 创建 `.chezmoitemplates/core/zim-config.sh` 模块
- 修改 `.chezmoitemplates/shell-common.sh` 加载逻辑
- 确保与现有模块的兼容性

### Phase 3: 功能验证和测试
- 测试 Zim 模块功能（git、autosuggestions、syntax-highlighting）
- 验证与 Starship、fzf、zoxide 的集成
- 测试多环境兼容性（desktop、remote、container）

### Phase 4: 迁移完成
- 验证所有功能正常工作
- 可选：禁用 Oh My Zsh 相关配置
- 更新相关文档和注释

## Migration Strategy

### 1. 渐进式迁移

```bash
# 通过特性标志控制迁移
[data.features]
  enable_oh_my_zsh = false  # 第一步：禁用 Oh My Zsh
  enable_zim = true         # 第二步：启用 Zim
```

### 2. 回滚机制

```bash
# 如果需要回滚到 Oh My Zsh
[data.features]
  enable_oh_my_zsh = true   # 重新启用 Oh My Zsh
  enable_zim = false        # 禁用 Zim
```

### 3. 并行支持（开发阶段）

```bash
# 开发期间可以同时支持两种框架
{{- if .features.enable_oh_my_zsh }}
{{ includeTemplate "core/oh-my-zsh-config.sh" . }}
{{- end }}

{{- if .features.enable_zim }}
{{ includeTemplate "core/zim-config.sh" . }}
{{- end }}
```

## Security Considerations

### 1. 模块来源验证
- 使用 Zim 官方模块
- 避免第三方不可信模块

### 2. 配置文件权限
- 保持现有的文件权限设置
- 确保配置文件不可被其他用户修改

### 3. 环境变量安全
- 继续使用现有的 1Password 集成
- 保持密钥管理机制不变

## Compatibility Matrix

| 环境 | Oh My Zsh | Zim | 兼容性 |
|------|-----------|-----|--------|
| macOS Desktop | ✓ | ✓ | 完全兼容 |
| Linux Desktop | ✓ | ✓ | 完全兼容 |
| SSH Remote | ✓ | ✓ | 完全兼容 |
| WSL | ✓ | ✓ | 完全兼容 |
| Container | ✓ | ✓ | 完全兼容 |

所有环境都将保持相同的功能和配置选项。