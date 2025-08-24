# 社区工具集成指南

本文档介绍 Chezmoi 重构项目中集成的社区工具，包括 Oh My Zsh、Starship 提示符和 fzf 模糊搜索。

## 概述

为了提供现代化的 Shell 体验，我们集成了以下经过社区验证的成熟工具：

- **Oh My Zsh**: Zsh 框架和插件管理系统
- **Starship**: 跨 Shell 的现代化提示符
- **fzf**: 强大的模糊搜索工具

## 功能特性

### Oh My Zsh 集成

**功能**:
- 自动安装 Oh My Zsh 框架
- 预配置常用插件 (git, docker, npm, python 等)
- 自动安装 zsh-autosuggestions 和 zsh-syntax-highlighting
- 根据环境类型优化插件配置

**配置位置**:
- 安装脚本: `run_once_install-oh-my-zsh.sh.tmpl`
- 配置模板: `.chezmoitemplates/oh-my-zsh-config.sh`

**启用/禁用**:
```toml
# .chezmoi.toml.tmpl
[data.features]
  enable_oh_my_zsh = true  # 设为 false 禁用
```

### Starship 提示符

**功能**:
- 跨 Shell 支持 (Zsh, Bash, Fish 等)
- 现代化的彩色提示符
- Git 状态显示
- 编程语言版本检测
- 根据环境优化显示内容
- 使用官方预设配置

**配置位置**:
- 安装脚本: `run_once_install-starship.sh.tmpl`
- 配置模板: `dot_config/starship.toml.tmpl`
- 初始化模板: `.chezmoitemplates/starship-config.sh`

**启用/禁用**:
```toml
# .chezmoi.toml.tmpl
[data.features]
  enable_starship = true  # 设为 false 使用默认提示符
```

**可用预设**:
- `catppuccin-powerline`: 彩色 Powerline 风格 (桌面环境默认)
- `nerd-font-symbols`: 简洁图标风格 (远程环境默认)
- `bracketed-segments`: 方括号分段风格
- `plain-text-symbols`: 纯文本符号风格

### fzf 模糊搜索

**功能**:
- 文件和目录模糊搜索
- 命令历史搜索
- Git 分支和提交搜索
- 进程搜索和管理
- 与 fd、ripgrep、bat 等现代工具集成

**配置位置**:
- 安装脚本: `run_once_install-fzf.sh.tmpl`
- 配置模板: `.chezmoitemplates/fzf-config.sh`

**启用/禁用**:
```toml
# .chezmoi.toml.tmpl
[data.features]
  enable_fzf = true  # 设为 false 禁用
```

## 安装和使用

### 自动安装

社区工具会在 Chezmoi 应用配置时自动安装：

```bash
# 初始化 Chezmoi (会触发工具安装)
chezmoi init --apply

# 或手动运行统一安装脚本
./run_once_install-community-tools.sh
```

### 手动安装单个工具

```bash
# 只安装 Oh My Zsh
./run_once_install-oh-my-zsh.sh

# 只安装 Starship
./run_once_install-starship.sh

# 只安装 fzf
./run_once_install-fzf.sh
```

### 验证安装

重新启动终端或运行以下命令来验证安装：

```bash
# 验证 Oh My Zsh
echo $ZSH_VERSION && ls $ZSH

# 验证 Starship
starship --version

# 验证 fzf
fzf --version
```

## 使用指南

### fzf 快捷键

- `Ctrl+T`: 搜索文件并插入到命令行
- `Ctrl+R`: 搜索命令历史
- `Alt+C`: 搜索目录并 cd 进入

### fzf 自定义函数

- `fcd [目录]`: 模糊搜索并切换到目录
- `fe [查询]`: 搜索文件并用编辑器打开
- `fh`: 搜索历史命令并执行
- `fkill`: 搜索进程并终止
- `fgb`: 搜索 Git 分支并切换 (在 Git 仓库中)
- `fgl`: 搜索 Git 提交历史 (在 Git 仓库中)

### Oh My Zsh 插件

启用的插件根据环境自动配置：

**桌面环境**:
- git, docker, npm, nvm, python, pip, fzf
- zsh-autosuggestions, zsh-syntax-highlighting

**远程/服务器环境**:
- git, fzf, zsh-autosuggestions, zsh-syntax-highlighting

### Starship 配置

Starship 提示符会根据环境显示不同信息：

**桌面环境**: 完整的彩色提示符，包含 Git 状态、语言版本、Docker 上下文等
**远程环境**: 简化的提示符，专注于基本信息和性能

## 自定义配置

### 修改 Oh My Zsh 配置

编辑 `.chezmoitemplates/oh-my-zsh-config.sh`:

```bash
# 添加自定义插件
plugins=(
    git
    your-custom-plugin  # 添加你的插件
    zsh-autosuggestions
    zsh-syntax-highlighting
)
```

### 修改 Starship 配置

**使用官方预设** (推荐):

```bash
# 应用 Catppuccin Powerline 预设
starship preset catppuccin-powerline -o ~/.config/starship.toml

# 应用其他预设
starship preset nerd-font-symbols -o ~/.config/starship.toml
starship preset bracketed-segments -o ~/.config/starship.toml

# 查看所有可用预设
starship preset --list
```

**自定义配置**:

如果需要自定义，可以在应用预设后编辑 `~/.config/starship.toml`:

```toml
# 添加自定义模块
[custom.my_module]
command = "echo 'custom'"
when = true

# 修改现有模块
[directory]
truncation_length = 5
```

### 修改 fzf 配置

编辑 `.chezmoitemplates/fzf-config.sh`:

```bash
# 自定义 fzf 选项
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --height 60%"
```

## 故障排除

### 常见问题

1. **Oh My Zsh 安装失败**
   - 检查网络连接
   - 确保 curl 和 git 已安装
   - 手动运行: `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`

2. **Starship 提示符不显示**
   - 确保 Starship 已安装: `starship --version`
   - 检查配置文件: `~/.config/starship.toml`
   - 重新加载 Shell: `source ~/.zshrc`

3. **fzf 快捷键不工作**
   - 确保 fzf 已安装: `fzf --version`
   - 检查 Shell 集成文件: `~/.fzf.zsh` 或 `~/.fzf.bash`
   - 重新运行 fzf 安装: `~/.fzf/install`

### 性能优化

如果 Shell 启动变慢，可以：

1. 禁用不需要的 Oh My Zsh 插件
2. 使用 Starship 替代 Oh My Zsh 主题
3. 在远程环境禁用重型功能

### 回滚到默认配置

如果需要禁用社区工具，修改 `.chezmoi.toml.tmpl`:

```toml
[data.features]
  enable_oh_my_zsh = false
  enable_starship = false
  enable_fzf = false
```

然后重新应用配置：

```bash
chezmoi apply
```

## 更多资源

- [Oh My Zsh 官方文档](https://ohmyz.sh/)
- [Starship 官方文档](https://starship.rs/)
- [fzf GitHub 仓库](https://github.com/junegunn/fzf)
- [Chezmoi 官方文档](https://www.chezmoi.io/)