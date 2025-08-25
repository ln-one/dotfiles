# 1Password 集成使用指南

本文档介绍如何在 chezmoi 配置中使用 1Password 来管理敏感信息和密钥。

## 功能概述

- 🔐 自动从 1Password 获取密钥和敏感信息
- 🚀 与 chezmoi 完全集成，无需手动运行额外命令
- 🛡️ 安全的密钥管理，不在版本控制中存储明文密钥
- 🔄 支持 SSH Agent 集成

## 前置要求

1. **1Password 账户** - 需要有效的 1Password 订阅
2. **1Password 应用** - 桌面版或浏览器扩展
3. **1Password CLI** - 会自动安装

## 设置步骤

### 1. 启用 1Password 功能

在 `.chezmoi.toml` 中确保启用了 1Password 功能：

```toml
[data.features]
  enable_1password = true
```

### 2. 安装和配置

运行 chezmoi 应用配置：

```bash
chezmoi apply
```

这会自动：
- 安装 1Password CLI（如果未安装）
- 设置 SSH Agent 集成
- 生成密钥文件

### 3. 登录 1Password

首次使用需要登录：

```bash
op signin
```

### 4. 验证配置

检查密钥是否正确加载：

```bash
# 检查环境变量
echo $OPENAI_API_KEY
echo $DB_USER

# 检查 SSH Agent
ssh-add -l
```

## 密钥配置

### 当前支持的密钥

已配置的密钥引用：

- `OPENAI_API_KEY` - OpenAI API 密钥
- `GOOGLE_CLOUD_PROJECT` - Google Cloud 项目 ID
- `DB_USER`, `DB_PASS`, `DB_HOST`, `DB_PORT` - MySQL 数据库连接

### 添加新密钥

1. **在 1Password 中存储密钥**
   - 创建新的登录项或安全笔记
   - 记录 vault/item/field 路径

2. **在 .chezmoi.toml.tmpl 中添加密钥读取**
   ```toml
   [data.secrets]
     new_secret = "{{ onepasswordRead "op://Vault/Item/field" }}"
   ```

3. **在模板文件中使用 chezmoi 变量**
   ```bash
   # dot_secrets.tmpl
   export NEW_SECRET="{{ .secrets.new_secret }}"
   
   # other_config.tmpl
   some_config = "{{ .secrets.new_secret }}"
   ```

4. **应用更改**
   ```bash
   chezmoi apply
   ```

### 1Password 引用格式

```
op://Vault/Item/Field
```

示例：
- `op://Work/OpenAI-API-Key/api-key`
- `op://Personal/Database/password`
- `op://Shared/AWS-Keys/access_key_id`

## SSH Agent 集成

### 自动配置

SSH Agent 会自动配置，支持：
- macOS: `~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock`
- Linux: `~/.1password/agent.sock`

### 使用 SSH 密钥

1. 在 1Password 中添加 SSH 密钥
2. 启用 SSH Agent 功能
3. SSH 连接会自动使用 1Password 中的密钥

## 故障排除

### 常见问题

1. **密钥未加载**
   ```bash
   # 检查 1Password CLI 状态
   op whoami
   
   # 重新登录
   op signin
   
   # 重新应用配置
   chezmoi apply
   ```

2. **SSH Agent 不工作**
   ```bash
   # 检查 SSH Agent 套接字
   ls -la ~/.1password/agent.sock  # Linux
   ls -la ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock  # macOS
   
   # 检查环境变量
   echo $SSH_AUTH_SOCK
   ```

3. **权限问题**
   ```bash
   # 检查密钥文件权限
   ls -la ~/.secrets
   
   # 应该是 600 (仅用户可读写)
   ```

### 调试命令

```bash
# 检查 1Password CLI 版本
op --version

# 列出可用的 vaults
op vault list

# 列出指定 vault 中的项目
op item list --vault Work

# 测试密钥读取
op read "op://Work/OpenAI-API-Key/api-key"
```

## 性能优化

为了避免重复调用 1Password CLI（会导致性能问题），遵循以下原则：

1. **统一读取** - 所有 `onepasswordRead` 调用都在 `dot_secrets.tmpl` 中
2. **环境变量引用** - 其他文件使用 `{{ env "VARIABLE_NAME" }}` 引用
3. **避免重复** - 同一个密钥只读取一次，多处使用环境变量

### 正确示例
```toml
# .chezmoi.toml.tmpl - 统一读取
[data.secrets]
  api_key = "{{ onepasswordRead "op://Work/API/key" }}"
```

```bash
# dot_secrets.tmpl - 使用 chezmoi 变量
export API_KEY="{{ .secrets.api_key }}"

# other_config.tmpl - 使用 chezmoi 变量
api_key = "{{ .secrets.api_key }}"
```

### 错误示例
```bash
# 避免在多个文件中重复调用 onepasswordRead
config1 = "{{ onepasswordRead "op://Work/API/key" }}"  # ❌
config2 = "{{ onepasswordRead "op://Work/API/key" }}"  # ❌
```

## 安全注意事项

1. **密钥文件权限** - 自动设置为 600 (仅用户可读写)
2. **版本控制** - 密钥文件已添加到 `.chezmoiignore`
3. **会话管理** - 1Password CLI 会话会自动管理
4. **最小权限** - 仅读取必要的密钥字段
5. **性能考虑** - 避免重复的 1Password 调用

## 高级配置

### 条件密钥加载

可以根据环境条件加载不同的密钥：

```bash
{{- if eq .environment "production" }}
export API_KEY="{{ onepasswordRead "op://Work/Prod-API/key" }}"
{{- else }}
export API_KEY="{{ onepasswordRead "op://Work/Dev-API/key" }}"
{{- end }}
```

### 多 Vault 支持

支持从不同的 vault 读取密钥：

```bash
export WORK_SECRET="{{ onepasswordRead "op://Work/Secret/value" }}"
export PERSONAL_SECRET="{{ onepasswordRead "op://Personal/Secret/value" }}"
```

## 相关文件

- `dot_secrets.tmpl` - 密钥模板文件
- `run_once_install-1password-cli.sh.tmpl` - CLI 安装脚本
- `run_once_setup-1password-ssh.sh.tmpl` - SSH Agent 设置脚本
- `.chezmoitemplates/environment.sh` - 环境变量配置

## 参考链接

- [1Password CLI 文档](https://developer.1password.com/docs/cli/)
- [Chezmoi 1Password 集成](https://www.chezmoi.io/user-guide/password-managers/1password/)
- [1Password SSH Agent](https://developer.1password.com/docs/ssh/)