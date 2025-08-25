# 环境变量统一管理

## 概述

为了提高配置的可维护性和一致性，所有环境变量都统一在 `environment.sh` 中管理。这次重构将分散在各个配置文件中的环境变量集中管理，提升了性能和可维护性。

## 文件结构

### `environment.sh` - 环境变量中心
统一管理所有环境变量，包括：

#### 基础配置
- **路径变量**: `USER_HOME`, `CONFIG_DIR`, `LOCAL_BIN`
- **编辑器配置**: `EDITOR`, `VISUAL`
- **语言和区域**: `LANG`, `LC_ALL`, `LC_CTYPE`
- **Shell 历史**: `HISTSIZE`, `SAVEHIST`, `HISTFILE`, `HIST_STAMPS`

#### 平台特定配置
- **Linux**: XDG 目录规范 (`XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_CACHE_HOME`)
- **macOS**: Homebrew 优化配置
- **远程环境**: 终端优化 (`TERM`)

#### 开发工具环境变量
- **fnm (Node.js 版本管理)**:
  - `FNM_PATH` - fnm 安装路径
  - 静默初始化，避免启动时输出信息
  - 自动版本切换支持 (`--use-on-cd`)
  
- **fzf (模糊搜索工具)**:
  - `FZF_DEFAULT_OPTS` - 默认选项和主题配置
  - `FZF_DEFAULT_COMMAND` - 搜索命令 (支持 fd/rg/find)
  - `FZF_CTRL_T_OPTS` - 文件搜索预览选项
  - `FZF_ALT_C_OPTS` - 目录搜索预览选项

#### 安全和集成
- **1Password SSH Agent**: 跨平台 SSH 密钥管理
- **代理配置**: HTTP/HTTPS/SOCKS 代理支持
- **AI 工具**: OpenAI API 配置

### 其他配置文件的职责分离

#### `oh-my-zsh-config.sh` - Shell 框架配置
- Oh My Zsh 主题和插件管理
- 补全系统优化
- 性能调优设置
- **移除了**: 历史配置 (已移至 environment.sh)

#### `fzf-config.sh` - 功能和集成
- Shell 集成 (key-bindings, completion)
- 自定义函数 (`fcd`, `fe`, `fh`, `fkill`)
- Git 相关函数 (`fgb`, `fgl`)
- **移除了**: 所有环境变量 (已移至 environment.sh)

#### 其他配置文件
- `starship-config.sh` - 提示符配置
- `zoxide-config.sh` - 快速导航
- `aliases.sh` - 命令别名
- `basic-functions.sh` - 通用函数

## 性能优化

### fnm 启动优化
- 使用 `--log-level=quiet` 抑制输出信息
- 重定向 stderr 作为额外保险
- 解决了 "Using Node for alias lts-latest" 的启动消息

### 配置加载优化
- 环境变量优先加载，避免重复设置
- 条件配置减少不必要的检查
- 预编译 zsh 配置文件

## 重构前后对比

### 重构前问题
- fnm 配置分散在 `oh-my-zsh-config.sh`
- fzf 环境变量在 `fzf-config.sh` 中
- 历史配置重复定义
- 启动时有多余输出信息

### 重构后优势
1. **集中管理**: 所有环境变量在一个文件中
2. **避免重复**: 防止配置冲突和重复定义
3. **职责分离**: 每个文件专注于特定功能
4. **性能提升**: 减少重复设置和输出
5. **易于维护**: 清晰的配置结构

## 加载顺序

1. **`environment.sh`** - 环境变量和基础配置
2. **`oh-my-zsh-config.sh`** - Shell 框架配置
3. **功能特定配置文件** - fzf, starship, zoxide 等

## 最佳实践

### 添加新环境变量
- 所有新的环境变量都应添加到 `environment.sh`
- 使用条件模板语法 `{{- if .features.enable_xxx }}`
- 添加清晰的注释说明用途

### 配置维护
- 保持配置的幂等性 (可重复执行)
- 使用模板变量进行条件配置
- 定期检查和清理过时的配置

### 性能考虑
- 避免在环境变量设置中执行耗时操作
- 使用静默选项减少启动输出
- 合理使用条件判断避免不必要的检查

## 相关文档

- [fnm 使用指南](./fnm-usage.md) - Node.js 版本管理详细说明
- [1Password 集成](./1password-integration.md) - SSH Agent 配置
- [代理配置](./proxy-configuration.md) - 网络代理设置