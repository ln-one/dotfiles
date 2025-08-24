# Chezmoi 配置管理

现代化的跨平台 dotfiles 管理，使用 Chezmoi 模板系统。

## 🚀 快速开始

### 应用配置
```bash
chezmoi apply
```

### 重新加载 Shell
```bash
# Bash
source ~/.bashrc

# Zsh  
source ~/.zshrc
```

## 🧩 模块化架构

### 核心模板
```
.chezmoitemplates/
├── environment.sh           # 环境变量管理 (路径、SSH、语言配置)
├── shell-common.sh          # 别名、函数、颜色配置
├── aliases.sh              # 核心别名 (ls/ll/la + 导航)
├── basic-functions.sh       # 基础函数 (mkcd, sysinfo)
├── proxy-functions.sh       # 代理管理 (proxyon/proxyoff/proxystatus)
└── theme-functions.sh       # WhiteSur 主题切换 (light/dark/themestatus)
```

### Shell 配置
```
├── dot_bashrc.tmpl         # Bash 配置模板
├── dot_zshrc.tmpl          # Zsh 配置模板
└── run_onchange_verify-environment.sh.tmpl  # 环境验证脚本
```

### 自动化脚本
```
├── run_once_setup-1password-ssh.sh.tmpl      # 1Password SSH Agent 设置
├── run_once_install-homebrew.sh.tmpl         # Homebrew 自动安装
├── run_once_install-tools.sh.tmpl            # 工具自动安装
├── run_once_install-version-managers.sh.tmpl # 版本管理器安装
├── run_onchange_install-brew-packages.sh.tmpl # Homebrew 包管理
└── run_onchange_verify-environment.sh.tmpl   # 环境变量验证
```

### 包管理
```
├── Brewfile.tmpl                            # Homebrew 包配置模板
└── docs/homebrew-integration.md             # Homebrew 集成文档
```

## 🔧 功能特性

### 环境变量管理
- **路径配置**: `USER_HOME`, `CONFIG_DIR`, `LOCAL_BIN` 自动设置
- **SSH Agent**: 1Password SSH Agent 跨平台集成
- **语言配置**: UTF-8 区域设置和编辑器配置
- **平台检测**: 自动检测 Linux/macOS 并应用相应配置

### 别名功能
- **智能 ls**: 自动检测并使用 `eza` > `exa` > `ls`
- **导航**: `..`, `...`, `....`, `~`, `-`
- **安全操作**: `cp -i`, `mv -i`, `rm -i`

### 代理管理 (Linux 桌面)
```bash
proxyon      # 启用代理 (环境变量 + GNOME 系统代理)
proxyoff     # 关闭代理
proxystatus  # 显示代理状态
```

### 主题切换 (Linux GNOME)
```bash
dark         # 切换到 WhiteSur 暗色主题
light        # 切换到 WhiteSur 亮色主题
themestatus  # 显示主题状态
```

### 基础函数
```bash
mkcd <dir>   # 创建目录并进入
sysinfo      # 显示系统信息
```

### 工具管理
- **自动安装**: 跨平台工具安装 (系统包管理器 + Homebrew)
- **智能检测**: 检查工具是否已安装，避免重复安装
- **现代工具**: eza, bat, fd, ripgrep, fzf, jq 等现代 CLI 工具
- **开发环境**: git, curl, neovim, tmux 等开发工具自动配置

### 版本管理器集成
- **NVM**: Node.js 版本管理，自动安装 LTS 版本
- **pyenv**: Python 版本管理，自动安装最新稳定版
- **rbenv**: Ruby 版本管理 (可选)
- **mise**: 通用版本管理器 (可选)
- **配置文件**: 自动创建 .nvmrc, .python-version 等配置文件

### SSH 和 Git 配置
- **SSH 配置**: 集成 1Password SSH Agent，支持多主机配置
- **Git 配置**: SSH 签名、代理配置、用户信息管理
- **安全**: SSH 密钥通过 1Password 管理，支持 YubiKey

## 🎯 设计原则

- **模块化**: 每个功能独立的模板文件
- **平台感知**: 根据操作系统和环境智能加载
- **简洁高效**: 只保留核心必需功能
- **易于维护**: 清晰的文件结构和职责分离

## 📋 迁移状态

✅ **已完成**:
- [x] Chezmoi 基础环境设置
- [x] 核心配置模板 (Zsh/Bash)
- [x] 环境变量管理系统
- [x] 1Password SSH Agent 集成
- [x] 跨平台兼容性 (Linux/macOS)
- [x] 核心别名系统
- [x] 代理管理功能
- [x] WhiteSur 主题切换
- [x] 基础实用函数
- [x] 模块化架构

✅ **Phase 2 已完成**:
- [x] Homebrew 包管理集成
- [x] 工具自动安装系统
- [x] 版本管理器集成 (NVM, pyenv, rbenv, mise)
- [x] SSH 和 Git 配置迁移

🚧 **Phase 3 进行中**:
- [ ] 配置简化和性能优化
- [ ] 社区工具集成 (Oh My Zsh, Starship, fzf)
- [ ] 跨平台兼容性测试

## 🔗 相关文件

- **配置**: `.chezmoi.toml.tmpl` - Chezmoi 主配置
- **忽略**: `.chezmoiignore` - Chezmoi 忽略规则
- **参考**: `dotfiles/` - 原始配置 (仅本地参考，不追踪)

---

*此配置由 Chezmoi 管理，请勿直接编辑生成的文件*