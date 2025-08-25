# Design Document

## Overview

本设计实现 chezmoi 配置的四层分层架构，通过智能环境检测和配置优先级管理，实现自适应的配置系统。设计目标是在保持现有功能完整性的基础上，提供更灵活的环境适配和用户定制能力。

## Architecture

### 配置分层架构

```
配置加载顺序 (优先级从低到高):
┌─────────────────────────────────────┐
│ 1. 核心配置层 (Core Layer)           │
│   - 基础环境变量                     │
│   - 通用别名和函数                   │
│   - 跨平台工具配置                   │
└─────────────────────────────────────┘
           ↓ 覆盖
┌─────────────────────────────────────┐
│ 2. 平台配置层 (Platform Layer)       │
│   - Linux 特定配置                   │
│   - macOS 特定配置                   │
│   - 平台特定工具和路径               │
└─────────────────────────────────────┘
           ↓ 覆盖
┌─────────────────────────────────────┐
│ 3. 环境配置层 (Environment Layer)    │
│   - Desktop: 完整功能配置            │
│   - Remote: 轻量化配置               │
│   - Container: 最小化配置            │
│   - WSL: 混合优化配置                │
└─────────────────────────────────────┘
           ↓ 覆盖
┌─────────────────────────────────────┐
│ 4. 用户配置层 (User Layer)           │
│   - 个人偏好设置                     │
│   - 本地配置覆盖                     │
│   - 敏感信息配置                     │
└─────────────────────────────────────┘
```

### 环境检测增强

```bash
环境检测决策树:
┌─ 容器检测 ─┐
│ /.dockerenv │ → container
│ /run/.containerenv │
└─────────────┘
       ↓ 否
┌─ WSL 检测 ─┐
│ $WSL_DISTRO_NAME │ → wsl
│ /proc/version (microsoft) │
└─────────────┘
       ↓ 否
┌─ SSH 检测 ─┐
│ $SSH_CONNECTION │ → remote
│ $SSH_CLIENT │
└─────────────┘
       ↓ 否
┌─ 桌面检测 ─┐
│ $DISPLAY │ → desktop
│ $WAYLAND_DISPLAY │
│ GUI 进程检测 │
└─────────────┘
```

## Components and Interfaces

### 1. 配置管理器 (Configuration Manager)

**文件**: `.chezmoitemplates/config-manager.sh`

**职责**:
- 环境检测和分类
- 配置层次加载
- 配置合并和优先级处理
- 配置验证和错误处理

**接口**:
```bash
# 环境检测
detect_environment() → "desktop|remote|container|wsl"
detect_platform() → "linux|darwin"
detect_architecture() → "amd64|arm64"

# 配置加载
load_core_config()
load_platform_config(platform)
load_environment_config(environment)
load_user_config()

# 配置验证
validate_config() → boolean
diagnose_config() → report
```

### 文件重新组织策略

基于现有文件结构，通过移动和重新组织实现分层架构：

**当前文件结构**:
```
根目录:
├── run_once_install-*.sh.tmpl        # → 保持在根目录 (chezmoi 要求)
├── run_once_setup-*.sh.tmpl          # → 保持在根目录 (chezmoi 要求)
├── run_onchange_*.sh.tmpl            # → 保持在根目录 (chezmoi 要求)
└── dot_*.tmpl                        # 保持不变

.chezmoitemplates/
├── environment.sh           # → 移动到 core/
├── shell-common.sh          # → 重构为分层加载器
├── aliases.sh              # → 移动到 core/
├── basic-functions.sh       # → 移动到 core/
├── fzf-config.sh           # → 移动到 core/
├── zoxide-config.sh        # → 移动到 core/
├── starship-config.sh       # → 移动到 core/
├── oh-my-zsh-config.sh      # → 移动到 core/
├── zsh-performance-tweaks.sh # → 移动到 core/
├── proxy-functions.sh       # → 移动到 platforms/linux/
└── theme-functions.sh       # → 移动到 platforms/linux/
```

