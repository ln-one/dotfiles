# Design Document

## Overview

本设计基于现有架构进行最小化修改，通过扩展现有的环境检测机制和模板系统，为Linux服务器远程环境添加专门的代理管理功能。设计原则是保持所有现有功能完全不变，通过渐进式增强的方式添加新功能。

### 设计原则
- **最小化修改**: 复用现有代码结构和逻辑
- **向后兼容**: 保持所有现有功能不变
- **环境隔离**: 通过环境检测确保功能不冲突
- **渐进增强**: 在现有基础上添加新功能

## Architecture

### 现有架构分析
当前系统已经具备完善的环境检测和配置管理机制：

1. **环境检测**: `.chezmoi.toml.tmpl`中通过`SSH_CONNECTION`/`SSH_CLIENT`检测远程环境
2. **环境配置**: `.chezmoitemplates/environments/remote.sh`提供远程环境专用配置
3. **平台功能**: `.chezmoitemplates/platforms/linux/proxy-functions.sh`提供desktop代理功能
4. **配置读取**: `.chezmoi.toml.tmpl`中已有clash配置读取逻辑

### 扩展设计
基于现有架构，通过以下方式进行扩展：

```
现有架构:
├── .chezmoi.toml.tmpl (环境检测 + 配置读取)
├── .chezmoitemplates/environments/remote.sh (远程环境配置)
└── .chezmoitemplates/platforms/linux/proxy-functions.sh (desktop代理功能)

扩展后:
├── .chezmoi.toml.tmpl (扩展: 支持subscription.yaml读取)
├── .chezmoitemplates/environments/remote.sh (扩展: 添加server代理函数)
└── .chezmoitemplates/platforms/linux/proxy-functions.sh (保持不变)
```

## Components and Interfaces

### 1. 配置读取组件扩展 (.chezmoi.toml.tmpl)

**现有逻辑**: 
- 检测环境变量代理
- 读取`~/.config/clash/config.yaml`

**扩展逻辑**:
- 在server环境中优先检测`~/.config/clash/subscription.yaml`
- 保持desktop环境的现有逻辑不变

```go-template
{{- if or (env "SSH_CONNECTION") (env "SSH_CLIENT") }}
  {{- $subscription_config := joinPath .chezmoi.homeDir ".config/clash/subscription.yaml" }}
  {{- if stat $subscription_config }}
    {{- $clash := include $subscription_config | fromYaml }}
    # Server环境使用subscription.yaml
  {{- else }}
    # 回退到config.yaml
  {{- end }}
{{- else }}
  # Desktop环境保持现有逻辑
{{- end }}
```

### 2. 远程环境代理函数 (.chezmoitemplates/environments/remote.sh)

**现有功能**: 
- 轻量级环境变量设置
- 基础的proxy函数占位符

**扩展功能**:
- 添加server专用的代理管理函数
- 保持现有函数结构和命名约定

```bash
# 扩展现有的remote.sh文件
# 在现有的proxy函数基础上增强功能

proxyon() {
    echo "🔗 启用服务器代理..."
    
    # Server专用逻辑: 使用subscription.yaml + nohup
    if [[ -d "$HOME/.config/clash" ]] && [[ -f "$HOME/.config/clash/clash" ]]; then
        cd "$HOME/.config/clash"
        nohup ./clash -f subscription.yaml > clash.log 2>&1 &
        # 设置环境变量...
    fi
}
```

### 3. 环境检测和加载机制

**现有机制**: 通过chezmoi模板条件加载不同环境配置

**保持不变**: 
- Desktop环境继续加载`proxy-functions.sh`
- Remote环境继续加载`remote.sh`
- 通过SSH_CONNECTION检测环境类型

## Data Models

### 代理配置数据结构

**现有结构** (保持不变):
```toml
[data.proxy]
enabled = true
source = "clash"
host = "127.0.0.1"
http_port = 7890
socks_port = 7891
```

**扩展结构** (仅在server环境):
```toml
[data.proxy]
enabled = true
source = "subscription"  # 新增source类型
config_file = "subscription.yaml"  # 新增配置文件字段
log_file = "clash.log"  # 新增日志文件字段
```

### 配置文件支持

**Desktop环境** (保持不变):
- 优先级: 环境变量 > config.yaml > 默认值

