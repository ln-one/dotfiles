# Homebrew 集成说明

## 概述

本项目通过 Chezmoi 集成了 Homebrew 包管理器，提供跨平台的工具安装和管理功能。

## 文件说明

### 1. `run_once_install-homebrew.sh.tmpl`
- **用途**: 自动安装 Homebrew
- **支持平台**: macOS 和 Linux
- **执行时机**: 仅在首次运行时执行
- **功能**:
  - 检测是否已安装 Homebrew
  - 根据平台安装相应版本
  - 配置环境变量和 PATH
  - 安装必要的构建依赖 (Linux)

### 2. `Brewfile.tmpl`
- **用途**: 定义要安装的包和应用程序
- **特性**:
  - 跨平台包管理
  - 条件安装 (基于平台和功能开关)
  - 现代化工具替代传统工具
  - 支持 macOS Cask 应用程序

### 3. `run_onchange_install-brew-packages.sh.tmpl`
- **用途**: 使用 Brewfile 安装和更新包
- **执行时机**: 当 Brewfile 发生变化时自动执行
- **功能**:
  - 更新 Homebrew
  - 安装 Brewfile 中定义的包
  - 验证关键工具安装
  - 清理不需要的包

## 使用方法

### 初始安装
```bash
# 应用 Chezmoi 配置 (会自动运行 Homebrew 安装)
chezmoi apply

# 或者手动运行 Homebrew 安装
chezmoi execute-template < run_once_install-homebrew.sh.tmpl | bash
```

### 管理包
```bash
# 查看将要安装的包
chezmoi execute-template < Brewfile.tmpl

# 安装/更新包
chezmoi apply  # 会自动运行包安装脚本

# 手动运行包安装
chezmoi execute-template < run_onchange_install-brew-packages.sh.tmpl | bash
```

### 自定义配置

在 `.chezmoi.toml.tmpl` 中修改功能开关:

```toml
[data.features]
  enable_node = true      # 启用 Node.js
  enable_python = true    # 启用 Python
  enable_docker = true    # 启用 Docker
  enable_ai_tools = true  # 启用 AI 开发工具
```

## 包分类

### 核心工具
- `git`, `curl`, `wget` - 基础开发工具
- `eza`, `bat`, `fd`, `ripgrep` - 现代化 CLI 工具
- `fzf` - 模糊搜索
- `jq` - JSON 处理

### 平台特定
- **macOS**: `mas`, `mackup`, Cask 应用程序
- **Linux**: `gcc`, `make`, 构建工具

### 可选功能
- **AI 工具**: `gh`, `glab`
- **代理工具**: `proxychains-ng`
- **开发语言**: `node`, `python`, `go`, `rust`

## 故障排除

### Homebrew 安装失败
```bash
# 检查网络连接
curl -I https://github.com

# 手动安装 Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 包安装失败
```bash
# 更新 Homebrew
brew update

# 检查 Brewfile 语法
brew bundle check --file=~/Brewfile

# 手动安装失败的包
brew install <package-name>
```

### Linux 权限问题
```bash
# 确保用户在正确的组中
sudo usermod -aG sudo $USER

# 重新登录或刷新组权限
newgrp sudo
```

## 维护

### 定期更新
```bash
# 更新 Homebrew 和所有包
brew update && brew upgrade

# 清理旧版本
brew cleanup

# 检查系统健康状态
brew doctor
```

### 添加新包
1. 编辑 `Brewfile.tmpl`
2. 添加新的 `brew "package-name"` 行
3. 运行 `chezmoi apply` 应用更改

### 移除包
1. 从 `Brewfile.tmpl` 中删除对应行
2. 手动卸载: `brew uninstall package-name`
3. 清理依赖: `brew autoremove`