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

本项目采用智能的四层配置架构，通过 chezmoi 模板系统实现环境自适应和配置分离：

### 配置加载顺序 (优先级从低到高)
```
1. 核心配置层 (Core Layer)        - 所有环境通用的基础功能
2. 平台配置层 (Platform Layer)    - Linux/macOS 特定配置  
3. 环境配置层 (Environment Layer) - 桌面/远程/容器/WSL 特定配置
4. 用户配置层 (User Layer)        - 个人定制和本地覆盖
```

### 文件结构
```
.chezmoitemplates/
├── core/                    # 🔧 核心配置层 (跨平台通用)
│   ├── environment.sh       # 环境变量管理 (路径、SSH、语言配置)
│   ├── aliases.sh          # 核心别名 (ls/ll/la + 导航)
│   ├── basic-functions.sh   # 基础函数 (mkcd, sysinfo)
│   ├── fzf-config.sh       # FZF 模糊搜索配置
│   ├── zoxide-config.sh    # Zoxide 智能目录跳转配置
│   ├── zim-config.sh       # Zim 框架配置和模块管理
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
├── local/                   # 👤 用户配置层 (个人定制，可选)
│   ├── user-overrides.sh   # 用户个人配置覆盖
│   └── local-config.sh     # 本地环境特定配置
└── shell-common.sh         # 🔄 分层配置加载器
```

### 环境配置选择
通过 chezmoi 模板变量 `.environment` 静态确定环境配置：

- **🖥️ 桌面环境** (`desktop`): 完整的开发工具和图形界面相关配置 (默认)
- **🌐 远程环境** (`remote`): 轻量化配置，跳过 GUI 工具，优化 SSH 使用
- **📦 容器环境** (`container`): 最小化配置，优化启动速度和资源使用
- **🪟 WSL 环境** (`wsl`): Windows 集成优化配置，支持跨系统操作

可通过 `.chezmoi.toml.tmpl` 配置文件设置环境类型，或使用环境变量覆盖。

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
├── dot_tmux.conf.tmpl      # Tmux 配置模板 (Tokyo Night 主题)
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

### 性能优化
- **zsh-defer 延迟加载**: 非关键组件延迟初始化，启动时间减少到 0.02-0.05 秒
  - 版本管理工具 (pyenv/rbenv/fnm) 延迟加载
  - CLI 补全系统 (kubectl/docker/gh) 延迟加载
  - 语法高亮和历史搜索延迟加载
  - 保持关键功能 (提示符/目录跳转) 立即可用
- **Evalcache 缓存**: 自动缓存 `eval` 语句输出，显著加速 shell 启动
  - Starship 初始化: ~50-100ms → ~1-5ms (90%+ 提升)
  - pyenv/rbenv 初始化: ~100-200ms → ~1-5ms (95%+ 提升)
- **智能缓存管理**: 自动检测工具更新并刷新缓存

### 环境变量管理
- **路径配置**: `USER_HOME`, `CONFIG_DIR`, `LOCAL_BIN` 自动设置
- **SSH Agent**: 1Password SSH Agent 跨平台集成
- **语言配置**: UTF-8 区域设置和编辑器配置
- **平台检测**: 自动检测 Linux/macOS 并应用相应配置
- **代理配置**: 自动检测 Clash 配置或环境变量，统一设置代理

### 别名功能
- **智能 ls**: 自动检测并使用 `eza` > `exa` > `ls`
- **导航**: `..`, `...`, `....`, `~`, `-`
- **安全操作**: `cp -i`, `mv -i`, `rm -i`

### 平台特定功能

#### Linux 桌面环境
**代理管理** (智能检测 + GNOME 集成):
```bash
proxyon      # 启用代理 (Clash + 环境变量 + GNOME 系统代理)
proxyoff     # 关闭代理 (停止 Clash + 清除环境变量)
proxystatus  # 显示代理状态 (进程、环境变量、网络测试)
```

**代理自动配置**:
- 优先检测环境变量 (`http_proxy`, `https_proxy`, `socks_proxy`)
- 其次读取 Clash 配置文件 (`~/.config/clash/config.yaml`)
- 自动设置 SSH 代理和终端代理环境变量
- 支持 Linux/Windows 系统，macOS 默认禁用

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

### 智能历史搜索
```bash
# 历史子字符串搜索 - 按前缀搜索历史命令
# 输入命令前缀，然后按上下箭头键搜索匹配的历史命令
git <↑>      # 搜索以 "git" 开头的历史命令
docker <↑>   # 搜索以 "docker" 开头的历史命令
npm <↑>      # 搜索以 "npm" 开头的历史命令

# 键绑定:
# ↑ 箭头键    - 向前搜索匹配的历史命令
# ↓ 箭头键    - 向后搜索匹配的历史命令
# k (vi模式)  - 向前搜索 (仅在 vi 模式下)
# j (vi模式)  - 向后搜索 (仅在 vi 模式下)
```

