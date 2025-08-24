# Chezmoi 跨平台兼容性测试

## 概述

这个测试套件验证 Chezmoi 配置在不同平台和环境下的兼容性，确保配置能够在 Ubuntu、macOS 和 SSH 远程服务器环境中正常工作。

## 快速开始

```bash
# 测试当前平台
./tests/test-cross-platform-compatibility.sh --current

# 测试所有适用平台
./tests/test-cross-platform-compatibility.sh --all
```

## 测试脚本说明

### 1. `test-cross-platform-compatibility.sh` - 主测试脚本
统一的测试入口，可以运行所有平台的兼容性测试。

**使用方法：**
```bash
# 运行所有适用的测试
./tests/test-cross-platform-compatibility.sh

# 只运行当前平台测试
./tests/test-cross-platform-compatibility.sh --current

# 只运行 Ubuntu 测试
./tests/test-cross-platform-compatibility.sh --ubuntu

# 只运行 macOS 测试
./tests/test-cross-platform-compatibility.sh --macos

# 只运行 SSH 远程测试
./tests/test-cross-platform-compatibility.sh --ssh

# 预览将要执行的测试
./tests/test-cross-platform-compatibility.sh --dry-run

# 显示帮助信息
./tests/test-cross-platform-compatibility.sh --help
```

### 2. `test-ubuntu-environment.sh` - Ubuntu 环境测试
专门测试 Ubuntu 24.04 环境下的兼容性。

**测试内容：**
- 系统环境检测 (Linux/Ubuntu)
- Chezmoi 模板渲染
- Shell 配置兼容性
- apt 包管理器集成
- 现代 CLI 工具兼容性
- 环境变量和路径配置
- Shell 启动性能

### 3. `test-macos-environment.sh` - macOS 环境测试
专门测试 macOS 环境下的兼容性。

**测试内容：**
- macOS 系统检测 (Darwin)
- Homebrew 集成测试
- Chezmoi 模板渲染 (macOS 特定)
- Shell 配置兼容性 (Zsh/Bash)
- macOS 特定功能
- 现代 CLI 工具兼容性
- Shell 启动性能

### 4. `test-ssh-remote-environment.sh` - SSH 远程环境测试
专门测试 SSH 远程服务器环境下的兼容性。

**测试内容：**
- SSH 环境检测
- 远程环境限制和适配
- 基础工具可用性
- Chezmoi 远程配置
- 网络连接和下载能力
- Shell 性能 (远程优化)
- 安全和权限检查

## 测试要求对应关系

| 测试脚本 | 对应需求 | 说明 |
|---------|---------|------|
| `test-ubuntu-environment.sh` | Requirement 2.1 | Ubuntu 24.04 平台支持 |
| `test-macos-environment.sh` | Requirement 2.2 | macOS 平台支持 |
| `test-ssh-remote-environment.sh` | Requirement 2.3 | SSH 远程服务器环境支持 |

## 快速开始

### 1. 运行当前平台测试
```bash
cd /path/to/chezmoi-config
./tests/test-cross-platform-compatibility.sh --current
```

### 2. 运行所有测试 (推荐)
```bash
./tests/test-cross-platform-compatibility.sh --all
```

### 3. 查看测试结果
测试完成后，详细日志会保存在 `/tmp/chezmoi-*-test.log` 文件中。

## 测试输出说明

### 成功标识
- ✅ 绿色勾号：测试通过
- ⚠️  黄色警告：非关键问题，但需要注意
- ❌ 红色叉号：测试失败，需要修复

### 日志文件
- `/tmp/chezmoi-cross-platform-test.log` - 主测试日志
- `/tmp/chezmoi-ubuntu-test.log` - Ubuntu 测试日志
- `/tmp/chezmoi-macos-test.log` - macOS 测试日志
- `/tmp/chezmoi-ssh-test.log` - SSH 远程测试日志

## 常见问题排查

### 1. 权限错误
```bash
# 确保测试脚本有执行权限
chmod +x tests/test-*.sh
```

### 2. Chezmoi 未安装
```bash
# 安装 Chezmoi
curl -sfL https://get.chezmoi.io | sh
```

### 3. 模板渲染失败
检查 `.chezmoi.toml.tmpl` 文件语法是否正确：
```bash
chezmoi execute-template < .chezmoi.toml.tmpl
```

### 4. 网络连接问题
某些测试需要网络连接来验证下载能力，确保网络正常。

## 持续集成

这些测试脚本可以集成到 CI/CD 流程中：

```yaml
# GitHub Actions 示例
- name: 运行跨平台兼容性测试
  run: |
    chmod +x tests/test-*.sh
    ./tests/test-cross-platform-compatibility.sh --current
```

## 贡献指南

### 添加新测试
1. 在相应的测试脚本中添加新的测试函数
2. 确保测试函数有清晰的日志输出
3. 更新此 README 文档

### 测试脚本规范
- 使用 `set -euo pipefail` 确保错误处理
- 提供彩色输出和清晰的日志
- 包含错误计数和最终结果汇总
- 支持详细的日志文件输出

## 性能基准

### 预期性能指标
- Shell 启动时间：< 500ms (本地环境)
- Shell 启动时间：< 1000ms (远程环境)
- 模板渲染时间：< 100ms
- 完整测试套件：< 2 分钟

### 性能优化建议
如果测试显示性能问题：
1. 检查 Shell 配置是否过于复杂
2. 减少不必要的外部命令调用
3. 优化模板逻辑
4. 考虑延迟加载某些功能

## 支持的环境

### 操作系统
- ✅ Ubuntu 24.04 LTS
- ✅ macOS 12.0+ (Monterey)
- ✅ 其他 Linux 发行版 (基础支持)

### Shell
- ✅ Bash 4.0+
- ✅ Zsh 5.0+

### 环境类型
- ✅ 桌面环境
- ✅ SSH 远程服务器
- ✅ WSL (Windows Subsystem for Linux)
- ✅ 容器环境

## 测试结果示例

```bash
$ ./tests/test-cross-platform-compatibility.sh --current

========================================
Cross-Platform Compatibility Test
========================================
✅ Ubuntu 环境兼容性测试 通过
✅ 所有跨平台兼容性测试通过!

🎉 恭喜! Chezmoi 配置在所有测试平台上都能正常工作
📋 详细测试报告: /tmp/chezmoi-cross-platform-test.log
```

## 更新日志

- **v1.0.0** - 初始版本，支持 Ubuntu、macOS 和 SSH 环境测试
- 实现了完整的跨平台兼容性测试套件
- 包含性能测试和安全检查
- 支持详细的日志输出和错误报告