# Chezmoi 安装脚本使用说明

## 概述

`install-chezmoi.sh` 是一个简化的 Chezmoi 初始化脚本，提供自动备份、安装和回滚功能。

## 功能特性

- ✅ 自动检测环境类型（桌面/服务器/WSL/容器）
- ✅ 创建现有配置文件的完整备份
- ✅ 安装和初始化 Chezmoi
- ✅ 错误处理和自动回滚机制
- ✅ 详细的日志记录
- ✅ 网络连接优化（超时和重试机制）
- ✅ 自动工具安装（现代化 CLI 工具）
- ✅ 版本管理器集成（fnm, pyenv）
- ✅ SSH 和 Git 配置自动化

## 使用方法

### 基本安装

```bash
# 使用默认仓库安装
bash install-chezmoi.sh

# 使用自定义仓库安装
CHEZMOI_REPO="https://github.com/yourusername/dotfiles.git" bash install-chezmoi.sh
```

### 回滚到备份

```bash
bash install-chezmoi.sh --rollback
```

### 清理失败的安装

```bash
bash install-chezmoi.sh --cleanup
```

### 查看帮助

```bash
bash install-chezmoi.sh --help
```

## 环境变量

- `CHEZMOI_REPO`: Git 仓库 URL（默认：`https://github.com/USERNAME/dotfiles.git`）

## 支持的环境

- **桌面环境**: 完整的配置安装
- **服务器环境**: 服务器优化的配置子集
- **WSL**: Windows 子系统 Linux 特定配置
- **容器**: 容器化环境的最小配置

## 备份和恢复

脚本会自动备份以下文件：
- `.zshrc`
- `.bashrc` 
- `.gitconfig`
- `.ssh/config`
- `.tmux.conf`
- `.shellrc`
- 整个 `.ssh` 目录

备份位置保存在 `~/.chezmoi-backup-location` 文件中。

## 故障排除

### 安装失败

如果安装失败，脚本会自动尝试回滚到备份状态。你也可以手动运行：

```bash
bash install-chezmoi.sh --rollback
```

### 查看日志

安装日志保存在当前目录的 `chezmoi-install.log`：

```bash
cat ./chezmoi-install.log
```

### 清理残留文件

如果需要完全清理 Chezmoi 安装：

```bash
bash install-chezmoi.sh --cleanup
```

## 依赖要求

- `curl`: 用于下载 Chezmoi
- `git`: 用于克隆配置仓库
- `bash`: 脚本运行环境

## 安全注意事项

- 脚本会在应用配置前显示变更预览
- 所有原始配置文件都会被备份
- 支持完整回滚到安装前状态
- 错误时自动清理和回滚