### 终端复用器 (Tmux)
**Tokyo Night 主题配置**:
- 现代化的 Tokyo Night 配色方案，支持真彩色显示
- Vim 风格的窗格导航 (hjkl) 和调整大小 (HJKL)
- 智能状态栏显示：会话信息、CPU 使用率、电池状态、日期
- TPM 插件管理器集成，支持会话恢复和系统监控

**快捷键配置**:
```bash
# 前缀键: Ctrl-a (替代默认的 Ctrl-b)
# 窗格分割
Ctrl-a |     # 垂直分割窗格
Ctrl-a -     # 水平分割窗格

# Vim 风格导航
Ctrl-a h/j/k/l    # 选择左/下/上/右窗格
Ctrl-a H/J/K/L    # 调整窗格大小

# 窗口管理
Alt-1/2/3/4/5     # 快速切换到窗口 1-5
Ctrl-a c          # 新建窗口 (在当前路径)
Ctrl-a r          # 重新加载配置文件
```

### 工具管理
- **自动安装**: 跨平台工具安装 (系统包管理器 + Homebrew)
- **智能检测**: 检查工具是否已安装，避免重复安装
- **现代工具**: eza, bat, fd, ripgrep, fzf, zoxide, jq 等现代 CLI 工具
- **开发环境**: git, curl, neovim, tmux 等开发工具自动配置

### 版本管理器集成
- **fnm**: 快速的 Node.js 版本管理器，替代 nvm
- **pyenv**: Python 版本管理，自动安装最新稳定版
- **rbenv**: Ruby 版本管理 (可选)
- **mise**: 通用版本管理器 (可选)
- **配置文件**: 自动创建 .nvmrc, .python-version 等配置文件

### SSH 和 Git 配置
- **SSH 配置**: 集成 1Password SSH Agent，支持多主机配置
- **SSH 代理**: 自动检测并配置 SOCKS5 代理 (GitHub, GitLab 等)
- **Git 配置**: SSH 签名、代理配置、用户信息管理
- **安全**: SSH 密钥通过 1Password 管理，支持 YubiKey

## 🎯 设计原则

- **分层架构**: 核心功能、平台特定、环境特定、本地自定义四层分离
- **模块化**: 每个功能独立的模板文件，按需加载
- **平台感知**: 根据操作系统和环境智能加载相应配置
- **性能优化**: zsh-defer 延迟加载、evalcache 缓存、条件加载
- **简洁高效**: 只保留核心必需功能，避免功能冗余
- **易于维护**: 清晰的文件结构和职责分离，便于扩展和调试

## 🎯 项目状态

✅ **核心功能完成**:
- 四层分层配置架构 (core/platforms/environments/local)
- Zim 框架集成，替代 Oh My Zsh
- 跨平台兼容性 (Linux/macOS/WSL)
- 智能环境检测和配置适配
- 现代化工具集成 (fzf, zoxide, starship)
- 1Password SSH Agent 集成
- 智能代理配置系统

🔧 **持续优化**:
- 配置验证和诊断工具
- 性能监控和调试
- 新工具集成和更新

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

## 🔧 故障排除

### ls 命令图标不显示

**问题**: `ls` 命令不显示图标，显示为普通文本列表

**原因**: 某些 shell 框架可能会覆盖自定义别名设置

**解决方案**: 
1. 配置系统已自动修复此问题，在框架加载后重新设置别名
2. 如果问题仍然存在，重新应用配置：
   ```bash
   chezmoi apply
   source ~/.zshrc
   ```

**验证修复**:
```bash
# 检查别名设置
alias ls
# 应该显示: ls='eza --color=auto --icons'

# 测试图标显示
ls
# 应该显示带图标的文件列表
```

### 配置加载顺序问题

如果遇到配置被意外覆盖的问题，检查加载顺序：

1. **核心配置** → **平台配置** → **环境配置** → **用户配置**
2. Zim 框架在核心配置层加载，别名在其后重新设置
3. 用户配置具有最高优先级，可以覆盖任何设置

## 📖 详细文档

- **[安装指南](docs/INSTALL.md)** - 详细的安装和配置说明
- **[Evalcache 使用](docs/evalcache-usage.md)** - Shell 启动加速和缓存管理
- **[1Password 集成](docs/1password-integration.md)** - SSH Agent 和密钥管理
- **[Homebrew 集成](docs/homebrew-integration.md)** - 包管理和工具安装
- **[社区工具](docs/community-tools.md)** - 现代化 CLI 工具介绍
- **[Nerd Fonts 设置](docs/nerd-fonts-setup.md)** - 字体安装和配置
- **[Zoxide 使用](docs/zoxide-usage.md)** - 智能目录跳转使用指南

## 🔗 相关文件

- **配置**: `.chezmoi.toml.tmpl` - Chezmoi 主配置
- **忽略**: `.chezmoiignore` - Chezmoi 忽略规则
- **参考**: `dotfiles/` - 原始配置 (仅本地参考，不追踪)

---

*此配置由 Chezmoi 管理，请勿直接编辑生成的文件*