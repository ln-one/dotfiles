# Chezmoi 配置管理

现代化的跨平台 dotfiles 管理，使用 Chezmoi 模板系统。

## 🚀 快速开始

### 全新安装
```bash
# 下载并运行安装脚本
curl -fsSL https://raw.githubusercontent.com/ln-one/dotfiles-chezmoi/main/install-chezmoi.sh | bash

# 或者手动安装
git clone https://github.com/ln-one/dotfiles-chezmoi.git ~/.local/share/chezmoi
cd ~/.local/share/chezmoi
./install-chezmoi.sh
```

### 应用配置
```bash
chezmoi apply --force
```

### 重新加载 Shell
```bash
# Bash
source ~/.bashrc

# Zsh  
source ~/.zshrc
```

## 🧩 四层分层配置架构

本项目采用智能的四层配置架构，实现环境自适应和配置分离：

### 配置加载顺序 (优先级从低到高)
```
1. 核心配置层 (Core Layer)     - 所有环境通用的基础功能
2. 平台配置层 (Platform Layer) - Linux/macOS 特定配置
3. 环境配置层 (Environment Layer) - 桌面/远程/容器/WSL 特定配置
4. 用户配置层 (User Layer)     - 个人定制和本地覆盖
```

### 文件结构
```
.chezmoitemplates/
├── core/                    # 🔧 核心配置层 (跨平台通用)
│   ├── environment.sh       # 环境变量管理 (路径、SSH、语言配置)
│   ├── environment-detection.sh # 智能环境检测 (容器/WSL/SSH/桌面)
│   ├── aliases.sh          # 核心别名 (ls/ll/la + 导航)
│   ├── basic-functions.sh   # 基础函数 (mkcd, sysinfo)
│   ├── fzf-config.sh       # FZF 模糊搜索配置
│   ├── zoxide-config.sh    # Zoxide 智能目录跳转配置
│   ├── oh-my-zsh-config.sh # Oh My Zsh 配置和性能优化
│   ├── starship-config.sh  # Starship 提示符配置
│   └── zsh-performance-tweaks.sh # Zsh 性能优化
├── platforms/               # 🖥️ 平台配置层 (操作系统特定)
│   ├── linux/              # Linux 特定配置
│   │   ├── proxy-functions.sh    # 代理管理 (Clash + GNOME)
│   │   └── theme-functions.sh    # WhiteSur 主题切换
│   └── darwin/             # macOS 特定配置
│       └── macos-specific.sh     # macOS 系统管理和应用
├── environments/            # 🌍 环境配置层 (使用场景特定)
│   ├── desktop.sh          # 桌面环境 - 完整功能配置
│   ├── remote.sh           # 远程环境 - 轻量化配置
│   ├── container.sh        # 容器环境 - 最小化配置
│   └── wsl.sh              # WSL 环境 - 混合优化配置
├── local/                   # 👤 用户配置层 (个人定制，待实现)
│   ├── user-overrides.sh   # 用户个人配置覆盖
│   └── local-config.sh     # 本地环境特定配置
└── shell-common.sh         # 🔄 分层配置加载器
```

### 智能环境检测
系统会自动检测运行环境并加载相应配置：

- **🖥️ 桌面环境** (`desktop`): 检测到 GUI 环境时，加载完整的开发工具和图形界面相关配置
- **🌐 远程环境** (`remote`): 检测到 SSH 连接时，加载轻量化配置，跳过 GUI 工具
- **📦 容器环境** (`container`): 检测到容器环境时，加载最小化配置，优化启动速度
- **🪟 WSL 环境** (`wsl`): 检测到 WSL 时，加载 Windows 集成优化配置

### 分层架构优势

🎯 **智能适配**: 根据运行环境自动选择最适合的配置组合
- VPS 远程服务器使用轻量化配置，响应更快
- 本地开发环境使用完整功能，提升效率
- 容器环境使用最小化配置，优化启动速度

🔧 **易于维护**: 配置职责清晰分离，便于管理和扩展
- 核心功能统一管理，确保一致性
- 平台特定功能独立维护，避免冲突
- 用户定制不影响系统更新

🚀 **性能优化**: 按需加载配置，避免不必要的资源消耗
- 远程环境跳过 GUI 相关配置
- 容器环境减少启动时间
- 桌面环境提供完整功能体验

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
├── run_once_install-fzf.sh.tmpl              # FZF 模糊搜索工具安装
├── run_once_install-zoxide.sh.tmpl           # Zoxide 智能目录跳转安装
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

### 平台特定功能

#### Linux 桌面环境
**代理管理** (Clash + GNOME 集成):
```bash
proxyon      # 启用代理 (Clash + 环境变量 + GNOME 系统代理)
proxyoff     # 关闭代理 (停止 Clash + 清除环境变量)
proxystatus  # 显示代理状态 (进程、环境变量、网络测试)
```

