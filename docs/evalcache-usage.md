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

## 性能优化策略

### 缓存策略分类

配置采用智能缓存策略，根据工具的实际性能特点决定是否使用缓存：

#### 高优先级缓存（真正慢的工具）
| 工具 | 原始时间 | 缓存后时间 | 提升 | 状态 |
|------|----------|------------|------|------|
| Starship | 50-100ms | 1-5ms | 90%+ | ✅ 缓存 |
| pyenv/rbenv | 100-200ms | 1-5ms | 95%+ | ✅ 缓存 |
| Homebrew | 50-150ms | 1-5ms | 90%+ | ✅ 缓存 |
| Conda | 200-500ms | 1-5ms | 98%+ | ✅ 缓存 |

#### 直接执行（快速工具）
| 工具 | 原始时间 | 缓存开销 | 决策 | 状态 |
|------|----------|----------|------|------|
| fzf | 5-15ms | 3-8ms | 缓存无益 | ❌ 直接 eval |
| zoxide | 3-10ms | 3-8ms | 缓存无益 | ❌ 直接 eval |
| direnv | 5-20ms | 3-8ms | 缓存无益 | ❌ 直接 eval |

#### 特殊处理
- **fnm**: 性能优化版本，禁用自动切换钩子以减少启动时间
- **mise**: 仅在确实很慢时才缓存

### fnm 性能优化详解

fnm 的 `--use-on-cd` 选项会创建 `_fnm_autoload_hook` 函数，在性能分析中占用 13.60% 的启动时间。

#### 优化策略
```bash
# ❌ 原始配置（慢）
eval "$(fnm env --use-on-cd)"  # 创建自动切换钩子

# ✅ 优化配置（快）
eval "$(fnm env)"              # 轻量级初始化
export PATH="$HOME/.fnm:$PATH"
```

#### 功能权衡
| 配置 | 启动时间 | 自动切换 | 使用方式 |
|------|----------|----------|----------|
| `--use-on-cd` | +13.60% | ✅ | `cd project` 自动切换 |
| 优化版本 | +1-2% | ❌ | `fnm use` 手动切换 |

#### 恢复自动切换
如果需要自动切换功能，在配置中取消注释：
```bash
# eval "$(fnm env --use-on-cd)"
```

### 性能问题诊断

如果 evalcache 本身成为性能瓶颈，使用内置诊断工具：

```bash
# 诊断性能问题
evalcache-diagnose

# 清理所有缓存重新开始
evalcache-clear

# 查看缓存状态
evalcache-status
```

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

### 性能诊断
```bash
evalcache-diagnose
```

诊断性能问题：
- 检查缓存文件大小
- 识别异常缓存文件
- 提供优化建议

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

#### 手动性能测试
```bash
# 测试当前启动时间
time zsh -i -c exit

# 对比缓存效果
ZSH_EVALCACHE_DISABLE=1 time zsh -i -c exit  # 禁用缓存
time zsh -i -c exit                           # 启用缓存
```

#### zsh 性能分析
```bash
# 在 .zshrc 开头添加
zmodload zsh/zprof

# 在 .zshrc 结尾添加
zprof
```

## 工作原理

1. **首次运行**: `_evalcache` 执行原始命令并将输出保存到缓存文件
2. **后续运行**: 直接读取缓存文件内容，跳过命令执行
3. **缓存失效**: 当原始命令或其依赖发生变化时，自动重新生成缓存

## 缓存位置

- **缓存目录**: `~/.cache/evalcache/`
- **插件目录**: `~/.evalcache/`

## 故障排除

### evalcache 性能问题
如果 evalcache 本身成为性能瓶颈（占用 >50% 启动时间）：

```bash
# 1. 运行诊断工具
evalcache-diagnose

# 2. 手动清理缓存
evalcache-clear

# 3. 测试启动时间
time zsh -i -c exit

# 4. 检查大缓存文件
find ~/.zsh-evalcache -size +1k -ls
```

### 常见性能问题

#### 问题：_evalcache 函数调用次数过多
**症状**: zsh 性能分析显示 `_evalcache` 占用大量时间
**原因**: 缓存了太多快速工具，缓存开销超过收益
**解决**: 
- 只缓存真正慢的工具（>50ms）
- 快速工具直接使用 `eval`

#### 问题：缓存文件过大或损坏
**症状**: 启动时间反而变慢
**解决**:
```bash
# 检查大缓存文件
find ~/.zsh-evalcache -size +1k -ls

# 清理并重新生成
evalcache-clear
```

#### 问题：特定工具缓存有问题
**症状**: 某个工具初始化异常
**解决**:
```bash
# 刷新特定工具缓存
evalcache-refresh starship

# 或改为直接 eval
# 在配置中将 _evalcache 改为 eval
```

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
   export ZSH_EVALCACHE_DISABLE=1
   ```

2. **永久禁用**: 在 chezmoi 配置中设置
   ```toml
   [data.features]
   enable_evalcache = false
   ```

### 性能基准测试
```bash
# 测试当前启动时间
time zsh -i -c exit

# 使用 zsh 内置性能分析
zmodload zsh/zprof
# 在 .zshrc 开头添加，结尾添加 zprof

# 比较缓存前后性能
ZSH_EVALCACHE_DISABLE=1 time zsh -i -c exit  # 禁用缓存
time zsh -i -c exit                           # 启用缓存
```

### 查看缓存过程
首次启动时会看到缓存信息：

```bash
evalcache: starship initialization not cached, caching output of: starship init zsh
evalcache: pyenv initialization not cached, caching output of: pyenv init -
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