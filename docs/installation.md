# 安装指南

## 前置要求

- Git
- Curl 或 Wget
- 1Password (推荐，用于 SSH 密钥管理)

## 快速安装

### 1. 安装 Chezmoi

```bash
# 使用官方安装脚本
sh -c "$(curl -fsLS get.chezmoi.io)"

# 或者使用包管理器
# Ubuntu/Debian
sudo apt install chezmoi

# macOS
brew install chezmoi
```

### 2. 初始化配置

```bash
# 克隆并应用配置
chezmoi init --apply https://github.com/ln-one/dotfiles-chezmoi.git
```

### 3. 重新加载 Shell

```bash
# Zsh
source ~/.zshrc

# Bash
source ~/.bashrc
```

## 自动化安装

配置包含以下自动化脚本，会在首次应用时运行：

- **工具安装**: 自动安装必需的开发工具
- **版本管理器**: 安装 NVM、pyenv 等版本管理器
- **Homebrew**: 跨平台包管理器安装
- **SSH 配置**: 1Password SSH Agent 设置

## 验证安装

```bash
# 检查别名
ll

# 检查代理功能 (Linux 桌面)
proxystatus

# 检查主题功能 (GNOME)
themestatus

# 检查版本管理器
nvm --version
pyenv --version
```

## 故障排除

### SSH 连接问题

1. 确保 1Password 应用正在运行
2. 检查 SSH Agent 套接字：`ls -la ~/.1password/agent.sock`
3. 测试 GitHub 连接：`ssh -T git@github.com`

### 工具安装失败

1. 检查网络连接
2. 更新系统包管理器：`sudo apt update` (Ubuntu)
3. 手动运行安装脚本：`chezmoi execute-template ~/.local/share/chezmoi/run_once_install-tools.sh.tmpl | bash`

### 版本管理器问题

1. 重新启动终端
2. 手动加载环境：`source ~/.zshrc`
3. 检查 PATH 设置：`echo $PATH`

## 自定义配置

编辑 `.chezmoi.toml.tmpl` 文件来自定义功能开关：

```toml
[data.features]
enable_proxy = true      # 代理管理功能
enable_theme = true      # 主题切换功能
enable_node = true       # Node.js 支持
enable_python = true     # Python 支持
```

应用更改：

```bash
chezmoi apply
```