**目标文件结构**:
```
根目录:
├── run_once_install-*.sh.tmpl        # 保持在根目录 (chezmoi 执行要求)
├── run_once_setup-*.sh.tmpl          # 保持在根目录 (chezmoi 执行要求)
├── run_onchange_*.sh.tmpl            # 保持在根目录 (chezmoi 执行要求)
└── dot_*.tmpl                        # 配置文件模板 (保持不变)

.chezmoitemplates/
├── core/                  # 核心配置层 (现有文件移动)
│   ├── environment.sh     # 环境变量和基础配置
│   ├── aliases.sh        # 通用别名
│   ├── basic-functions.sh # 基础函数
│   ├── fzf-config.sh     # fzf 模糊搜索配置
│   ├── zoxide-config.sh  # zoxide 智能跳转配置
│   ├── starship-config.sh # starship 提示符配置
│   ├── oh-my-zsh-config.sh # oh-my-zsh 配置
│   └── zsh-performance-tweaks.sh # zsh 性能优化
├── platforms/            # 平台配置层 (现有文件移动)
│   ├── linux/            # Linux 特定功能
│   │   ├── proxy-functions.sh    # 从根目录移动
│   │   └── theme-functions.sh    # 从根目录移动
│   └── darwin/           # macOS 特定功能 (新建)
│       └── macos-specific.sh     # 提取 macOS 特定配置
├── environments/         # 环境配置层 (新建，基于现有条件)
│   ├── desktop.sh       # 提取桌面环境特定配置
│   ├── remote.sh        # 提取远程环境特定配置
│   └── container.sh     # 提取容器环境特定配置
├── local/               # 用户本地配置层 (待实现)
│   ├── user-overrides.sh # 用户个人配置覆盖 (待创建)
│   └── local-config.sh  # 本地环境特定配置 (待创建)
└── shell-common.sh      # 重构为分层加载器
```

### 重构策略

#### 1. 保持现有文件内容和位置不变
- 安装脚本保持在根目录 (chezmoi 执行要求)
- 仅重新组织 `.chezmoitemplates/` 目录下的配置文件
- 只修改 `includeTemplate` 路径引用
- 不重写现有功能实现

#### 2. 更新加载器 (shell-common.sh)
```bash
# 修改现有的 shell-common.sh 为分层加载器
# 保持现有的 includeTemplate 调用，只更新路径

# 核心配置层 (所有环境)
{{ includeTemplate "core/environment.sh" . }}
{{ includeTemplate "core/aliases.sh" . }}
{{ includeTemplate "core/basic-functions.sh" . }}
{{ includeTemplate "core/starship-config.sh" . }}
{{ includeTemplate "core/oh-my-zsh-config.sh" . }}
{{ includeTemplate "core/zsh-performance-tweaks.sh" . }}
{{ includeTemplate "core/fzf-config.sh" . }}
{{ includeTemplate "core/zoxide-config.sh" . }}

# 平台配置层
{{- if eq .chezmoi.os "linux" }}
{{ includeTemplate "platforms/linux/proxy-functions.sh" . }}
{{ includeTemplate "platforms/linux/theme-functions.sh" . }}
{{- else if eq .chezmoi.os "darwin" }}
{{ includeTemplate "platforms/darwin/macos-specific.sh" . }}
{{- end }}

# 环境配置层
{{- if eq .environment "desktop" }}
{{ includeTemplate "environments/desktop.sh" . }}
{{- else if eq .environment "remote" }}
{{ includeTemplate "environments/remote.sh" . }}
{{- else if eq .environment "container" }}
{{ includeTemplate "environments/container.sh" . }}
{{- end }}

# 用户本地配置层 (最高优先级)
{{- if stat (joinPath .chezmoi.sourceDir ".chezmoitemplates/local/user-overrides.sh") }}
{{ includeTemplate "local/user-overrides.sh" . }}
{{- end }}
{{- if stat (joinPath .chezmoi.homeDir ".chezmoi.local.sh") }}
{{ include (joinPath .chezmoi.homeDir ".chezmoi.local.sh") }}
{{- end }}
```

### 3. 工具管理器 (Tool Manager)

**文件**: `.chezmoitemplates/tool-manager.sh`

**职责**:
- 环境感知的工具选择
- 工具可用性检测
- 轻量化工具映射
- 工具安装策略

**平台特定功能分布**:
```bash
# Linux 独有功能
Linux Only:
  - 代理管理 (proxyon/proxyoff/proxystatus/proxyai)
  - WhiteSur 主题管理 (dark/light/themestatus) 
  - APT 包管理器集成 (bat→batcat, fd→fdfind)
  - GNOME gsettings 配置

# macOS 独有功能  
macOS Only:
  - Homebrew Cask 应用管理 (GUI 应用)
  - Mac App Store CLI (mas)
  - macOS 应用配置备份 (mackup)
  - macOS 特定路径配置 (/opt/homebrew)

# 跨平台但实现不同
Cross-Platform (Different Implementation):
  - 包管理策略 (Linux: apt→brew, macOS: brew only)
  - SSH Agent 路径 (不同套接字位置)
  - 颜色配置 (LS_COLORS vs LSCOLORS)
  - Shell 补全路径
```