**Server环境** (新增):
- 优先级: 环境变量 > subscription.yaml > config.yaml > 默认值

## Error Handling

### 现有错误处理 (保持不变)
- Desktop环境的所有错误处理逻辑保持不变
- 继续使用现有的错误消息和处理方式

### 新增错误处理 (Server环境)
- 配置文件不存在: 提供清晰的错误信息和解决建议
- clash二进制不存在: 指导用户安装或配置路径
- 端口冲突: 检测端口占用并提供解决方案
- 权限问题: 检查文件权限并提供修复建议

```bash
# 错误处理示例
if [[ ! -f "$HOME/.config/clash/subscription.yaml" ]]; then
    echo "⚠️  配置文件不存在: $HOME/.config/clash/subscription.yaml"
    echo "💡 请确保配置文件存在或使用 config.yaml 作为备选"
    return 1
fi
```

## Testing Strategy

### 本地测试 (开发环境)
- 验证desktop环境功能完全不受影响
- 测试配置文件读取逻辑的扩展
- 验证环境检测机制的准确性

### 远程测试 (需要手动测试)
由于当前在本地环境，以下测试需要在实际的Linux服务器上手动进行：

#### 测试环境准备
1. **Ubuntu 24.04 Server**: 主要测试目标
2. **其他Linux发行版**: CentOS、Debian等 (可选)
3. **SSH连接**: 确保通过SSH连接触发远程环境检测

#### 手动测试清单
1. **环境检测测试**:
   ```bash
   # 在服务器上验证环境检测
   echo $SSH_CONNECTION
   chezmoi data | grep environment
   ```

2. **配置文件读取测试**:
   ```bash
   # 测试subscription.yaml读取
   ls -la ~/.config/clash/
   chezmoi data | grep proxy
   ```

3. **代理功能测试**:
   ```bash
   # 测试server代理函数
   proxyon
   proxystatus
   proxyoff
   ```

4. **进程管理测试**:
   ```bash
   # 验证nohup和后台运行
   ps aux | grep clash
   tail -f ~/.config/clash/clash.log
   ```

5. **网络连接测试**:
   ```bash
   # 测试代理连接
   curl --proxy socks5://127.0.0.1:7891 httpbin.org/ip
   ```

### 实际问题分析
基于当前服务器状态，发现以下问题需要解决：
1. **Starship未安装**: 需要自动安装starship
2. **函数定义错误**: zshrc中存在函数定义问题
3. **别名冲突**: alias和function定义冲突

### 测试数据准备
为了进行完整测试，需要在服务器上准备：
- `~/.config/clash/clash` 二进制文件
- `~/.config/clash/subscription.yaml` 配置文件
- 有效的代理订阅配置
- 修复现有的zshrc配置问题

### 回归测试
确保现有功能不受影响：
- Desktop环境的所有代理功能正常
- 现有的配置读取逻辑正常
- 其他环境配置不受影响

## Implementation Phases

### Phase 1: 配置读取扩展
- 扩展`.chezmoi.toml.tmpl`中的代理配置读取逻辑
- 添加对subscription.yaml的支持
- 保持向后兼容

### Phase 2: 远程环境代理函数
- 扩展`.chezmoitemplates/environments/remote.sh`
- 添加server专用的proxyon/proxyoff/proxystatus函数
- 实现nohup启动和日志管理

### Phase 3: 测试和优化
- 本地测试配置读取和环境检测
- **手动测试**: 在实际服务器环境中测试所有功能
- 根据测试结果进行优化和修复

### Phase 4: 文档和完善
- 更新相关文档
- 添加使用示例和故障排除指南
- 确保所有功能稳定可靠

## 风险评估

### 低风险
- 配置读取扩展: 基于现有逻辑，风险很低
- 环境检测: 复用现有机制，风险很低

### 中等风险
- 远程环境函数扩展: 需要仔细测试以避免冲突

### 需要注意的点
- 确保desktop和server环境的函数不会相互干扰
- 验证nohup进程管理的稳定性
- 测试不同Linux发行版的兼容性

## 部署策略

### 渐进式部署
1. 首先部署配置读取扩展
2. 然后部署远程环境函数
3. 最后进行完整的集成测试

### 回滚计划
- 保持所有现有文件的备份
- 确保可以快速回滚到当前状态
- 提供清晰的回滚步骤文档