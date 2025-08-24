# Zoxide 智能目录跳转使用指南

Zoxide 是一个智能的目录跳转工具，比传统的 `z` 更快更智能。它会学习你的使用习惯，让目录导航变得更加高效。

## 基本用法

### 跳转到目录
```bash
z <目录名>          # 跳转到匹配的目录
z proj              # 跳转到包含 "proj" 的目录
z doc               # 跳转到包含 "doc" 的目录
```

### 交互式选择
```bash
zi                  # 打开交互式目录选择器 (需要 fzf)
```

### 返回上一个目录
```bash
z -                 # 返回上一个访问的目录
```

### 查询数据库
```bash
zoxide query <关键词>    # 查询匹配的目录
zoxide query --list     # 列出所有记录的目录
zoxide query --score    # 显示目录及其访问分数
```

## 自定义函数

我们的配置还包含了一些有用的自定义函数：

### 项目跳转
```bash
proj <项目名>       # 快速跳转到项目目录
proj                # 显示可用的项目列表
```

### 查看热门目录
```bash
ztop                # 显示最常访问的 10 个目录
```

### 清理数据库
```bash
zclean              # 清理不存在的目录记录
```

## 工作原理

1. **学习阶段**: 使用 `cd` 命令正常导航，zoxide 会在后台记录你的访问模式
2. **智能匹配**: 使用 `z` 命令时，zoxide 会根据访问频率和最近访问时间进行智能匹配
3. **模糊搜索**: 支持部分匹配，不需要输入完整的目录名

## 配置选项

Zoxide 的配置通过环境变量控制：

```bash
export _ZO_DATA_DIR="$HOME/.local/share"    # 数据存储目录
export _ZO_ECHO=1                           # 显示跳转的目录
export _ZO_RESOLVE_SYMLINKS=1               # 解析符号链接
```

## 与其他工具集成

- **fzf**: 自动集成，提供交互式选择功能
- **shell**: 支持 bash、zsh、fish 等多种 shell
- **编辑器**: 可以与 vim、emacs 等编辑器集成

## 常见问题

### Q: 如何重置 zoxide 数据库？
```bash
rm -rf ~/.local/share/zoxide
```

### Q: 如何导入现有的 z 数据库？
```bash
zoxide import --from z ~/.z
```

### Q: 如何禁用某个目录的记录？
将目录添加到 `_ZO_EXCLUDE_DIRS` 环境变量中。

## 性能对比

相比传统的 `z` 工具：
- 🚀 启动速度快 10-100 倍
- 🧠 更智能的匹配算法
- 🔧 更好的配置选项
- 🛡️ 更安全的实现

## 更多信息

- [官方文档](https://github.com/ajeetdsouza/zoxide)
- [配置示例](https://github.com/ajeetdsouza/zoxide/wiki)