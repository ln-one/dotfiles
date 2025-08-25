# fnm 使用指南

fnm (Fast Node Manager) 是一个用 Rust 编写的快速 Node.js 版本管理器，是 nvm 的现代化替代品。

## 为什么选择 fnm

- **速度快**: 比 nvm 快 40 倍以上
- **跨平台**: 支持 macOS、Linux 和 Windows
- **自动切换**: 支持 `.nvmrc` 文件自动切换版本
- **内存占用小**: 启动时间几乎为零

## 基本使用

### 安装 Node.js 版本

```bash
# 安装最新 LTS 版本
fnm install --lts

# 安装特定版本
fnm install 18.17.0
fnm install 20.5.0

# 安装最新版本
fnm install latest
```

### 切换 Node.js 版本

```bash
# 使用特定版本
fnm use 18.17.0

# 使用 LTS 版本
fnm use --lts

# 如果版本不存在则自动安装
fnm use --install-if-missing 20.5.0
```

### 设置默认版本

```bash
# 设置默认版本
fnm default 18.17.0

# 设置 LTS 为默认
fnm default --lts
```

### 查看版本信息

```bash
# 列出已安装的版本
fnm list

# 列出可用的远程版本
fnm list-remote

# 查看当前使用的版本
fnm current

# 查看 fnm 版本
fnm --version
```

## 自动版本切换

fnm 支持根据 `.nvmrc` 文件自动切换 Node.js 版本：

```bash
# 在项目根目录创建 .nvmrc 文件
echo "18.17.0" > .nvmrc

# 或者使用 LTS
echo "lts/*" > .nvmrc

# 进入目录时自动切换版本 (需要配置 shell)
cd your-project  # 自动切换到 .nvmrc 指定的版本
```

## Shell 集成

fnm 已经在你的 shell 配置中自动设置，支持：

- 自动补全
- 目录切换时自动版本切换
- 快速启动

配置位置：`.chezmoitemplates/core/oh-my-zsh-config.sh`

## 常用命令速查

| 命令 | 说明 |
|------|------|
| `fnm install --lts` | 安装最新 LTS 版本 |
| `fnm use <version>` | 切换到指定版本 |
| `fnm default <version>` | 设置默认版本 |
| `fnm list` | 列出已安装版本 |
| `fnm list-remote` | 列出可用版本 |
| `fnm current` | 显示当前版本 |
| `fnm uninstall <version>` | 卸载指定版本 |

## 迁移从 nvm

如果你之前使用 nvm，可以这样迁移：

1. 查看 nvm 已安装的版本：`nvm list`
2. 使用 fnm 安装相同版本：`fnm install <version>`
3. 设置默认版本：`fnm default <version>`
4. 删除 nvm（可选）

## 性能对比

| 操作 | nvm | fnm |
|------|-----|-----|
| 启动时间 | ~200ms | ~5ms |
| 版本切换 | ~100ms | ~10ms |
| 内存占用 | ~10MB | ~1MB |

## 故障排除

### fnm 命令未找到

```bash
# 检查 PATH
echo $PATH

# 手动添加到 PATH
export PATH="$HOME/.local/bin:$PATH"

# 重新加载 shell 配置
source ~/.zshrc
```

### 版本切换不生效

```bash
# 检查当前版本
fnm current

# 重新初始化 fnm
eval "$(fnm env --use-on-cd)"
```

### .nvmrc 文件不生效

确保 shell 配置中包含 `--use-on-cd` 选项：

```bash
eval "$(fnm env --use-on-cd)"
```

## 更多信息

- [fnm GitHub 仓库](https://github.com/Schniz/fnm)
- [官方文档](https://github.com/Schniz/fnm/blob/master/docs/commands.md)