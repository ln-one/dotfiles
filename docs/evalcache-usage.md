# Evalcache 使用指南

## 概述

Evalcache 是一个 zsh 插件，用于缓存 `eval` 语句的输出，显著加速 shell 启动时间。对于使用多个需要 `eval` 初始化的工具（如 starship、pyenv、rbenv 等）的开发环境特别有效。

## 自动安装

Evalcache 已集成到 chezmoi 配置中，会自动安装和配置：

```bash
chezmoi apply
exec zsh  # 重启 shell 生效
```

## 支持的工具

当前配置支持缓存以下工具的初始化：

### 核心工具
- **Starship** - 现代化提示符
- **fzf** - 模糊搜索工具
- **zoxide** - 智能目录跳转

### 版本管理工具（最大收益）
- **pyenv** - Python 版本管理
- **rbenv** - Ruby 版本管理
- **fnm** - Node.js 版本管理
- **mise** - 多语言版本管理
- **nvm** - Node.js 版本管理（传统）

### 包管理器
- **Homebrew** - Linux 上的 Homebrew 环境设置
- **Conda** - Python 环境管理

### 开发工具
- **direnv** - 环境变量管理
- **thefuck** - 命令纠错工具
- **gh** - GitHub CLI 补全
- **kubectl** - Kubernetes CLI 补全
- **docker** - Docker CLI 补全

## 性能提升

预期的启动时间改善：

| 工具 | 原始时间 | 缓存后时间 | 提升 |
|------|----------|------------|------|
| Starship | 50-100ms | 1-5ms | 90%+ |
| pyenv/rbenv | 100-200ms | 1-5ms | 95%+ |
| fzf | 20-50ms | 1-5ms | 80%+ |
| zoxide | 10-30ms | 1-5ms | 70%+ |

**总体提升**: shell 启动时间可减少 200-500ms

## 管理命令

### 查看缓存状态
```bash
evalcache-status
```

显示：
- 缓存目录位置
- 缓存文件数量
- 缓存目录大小
- 已缓存的工具列表

### 清理所有缓存
```bash
evalcache-clear
```

删除所有缓存文件，下次启动时重新生成。

### 刷新特定工具缓存
```bash
evalcache-refresh starship
evalcache-refresh pyenv
```

删除指定工具的缓存，强制重新生成。

### 性能测试
```bash
# 手动测试启动时间
time zsh -i -c exit
```

## 工作原理

1. **首次运行**: `_evalcache` 执行原始命令并将输出保存到缓存文件
2. **后续运行**: 直接读取缓存文件内容，跳过命令执行
3. **缓存失效**: 当原始命令或其依赖发生变化时，自动重新生成缓存

## 缓存位置

- **缓存目录**: `~/.cache/evalcache/`
- **插件目录**: `~/.evalcache/`

## 故障排除

### 工具行为异常
如果某个工具的行为不正常，可能是缓存过期：

```bash
# 刷新特定工具缓存
evalcache-refresh <tool_name>

# 或清理所有缓存
evalcache-clear
```

### 新版本工具不生效
更新工具后，需要刷新对应的缓存：

```bash
# 例如更新 starship 后
evalcache-refresh starship
```

### 禁用 evalcache
如果需要临时禁用 evalcache，可以：

1. **临时禁用**: 设置环境变量
   ```bash
   export EVALCACHE_DISABLE=1
   ```

2. **永久禁用**: 在 chezmoi 配置中设置
   ```toml
   [data.features]
   enable_evalcache = false
   ```

### 查看缓存过程
首次启动时会看到缓存信息：

```bash
evalcache: starship initialization not cached, caching output of: starship init zsh
evalcache: zoxide initialization not cached, caching output of: zoxide init zsh
```

## 最佳实践

### 1. 定期清理缓存
建议每月清理一次缓存，确保使用最新的工具配置：

```bash
evalcache-clear
```

### 2. 监控性能
观察 shell 启动速度的改善，通常第二次启动会明显更快。

### 3. 工具更新后刷新
更新开发工具后，记得刷新对应的缓存：

```bash
# 更新 pyenv 后
evalcache-refresh pyenv

# 更新 starship 后  
evalcache-refresh starship
```

### 4. 新环境设置
在新环境中首次运行时，让所有工具生成缓存：

```bash
# 重新启动 shell 几次，让所有工具生成缓存
exec zsh
```

## 配置自定义

### 添加新工具
要为新工具添加 evalcache 支持，编辑 `.chezmoitemplates/core/evalcache-config.sh`：

```bash
# 添加新工具
if command -v newtool >/dev/null 2>&1; then
    _evalcache newtool init zsh
fi
```

### 自定义缓存目录
设置环境变量：

```bash
export EVALCACHE_DIR="$HOME/.cache/my-evalcache"
```

## 兼容性

- **主要支持**: zsh
- **实验性支持**: bash（部分功能）
- **不支持**: fish、其他 shell

## 相关链接

- [evalcache GitHub 仓库](https://github.com/mroth/evalcache)
- [Shell 配置文档](../README.md)