**主题切换** (WhiteSur + GNOME):
```bash
dark         # 切换到 WhiteSur 暗色主题 (GTK + Shell + fcitx5)
light        # 切换到 WhiteSur 亮色主题
themestatus  # 显示主题状态 (GTK、Shell、配色方案)
```

#### macOS 系统管理
**系统信息和管理**:
```bash
macos_version    # 显示 macOS 版本信息
system_status    # 系统资源使用情况
clean_system     # 清理系统缓存和垃圾桶
```

**应用管理** (Homebrew Cask + Mac App Store):
```bash
cask_list        # 列出已安装的 Cask 应用
cask_upgrade     # 更新所有 Cask 应用
mas_list         # 列出已安装的 App Store 应用
mas_upgrade      # 更新所有 App Store 应用
```

**系统优化**:
```bash
show_hidden      # 显示隐藏文件
hide_hidden      # 隐藏隐藏文件
reset_dock       # 重置 Dock 到默认设置
brew_cleanup     # 清理 Homebrew 缓存
```

### 基础函数
```bash
mkcd <dir>   # 创建目录并进入
sysinfo      # 显示系统信息
```

### 智能目录跳转 (Zoxide)
```bash
z <目录名>   # 智能跳转到匹配目录
zi           # 交互式目录选择 (需要 fzf)
z -          # 返回上一个目录
proj <名称>  # 快速跳转到项目目录
ztop         # 显示最常访问的目录
zclean       # 清理数据库
```

### 模糊搜索 (FZF)
```bash
fh           # 搜索历史命令
```

### 工具管理
- **自动安装**: 跨平台工具安装 (系统包管理器 + Homebrew)
- **智能检测**: 检查工具是否已安装，避免重复安装
- **现代工具**: eza, bat, fd, ripgrep, fzf, zoxide, jq 等现代 CLI 工具
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

- **分层架构**: 核心功能、平台特定、环境特定、本地自定义四层分离
- **模块化**: 每个功能独立的模板文件，按需加载
- **平台感知**: 根据操作系统和环境智能加载相应配置
- **性能优化**: 条件加载、延迟初始化、预编译脚本
- **简洁高效**: 只保留核心必需功能，避免功能冗余
- **易于维护**: 清晰的文件结构和职责分离，便于扩展和调试

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

✅ **Phase 3 已完成**:
- [x] 配置简化和性能优化
- [x] 安装脚本完善 (错误处理、回滚机制)
- [x] 网络连接优化 (超时、重试机制)
- [x] 跨平台兼容性测试和修复
- [x] FZF 模糊搜索集成
- [x] Zoxide 智能目录跳转集成

✅ **分层配置架构重构 (Phase 4)**:
- [x] 实现四层分层配置架构 (core/platforms/environments/local)
- [x] 智能环境检测系统 (容器/WSL/SSH/桌面自动识别)
- [x] 平台特定配置分离 (Linux 代理/主题管理，macOS 系统管理)
- [x] 环境特定配置实现 (桌面/远程/容器/WSL 差异化配置)
- [x] 文件结构重新组织和清理
- [x] 配置文档更新和完善

🚧 **进行中**:
- [ ] 分层配置加载器重构 (shell-common.sh)
- [ ] 用户本地配置层实现
- [ ] 配置验证和诊断工具

🎯 **项目状态**: 分层架构基础完成，核心功能稳定，正在完善高级特性

## 🧪 跨平台测试

本项目包含完整的跨平台兼容性测试套件，确保配置在不同环境下都能正常工作。

### 支持的平台
- ✅ **Ubuntu 24.04 LTS** - 完整支持，包括 apt 包管理器集成
- ✅ **macOS 12.0+** - 完整支持，包括 Homebrew 集成
- ✅ **SSH 远程服务器** - 优化的远程环境配置

### 运行测试
```bash
# 测试当前平台
./tests/test-cross-platform-compatibility.sh --current

# 测试所有平台 (根据当前环境)
./tests/test-cross-platform-compatibility.sh --all

# 查看测试选项
./tests/test-cross-platform-compatibility.sh --help
```

### 测试内容
- **系统环境检测** - 操作系统、架构、包管理器
- **Chezmoi 模板渲染** - 配置文件生成和语法验证
- **Shell 配置兼容性** - Bash/Zsh 配置语法检查
- **工具可用性** - 现代 CLI 工具安装和功能测试
- **性能测试** - Shell 启动时间和响应性能
- **网络连接** - 远程环境的网络和下载能力

详细测试文档请参考: [tests/README.md](tests/README.md)

## 🔗 相关文件

- **配置**: `.chezmoi.toml.tmpl` - Chezmoi 主配置
- **忽略**: `.chezmoiignore` - Chezmoi 忽略规则
- **参考**: `dotfiles/` - 原始配置 (仅本地参考，不追踪)

---

*此配置由 Chezmoi 管理，请勿直接编辑生成的文件*