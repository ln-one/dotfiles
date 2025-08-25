# 用户配置覆盖机制使用指南

本目录包含用户配置层的模板文件，允许用户在不修改源代码的情况下自定义配置。

## 配置优先级

配置按以下优先级加载（数字越大优先级越高）：

1. **核心配置层** - 所有环境通用的基础功能
2. **平台配置层** - 操作系统特定的配置
3. **环境配置层** - 运行环境特定的配置
4. **用户配置层** - 用户个人配置（最高优先级）

## 用户配置文件

### 内部配置文件（通过 chezmoi 管理）

#### `user-overrides.sh`
- 用户个人配置覆盖模板
- 包含常用的配置选项和示例
- 通过 chezmoi 模板系统管理

#### `local-config.sh`
- 本地环境特定配置模板
- 支持通过 chezmoi 数据变量配置
- 自动检测本地环境能力

### 外部配置文件（不通过 chezmoi 管理）

外部配置文件按以下优先级加载：

1. `/etc/chezmoi/config.sh` - 系统级配置（最低优先级）
2. `$HOME/.config/chezmoi/config.sh` - 用户配置目录
3. `$HOME/.chezmoi.local.sh` - 用户主目录配置
4. `$(pwd)/.chezmoi.local.sh` - 项目特定配置（最高优先级）

## 使用方法

### 方法一：使用示例配置文件

```bash
# 复制示例配置到用户主目录
cp .chezmoitemplates/local/sample-external-config.sh ~/.chezmoi.local.sh

# 编辑配置文件
vim ~/.chezmoi.local.sh
```

### 方法二：通过 chezmoi 数据配置

在 `.chezmoi.toml` 中添加本地配置数据：

```toml
[data.local]
  machine_name = "my-laptop"
  work_directory = "/home/user/work"
  projects_directory = "/home/user/projects"

  [data.local.proxy]
    enabled = true
    host = "127.0.0.1"
    http_port = 7890
    socks_port = 7891

  [data.local.development]
    node_version = "20"
    python_version = "3.11"
    go_version = "1.21"

  [data.local.tools]
    editor = "code"
    browser = "firefox"
    terminal = "ghostty"

  [data.local.custom_paths]
    - "/opt/custom/bin"
    - "/home/user/scripts"
```

### 方法三：通过环境变量配置

```bash
# 设置环境变量进行最终配置覆盖
export CHEZMOI_USER_CONFIG='export PREFERRED_EDITOR="vim"; alias ll="ls -la"'
```

## 配置示例

### 个人信息配置

```bash
# 在 ~/.chezmoi.local.sh 中
export GIT_USER_NAME="张三"
export GIT_USER_EMAIL="zhangsan@example.com"
```

### 代理配置

```bash
# 在 ~/.chezmoi.local.sh 中
export PROXY_ENABLED=true
export PROXY_HOST="127.0.0.1"
export PROXY_HTTP_PORT=7890
export PROXY_SOCKS_PORT=7891
```

### 工具偏好设置

```bash
# 在 ~/.chezmoi.local.sh 中
export PREFERRED_EDITOR="code"
export PREFERRED_SHELL="zsh"
export PREFERRED_TERMINAL="ghostty"
```

### 自定义别名和函数

```bash
# 在 ~/.chezmoi.local.sh 中
alias myproject="cd ~/projects/my-important-project"
alias deploy="./scripts/deploy.sh"

# 自定义函数
quick_backup() {
    tar -czf "backup-$(date +%Y%m%d).tar.gz" "$1"
}
```

### 环境特定配置

```bash
# 在 ~/.chezmoi.local.sh 中
case "${CHEZMOI_ENVIRONMENT:-desktop}" in
    "desktop")
        export ENABLE_GUI_TOOLS=true
        ;;
    "remote")
        export ENABLE_GUI_TOOLS=false
        export PROXY_ENABLED=false
        ;;
esac
```

## 配置验证

加载配置后，可以通过以下方式验证：

```bash
# 检查配置是否加载
echo $CHEZMOI_CONFIG_LOADED

# 查看配置层信息
echo $CHEZMOI_CONFIG_LAYERS

# 查看当前平台和环境
echo $CHEZMOI_PLATFORM
echo $CHEZMOI_ENVIRONMENT
```

## 故障排除

### 配置不生效

1. 检查文件路径是否正确
2. 检查文件权限是否可读
3. 检查语法是否正确
4. 查看是否被其他配置覆盖

### 调试配置加载

```bash
# 在配置文件中添加调试信息
echo "加载配置文件: ${BASH_SOURCE[0]}"

# 检查变量是否设置
echo "PREFERRED_EDITOR: $PREFERRED_EDITOR"
```

### 重置配置

如果配置出现问题，可以：

1. 重命名或删除外部配置文件
2. 重新运行 `chezmoi apply`
3. 使用默认配置

## 注意事项

1. **优先级**：后加载的配置会覆盖先加载的配置
2. **语法**：确保 shell 脚本语法正确
3. **安全**：不要在配置文件中存储敏感信息
4. **备份**：修改前备份重要配置
5. **测试**：在新终端中测试配置更改