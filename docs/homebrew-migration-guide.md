# Homebrew 统一包管理迁移指南

本指南帮助用户从旧的多包管理器系统迁移到新的 Homebrew 统一包管理系统。

## 📋 迁移概述

### 变更内容
- **移除**: 所有系统包管理器 (apt, yum, dnf) 相关的安装脚本和逻辑
- **统一**: 所有工具通过 Homebrew 安装和管理
- **简化**: 从 10+ 个安装脚本简化为 3 个核心脚本
- **标准化**: 使用 Homebrew 标准包名和路径

### 迁移优势
- ✅ **跨平台一致性**: macOS 和 Linux 使用相同工具版本
- ✅ **简化维护**: 单一包管理器，统一更新流程
- ✅ **现代工具**: 优先使用现代化 CLI 工具
- ✅ **版本控制**: 避免系统包版本差异问题

## 🚀 迁移步骤

### 步骤 1: 备份现有配置

```bash
# 备份当前配置
cp ~/.zshrc ~/.zshrc.backup
cp ~/.bashrc ~/.bashrc.backup
cp ~/.gitconfig ~/.gitconfig.backup

# 备份 chezmoi 状态
chezmoi dump > ~/chezmoi-backup.json
```

### 步骤 2: 安装 Homebrew (如果尚未安装)

```bash
# 安装 Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 设置环境变量
# macOS Apple Silicon
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile

# macOS Intel
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile

# Linux
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile

# 立即生效
eval "$(brew shellenv)"
```

### 步骤 3: 更新 dotfiles 配置

```bash
# 拉取最新配置
cd ~/.local/share/chezmoi
git pull origin main

# 应用新配置
chezmoi apply --force
```

### 步骤 4: 安装工具 (通过 Homebrew)

```bash
# 安装所有工具
brew bundle install

# 验证安装
brew bundle check
```

### 步骤 5: 重新加载 Shell

```bash
# 重新加载配置
source ~/.zshrc
# 或
source ~/.bashrc
```

## 🧹 清理旧系统

### 清理系统包 (可选)

如果你想完全移除通过系统包管理器安装的工具，可以执行以下清理步骤：

#### Ubuntu/Debian 系统清理

```bash
# 移除可能冲突的系统包
sudo apt remove --purge \
  batcat \
  fd-find \
  ripgrep \
  exa \
  fzf \
  zoxide

# 清理不再需要的依赖
sudo apt autoremove

# 注意: 保留 1password-cli，它必须通过 apt 管理
# 不要移除 1password-cli，因为 Homebrew 不支持它
```

#### CentOS/RHEL/Fedora 系统清理

```bash
# 移除可能冲突的系统包
sudo dnf remove \
  bat \
  fd-find \
  ripgrep \
  exa \
  fzf

# 或使用 yum (旧版本)
sudo yum remove \
  bat \
  fd-find \
  ripgrep \
  exa \
  fzf
```

### 清理旧的安装脚本

以下脚本已被移除，如果你有本地修改，请备份后删除：

```bash
# 已移除的脚本文件 (如果存在)
rm -f ~/.local/share/chezmoi/run_once_install-community-tools.sh.tmpl
rm -f ~/.local/share/chezmoi/run_once_install-starship.sh.tmpl
rm -f ~/.local/share/chezmoi/run_once_install-fzf.sh.tmpl
rm -f ~/.local/share/chezmoi/run_once_install-zoxide.sh.tmpl
rm -f ~/.local/share/chezmoi/run_once_install-nerd-fonts.sh.tmpl
rm -f ~/.local/share/chezmoi/run_once_install-version-managers.sh.tmpl
rm -f ~/.local/share/chezmoi/run_once_install-tools.sh.tmpl
rm -f ~/.local/share/chezmoi/run_once_install-evalcache.sh.tmpl
rm -f ~/.local/share/chezmoi/run_once_install-fnm.sh.tmpl
rm -f ~/.local/share/chezmoi/run_once_install-zim.sh.tmpl
```

## 🔧 工具映射对照表

### 包名映射

| 旧系统包名 | Homebrew 包名 | 说明 |
|-----------|---------------|------|
| `batcat` (Ubuntu) | `bat` | 语法高亮文件查看器 |
| `fd-find` (Ubuntu) | `fd` | 快速文件搜索工具 |
| `ripgrep` | `ripgrep` | 高性能文本搜索 |
| `exa` | `eza` | 现代化 ls 替代品 |
| `fzf` | `fzf` | 模糊搜索工具 |
| `zoxide` | `zoxide` | 智能目录跳转 |

### 路径映射

| 旧路径 | 新路径 (Homebrew) | 平台 |
|--------|------------------|------|
| `/usr/bin/batcat` | `$(brew --prefix)/bin/bat` | Linux |
| `/usr/bin/fdfind` | `$(brew --prefix)/bin/fd` | Linux |
| `/usr/local/bin/*` | `$(brew --prefix)/bin/*` | macOS |
| `/opt/homebrew/bin/*` | `$(brew --prefix)/bin/*` | macOS (Apple Silicon) |

### 命令别名更新