**工具映射策略**:
```bash
# 环境感知工具选择
Desktop Environment:
  editor: nvim → code → vim
  file_manager: eza → exa → ls
  system_monitor: htop → top
  # Linux 桌面额外功能: 代理管理, 主题切换

Remote Environment:
  editor: vim → nano
  file_manager: ls (colored)
  system_monitor: htop → top
  # 跳过: GUI 相关功能 (代理 GUI, 主题管理)
  
Container Environment:
  editor: vi
  file_manager: ls
  system_monitor: top
  # 最小化: 仅核心工具
```

### 4. 配置验证器 (Configuration Validator)

**文件**: `.chezmoitemplates/config-validator.sh`

**职责**:
- 配置语法验证
- 依赖检查
- 性能影响评估
- 安全性检查

## Data Models

### 环境配置数据结构

```toml
# .chezmoi.toml.tmpl 增强版
[data.detection]
  platform = "{{ .chezmoi.os }}"
  architecture = "{{ .chezmoi.arch }}"
  environment = "{{ template "detect-environment" . }}"
  
[data.layers]
  core_enabled = true
  platform_enabled = true
  environment_enabled = true
  user_enabled = true

[data.environment_configs]
  [data.environment_configs.desktop]
    gui_tools = true
    development_tools = true
    # Linux 独有功能
    theme_management = "{{ if eq .chezmoi.os \"linux\" }}true{{ else }}false{{ end }}"
    proxy_management = "{{ if eq .chezmoi.os \"linux\" }}true{{ else }}false{{ end }}"
    # macOS 独有功能  
    cask_apps = "{{ if eq .chezmoi.os \"darwin\" }}true{{ else }}false{{ end }}"
    
  [data.environment_configs.remote]
    gui_tools = false
    development_tools = "lightweight"
    theme_management = false  # 所有远程环境都不需要
    proxy_management = "cli_only"  # 仅命令行代理，无 GUI
    cask_apps = false
    network_optimization = true
    
  [data.environment_configs.container]
    gui_tools = false
    development_tools = "minimal"
    theme_management = false
    proxy_management = false
    cask_apps = false
    startup_optimization = true
    
  [data.environment_configs.wsl]
    gui_tools = "conditional"
    development_tools = true
    theme_management = false  # WSL 不需要 Linux 主题管理
    proxy_management = "windows_integration"  # 使用 Windows 代理
    cask_apps = false
    windows_integration = true

[data.tool_preferences]
  [data.tool_preferences.desktop]
    editor = ["nvim", "code", "vim"]
    file_browser = ["eza", "exa", "ls"]
    system_monitor = ["htop", "top"]
    
  [data.tool_preferences.remote]
    editor = ["vim", "nano", "vi"]
    file_browser = ["ls"]
    system_monitor = ["htop", "top"]
    
  [data.tool_preferences.container]
    editor = ["vi", "nano"]
    file_browser = ["ls"]
    system_monitor = ["top"]
```

### 用户配置覆盖模型

```toml
# ~/.chezmoi.local.toml (用户配置文件)
[user_overrides]
  [user_overrides.personal]
    git_user_name = "Your Name"
    git_user_email = "your.email@example.com"
    
  [user_overrides.proxy]
    enabled = true
    host = "127.0.0.1"
    http_port = 7890
    socks_port = 7891
    
  [user_overrides.tools]
    preferred_editor = "code"
    preferred_shell = "zsh"
    
  [user_overrides.features]
    enable_ai_tools = true
    enable_docker = false
```

## Error Handling

### 配置加载错误处理

```bash
# 错误处理策略
load_config_with_fallback() {
    local config_file="$1"
    local fallback_config="$2"
    
    if [[ -f "$config_file" ]]; then
        if validate_config_syntax "$config_file"; then
            source "$config_file"
        else
            log_error "配置文件语法错误: $config_file"
            log_info "使用回退配置: $fallback_config"
            source "$fallback_config"
        fi
    else
        log_warn "配置文件不存在: $config_file"
        if [[ -f "$fallback_config" ]]; then
            source "$fallback_config"
        fi
    fi
}
```

### 环境检测失败处理

