# Zsh-defer 启动优化指南

## 概述

本项目集成了 [zsh-defer](https://github.com/romkatv/zsh-defer) 来显著提升 Zsh 启动速度。通过延迟加载非关键组件，启动时间可以从数秒减少到 0.02-0.05 秒。

## 优化策略

### ✅ 已延迟加载的组件

#### 版本管理工具（高收益）
- `pyenv init -` - Python 版本管理
- `rbenv init -` - Ruby 版本管理  
- `fnm env --use-on-cd` - Node.js 版本管理
- `mise activate zsh` - 多语言版本管理

#### CLI 工具补全系统（高收益）
- `gh completion -s zsh` - GitHub CLI 补全
- `kubectl completion zsh` - Kubernetes CLI 补全
- `docker completion zsh` - Docker CLI 补全

#### 其他工具
- `thefuck --alias` - 命令纠错工具
- Homebrew 环境设置（Linux）
- `fzf --zsh` - fzf shell 集成

### ❌ 保持立即加载的组件

为了用户体验，以下组件保持立即加载：

- `starship init zsh` - 提示符（需要立即显示）
- `zoxide init zsh` - 目录跳转（用户第一个命令常用）
- 基础别名和环境变量
- fzf 自定义函数

## 实现细节

### 配置文件结构

```
.chezmoitemplates/
├── core/
│   ├── zsh-defer-init.sh      # zsh-defer 初始化
│   ├── evalcache-config.sh    # 延迟加载配置
│   └── fzf-config.sh         # fzf 延迟集成
└── shell-common.sh           # 主配置文件
```

### 加载顺序

1. **Zim 框架初始化** - 安装 zsh-defer 模块
2. **zsh-defer 初始化** - 激活延迟加载功能
3. **evalcache 配置** - 使用 zsh-defer 延迟各种工具
4. **其他配置** - starship、zoxide 等立即加载

### 关键修复

1. **避免重复初始化**：
   - 移除 `environment.sh` 中的 fnm 直接初始化
   - 禁用 Zim 的 fzf 模块，使用自定义 defer 配置

2. **回退机制**：
   - 如果 zsh-defer 不可用，回退到 evalcache
   - 如果 evalcache 不可用，回退到直接初始化

## 使用方法

### 启用 zsh-defer

zsh-defer 通过 Zim 框架自动安装和配置：

```bash
# 应用配置
chezmoi apply

# 安装 Zim 模块（包括 zsh-defer）
zimfw install

# 重启终端生效
```

### 性能测试

```bash
# 测试启动时间
time zsh -i -c exit

# 详细性能分析
zsh -i -c 'zprof'
```

### 验证功能

延迟加载的工具在第一次使用时会自动初始化：

```bash
# 版本管理工具
pyenv versions    # 第一次使用时初始化
fnm list         # 第一次使用时初始化

# CLI 补全
kubectl <tab>    # 第一次使用时加载补全
docker <tab>     # 第一次使用时加载补全

# fzf 快捷键
Ctrl-R          # 第一次使用时初始化
Ctrl-T          # 第一次使用时初始化
```

## 预期效果

- **启动时间**：从 1-3 秒减少到 0.02-0.05 秒
- **用户体验**：基础功能立即可用，高级功能按需加载
- **兼容性**：完整的回退机制确保在任何环境下都能正常工作

## 故障排除

### zsh-defer 未初始化

如果看到错误信息，检查 Zim 安装：

```bash
# 重新安装 Zim 模块
zimfw install

# 检查 zsh-defer 是否可用
command -v zsh-defer
```

### 工具初始化失败

如果某个工具无法使用，可以手动初始化：

```bash
# 手动初始化 pyenv
eval "$(pyenv init -)"

# 手动初始化 fnm
eval "$(fnm env --use-on-cd)"
```

### 性能问题

如果启动仍然很慢，使用 zprof 分析：

```bash
# 在 .zshrc 开头添加
zmodload zsh/zprof

# 在 .zshrc 结尾添加
zprof
```

## 自定义配置

### 添加新的延迟工具

在 `.chezmoitemplates/core/evalcache-config.sh` 中添加：

```bash
# 新工具延迟加载
if command -v zsh-defer >/dev/null 2>&1; then
    if command -v your-tool >/dev/null 2>&1; then
        zsh-defer _evalcache your-tool init
    fi
fi
```

### 禁用特定工具的延迟

如果某个工具的延迟影响使用，可以移除其 `zsh-defer` 包装，改为直接初始化。

## 参考资料

- [zsh-defer GitHub](https://github.com/romkatv/zsh-defer)
- [Zim 框架文档](https://zimfw.sh/)
- [evalcache 插件](https://github.com/mroth/evalcache)