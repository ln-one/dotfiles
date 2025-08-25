# 代理配置系统

本项目实现了智能的代理配置系统，能够自动检测和配置代理设置，支持多种代理工具和使用场景。

## 🎯 设计原理

### 检测优先级
1. **环境变量优先**: 检测 `http_proxy`/`HTTP_PROXY`、`https_proxy`/`HTTPS_PROXY`、`socks_proxy`/`SOCKS_PROXY`
2. **Clash 配置其次**: 读取 `~/.config/clash/config.yaml` 配置文件
3. **平台限制**: 仅在 Linux/Windows 系统上启用 Clash 检测
4. **默认禁用**: 如果都没有找到，代理功能禁用

### 统一配置
所有检测逻辑集中在 `.chezmoi.toml.tmpl` 中处理，生成统一的模板变量供其他配置文件使用。

## 🔧 配置结构

### 模板变量
```toml
[data.proxy]
enabled = true          # 是否启用代理
source = "clash"        # 代理来源: "environment" 或 "clash"
host = "127.0.0.1"     # 代理主机
http_port = 7890       # HTTP 代理端口
socks_port = 7891      # SOCKS5 代理端口
```

### 应用范围
- **SSH 配置**: 自动为 GitHub、GitLab 等配置 SOCKS5 代理
- **环境变量**: 设置 `HTTP_PROXY`、`HTTPS_PROXY`、`SOCKS_PROXY`
- **终端工具**: curl、wget、git、npm、pip 等自动使用代理

## 📋 支持的代理工具

### Clash 系列
- **标准 Clash**: `~/.config/clash/config.yaml`
- **Clash Verge**: `~/.config/clash-verge/config.yaml`
- **Mihomo**: `~/.config/mihomo/config.yaml`

### 环境变量
```bash
# HTTP 代理
export http_proxy=http://127.0.0.1:7890
export HTTP_PROXY=http://127.0.0.1:7890

# HTTPS 代理
export https_proxy=http://127.0.0.1:7890
export HTTPS_PROXY=http://127.0.0.1:7890

# SOCKS 代理
export socks_proxy=socks5://127.0.0.1:7891
export SOCKS_PROXY=socks5://127.0.0.1:7891
```

## 🚀 使用方法

### 自动配置
1. **安装 Clash**: 将配置文件放在 `~/.config/clash/config.yaml`
2. **应用配置**: 运行 `chezmoi apply`
3. **重新加载**: `source ~/.bashrc` 或 `source ~/.zshrc`

### 手动配置
```bash
# 设置环境变量
export http_proxy=http://127.0.0.1:8080
export socks_proxy=socks5://127.0.0.1:1080

# 重新生成配置
chezmoi apply
```

### 验证配置
```bash
# 查看代理配置
chezmoi data | grep -A 10 proxy

# 测试代理连接
curl -I --proxy socks5://127.0.0.1:7891 https://google.com
```

## 🔍 配置示例

### Clash 配置文件
```yaml
# ~/.config/clash/config.yaml
port: 7890              # HTTP 代理端口
socks-port: 7891        # SOCKS5 代理端口
allow-lan: false
mode: Rule
log-level: info
external-controller: 127.0.0.1:9090
```

### 生成的环境变量
```bash
# 自动生成在 ~/.bashrc 或 ~/.zshrc 中
export HTTP_PROXY="http://127.0.0.1:7890"
export HTTPS_PROXY="http://127.0.0.1:7890"
export SOCKS_PROXY="socks5://127.0.0.1:7891"
export NO_PROXY="localhost,127.0.0.1,::1,.local"

# 小写版本 (兼容性)
export http_proxy="$HTTP_PROXY"
export https_proxy="$HTTPS_PROXY"
export socks_proxy="$SOCKS_PROXY"
export no_proxy="$NO_PROXY"
```

### SSH 配置
```ssh
# 自动生成在 ~/.ssh/config 中
Host github.com
    HostName ssh.github.com
    User git
    Port 443
    IdentityAgent ~/.1password/agent.sock
    ProxyCommand nc -X 5 -x 127.0.0.1:7891 %h %p
```

## 🛠️ 故障排除

### 代理未生效
1. **检查配置**: `chezmoi data | grep proxy`
2. **验证文件**: 确认 Clash 配置文件存在且格式正确
3. **重新应用**: `chezmoi apply && source ~/.bashrc`

### SSH 代理连接失败
1. **测试代理**: `nc -zv 127.0.0.1 7891`
2. **检查 Clash**: 确认 Clash 正在运行
3. **验证配置**: `ssh -T git@github.com`

### 环境变量冲突
1. **清除旧变量**: `unset http_proxy https_proxy socks_proxy`
2. **重新加载**: `source ~/.bashrc`
3. **检查优先级**: 环境变量优先于 Clash 配置

## 🔧 高级配置

### 自定义代理路径
```bash
# 设置自定义 Clash 配置路径
export CLASH_CONFIG_PATH="/path/to/custom/config.yaml"
chezmoi apply
```

### 禁用代理检测
```toml
# 在 .chezmoi.toml.tmpl 中
[data.features]
enable_proxy = false
```

### NO_PROXY 配置
系统自动设置以下地址不使用代理：
- `localhost` - 本地主机
- `127.0.0.1` - IPv4 回环地址
- `::1` - IPv6 回环地址
- `.local` - 本地网络域名

可以通过环境变量添加更多排除地址：
```bash
export NO_PROXY="localhost,127.0.0.1,::1,.local,192.168.0.0/16"
```

## 🌍 跨平台支持

### Linux
- ✅ 完整支持 Clash 配置检测
- ✅ 环境变量检测
- ✅ SSH 代理配置

### Windows
- ✅ 支持 Clash 配置检测
- ✅ 环境变量检测
- ⚠️ SSH 代理需要安装 `nc` 工具

### macOS
- ❌ 默认禁用 Clash 检测 (可手动启用)
- ✅ 环境变量检测
- ✅ SSH 代理配置

## 📚 相关文档

- [SSH 配置](ssh-configuration.md)
- [环境变量管理](environment-variables.md)
- [跨平台兼容性](cross-platform-compatibility.md)