```bash
# 环境检测失败时的回退机制
detect_environment_with_fallback() {
    local detected_env
    
    # 尝试自动检测
    detected_env=$(auto_detect_environment)
    
    # 检测失败时的处理
    if [[ -z "$detected_env" ]]; then
        # 检查用户手动指定
        if [[ -n "${CHEZMOI_ENVIRONMENT:-}" ]]; then
            detected_env="$CHEZMOI_ENVIRONMENT"
        else
            # 使用安全的默认值
            detected_env="desktop"
            log_warn "环境检测失败，使用默认环境: $detected_env"
        fi
    fi
    
    echo "$detected_env"
}
```

## Testing Strategy

### 1. 单元测试

**测试文件**: `tests/unit/`
- `test-environment-detection.sh` - 环境检测逻辑测试
- `test-config-loading.sh` - 配置加载和合并测试
- `test-tool-selection.sh` - 工具选择逻辑测试

### 2. 集成测试

**测试文件**: `tests/integration/`
- `test-layered-config.sh` - 完整配置分层测试
- `test-cross-platform.sh` - 跨平台兼容性测试
- `test-environment-switching.sh` - 环境切换测试

### 3. 性能测试

**测试文件**: `tests/performance/`
- `test-shell-startup-time.sh` - Shell 启动时间测试
- `test-config-loading-performance.sh` - 配置加载性能测试

### 4. 用户验收测试

**测试场景**:
1. **本地开发环境** - 完整功能验证
2. **VPS 远程环境** - 轻量化配置验证
3. **容器环境** - 最小化配置验证
4. **macOS 迁移** - 跨平台迁移验证

## 当前实现状态

### 已完成的组件

1. **分层目录结构** ✅
   - 创建了完整的四层配置目录结构
   - `core/`, `platforms/linux/`, `platforms/darwin/`, `environments/`

2. **核心配置层** ✅
   - 所有通用配置文件已移动到 `core/` 目录
   - 包含环境变量、别名、基础函数、工具配置等

3. **平台配置层** ✅
   - Linux 特定功能 (代理管理、主题管理) 移动到 `platforms/linux/`
   - macOS 特定配置创建在 `platforms/darwin/`

4. **环境配置层** ✅
   - 桌面环境配置 (`environments/desktop.sh`)
   - 远程环境轻量化配置 (`environments/remote.sh`)
   - 容器环境最小化配置 (`environments/container.sh`)
   - WSL 环境混合配置 (`environments/wsl.sh`)

5. **增强环境检测** ✅
   - 实现了容器、WSL、SSH、桌面环境的智能检测
   - 包含检测失败的回退机制

### 待实现的组件

1. **分层加载器重构** (下一步)
   - 重构 `shell-common.sh` 为分层配置加载器
   - 更新所有 `includeTemplate` 路径引用

2. **用户配置层** (待实现)
   - 创建 `local/` 目录和用户配置模板
   - 实现外部配置文件支持

3. **配置验证和诊断** (待实现)
   - 配置语法验证器
   - 配置诊断和调试工具

## Implementation Plan

### Phase 1: 文件重新组织 (重组配置文件) ✅ 已完成
1. 创建目录结构:
   - `.chezmoitemplates/core/`, `platforms/linux/`, `platforms/darwin/`, `environments/`, `local/`
2. 保持安装脚本在根目录 (chezmoi 执行要求)
3. 移动 `.chezmoitemplates/` 下的配置文件到对应的分层目录
4. 更新 `shell-common.sh` 中的 `includeTemplate` 路径引用
5. 测试现有功能是否正常工作

### Phase 2: 平台特定配置提取
1. 从现有文件中提取 macOS 特定配置到 `platforms/darwin/`
2. 从 `Brewfile.tmpl` 提取平台特定包配置
3. 从安装脚本中提取平台特定逻辑
4. 验证跨平台功能正常

### Phase 3: 环境配置分离
1. 创建环境特定配置文件 (基于现有条件判断)
2. 提取轻量化配置逻辑到 `environments/remote.sh`
3. 提取容器优化配置到 `environments/container.sh`
4. 测试不同环境下的配置加载

### Phase 4: 用户本地配置层支持
1. 创建 `local/` 目录和用户配置模板
2. 添加 `~/.chezmoi.local.sh` 外部配置文件支持
3. 实现配置优先级处理 (local 层最高优先级)
4. 添加配置验证和错误处理
5. 创建配置诊断工具