```bash
# 旧别名逻辑 (已移除)
if command -v batcat >/dev/null 2>&1; then
    alias bat='batcat'
fi

# 新统一别名 (自动设置)
alias bat='bat'  # 直接使用 Homebrew 版本
alias fd='fd'    # 直接使用 Homebrew 版本
```

## 🔍 验证迁移结果

### 检查工具安装

```bash
# 验证核心工具
which bat fd rg eza fzf zoxide
# 应该都指向 Homebrew 路径

# 检查版本
bat --version
fd --version
rg --version
eza --version
fzf --version
zoxide --version
```

### 检查路径配置

```bash
# 检查 Homebrew 路径
echo $HOMEBREW_PREFIX
# macOS Apple Silicon: /opt/homebrew
# macOS Intel: /usr/local  
# Linux: /home/linuxbrew/.linuxbrew

# 检查 PATH 配置
echo $PATH | grep -o "$(brew --prefix)/bin"
# 应该包含 Homebrew bin 路径
```

### 测试功能

```bash
# 测试现代工具
ls          # 应该显示图标 (eza)
bat README.md  # 应该有语法高亮
fd "*.md"   # 应该快速搜索文件
rg "TODO"   # 应该快速搜索文本
z ~         # 应该智能跳转到 home
```

## 🚨 故障排除

### 问题 1: 工具未找到

**症状**: `command not found: bat/fd/rg`

**原因**: Homebrew 路径未正确设置

**解决方案**:
```bash
# 重新设置 Homebrew 环境
eval "$(brew shellenv)"

# 永久设置 (添加到 shell 配置文件)
echo 'eval "$(brew shellenv)"' >> ~/.zshrc
source ~/.zshrc
```

### 问题 2: 别名不生效

**症状**: `ls` 仍显示普通列表，没有图标

**原因**: 别名被其他配置覆盖

**解决方案**:
```bash
# 重新应用配置
chezmoi apply --force
source ~/.zshrc

# 手动设置别名 (临时)
alias ls='eza --color=auto --icons'
```

### 问题 3: 版本冲突

**症状**: 工具版本不是最新的 Homebrew 版本

**原因**: 系统包仍在 PATH 中优先

**解决方案**:
```bash
# 检查 PATH 顺序
echo $PATH

# 确保 Homebrew 路径在前面
export PATH="$(brew --prefix)/bin:$PATH"

# 或移除冲突的系统包 (见清理章节)
```

### 问题 4: Brewfile 安装失败

**症状**: `brew bundle install` 报错

**原因**: 网络问题或包不可用

**解决方案**:
```bash
# 检查网络连接
brew update

# 逐个安装包以定位问题
brew install bat fd ripgrep eza fzf zoxide

# 跳过失败的包
brew bundle install --no-lock
```

### 问题 5: 权限问题

**症状**: Homebrew 安装权限被拒绝

**原因**: 目录权限不正确

**解决方案**:
```bash
# 修复 Homebrew 权限 (macOS)
sudo chown -R $(whoami) $(brew --prefix)/*

# Linux 用户权限
sudo chown -R $USER /home/linuxbrew/.linuxbrew
```

## 📞 获取帮助

如果遇到迁移问题，可以：

1. **检查日志**: `brew doctor` 诊断 Homebrew 问题
2. **查看文档**: 参考 [Homebrew 官方文档](https://docs.brew.sh/)
3. **运行测试**: 使用项目测试脚本验证配置
4. **回滚配置**: 使用备份文件恢复旧配置

### 紧急回滚

如果迁移出现严重问题，可以快速回滚：

```bash
# 恢复备份配置
cp ~/.zshrc.backup ~/.zshrc
cp ~/.bashrc.backup ~/.bashrc
cp ~/.gitconfig.backup ~/.gitconfig

# 重新加载
source ~/.zshrc
```

## ⚠️ 例外情况

虽然我们采用 Homebrew 统一包管理策略，但有少数工具由于技术限制无法完全统一：

### 1Password CLI

**Linux 系统**:
- 必须通过官方 APT 仓库安装
- 原因: 1Password 官方不在 Homebrew 中提供 Linux 版本
- 安装方式: 通过 `run_once_install-1password-cli.sh` 脚本自动处理

**macOS 系统**:
- 通过 Homebrew tap 安装: `brew install --cask 1password/tap/1password-cli`
- 在 Brewfile 中自动处理

### 处理策略

1. **保持功能一致性**: 虽然安装方式不同，但功能和配置完全一致
2. **自动化安装**: 通过 chezmoi 脚本自动处理平台差异
3. **统一配置**: 所有 1Password 相关配置在 `.chezmoi.toml.tmpl` 中统一管理

## 📈 迁移后优化

### 性能优化

```bash
# 清理 Homebrew 缓存
brew cleanup

# 更新所有包
brew upgrade

# 检查过时包
brew outdated
```

### 定期维护

```bash
# 每周运行一次
brew update && brew upgrade && brew cleanup

# 检查系统健康
brew doctor
```

---

*迁移完成后，你将拥有一个统一、现代、易维护的开发环境！*