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
├── aliases.sh              # 核心别名 (ls/ll/la + 导航)
├── basic-functions.sh       # 基础函数 (mkcd, sysinfo)
├── proxy-functions.sh       # 代理管理 (proxyon/proxyoff/proxystatus)
├── theme-functions.sh       # WhiteSur 主题切换 (light/dark/themestatus)
└── shell-common.sh          # 模块加载器
```

### Shell 配置
```
├── dot_bashrc.tmpl         # Bash 配置模板
└── dot_zshrc.tmpl          # Zsh 配置模板
```

## 🔧 功能特性

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

## 🎯 设计原则

- **模块化**: 每个功能独立的模板文件
- **平台感知**: 根据操作系统和环境智能加载
- **简洁高效**: 只保留核心必需功能
- **易于维护**: 清晰的文件结构和职责分离

## 📋 迁移状态

✅ **已完成**:
- [x] 核心别名系统
- [x] 代理管理功能
- [x] WhiteSur 主题切换
- [x] 基础实用函数
- [x] 模块化架构

## 🔗 相关文件

- **配置**: `.chezmoi.toml.tmpl` - Chezmoi 主配置
- **忽略**: `.chezmoiignore` - Chezmoi 忽略规则
- **参考**: `dotfiles/` - 原始配置 (仅本地参考，不追踪)

---

*此配置由 Chezmoi 管理，请勿直接编辑生成的文件*