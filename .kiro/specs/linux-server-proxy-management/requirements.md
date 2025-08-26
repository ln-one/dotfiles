# Requirements Document

## Introduction

本功能旨在基于现有架构，通过最小化修改为Linux服务器远程环境增加代理管理支持。主要目标是利用现有的环境检测机制和模板系统，为server环境添加专门的代理管理功能，同时保持desktop环境的所有现有功能完全不变。采用小步慢走的方式，避免大规模重构，最大化利用当前架构优势。

## Requirements

### Requirement 1

**User Story:** 作为一个开发者，我希望能够在各种Linux服务器（Ubuntu、CentOS、Debian等）上使用chezmoi自动部署我的dotfiles配置，以便在远程环境中获得与本地一致的开发体验。

#### Acceptance Criteria

1. WHEN 用户通过SSH连接到Linux服务器并初始化chezmoi THEN 系统应该自动检测远程环境和发行版类型
2. WHEN 系统检测到缺失的依赖工具（如starship、fzf、zoxide等） THEN 系统应该通过chezmoi的run_once脚本自动下载和安装
3. WHEN 用户应用配置 THEN 系统应该使用默认设置覆盖（如默认starship配置）而不需要用户手动配置
4. WHEN 配置应用完成 THEN 用户应该能够立即使用所有配置的功能，包括shell别名、函数和工具
5. WHEN 在不同Linux发行版上部署 THEN 系统应该自动适配包管理器（apt、yum、dnf等）

### Requirement 2

**User Story:** 作为一个开发者，我希望系统能够根据环境类型自动选择合适的代理管理方式，在desktop环境使用现有的代理功能，在server环境使用适配服务器的代理管理方式。

#### Acceptance Criteria

1. WHEN 系统在desktop环境（非SSH连接） THEN 应该使用现有的代理管理功能（启动clash + GNOME系统代理设置）
2. WHEN 系统在server环境（SSH连接） THEN 应该使用服务器专用的代理管理方式
3. WHEN 在server环境执行proxyon THEN 系统应该cd到~/.config/clash目录并执行`nohup ./clash -f subscription.yaml > clash.log 2>&1 &`
4. WHEN 在server环境启动clash THEN 系统应该使用subscription.yaml配置文件并将输出重定向到clash.log
5. WHEN 在server环境执行proxyoff THEN 系统应该停止clash进程并清除环境变量
6. WHEN 在server环境执行proxystatus THEN 系统应该显示clash进程状态、日志文件状态和网络连接测试

### Requirement 3

**User Story:** 作为一个开发者，我希望代理配置读取功能能够兼容现有逻辑的同时，为server环境增加对subscription.yaml的支持，以便系统能够在不同环境中自动设置正确的代理参数。

#### Acceptance Criteria

1. WHEN 在desktop环境 THEN 系统应该保持现有的配置读取逻辑（优先环境变量，其次config.yaml）
2. WHEN 在server环境 THEN 系统应该优先检查~/.config/clash/subscription.yaml文件
3. IF 在server环境且subscription.yaml不存在 THEN 系统应该回退到检查config.yaml文件
4. WHEN 解析任何配置文件 THEN 系统应该提取port和socks-port信息用于设置环境变量
5. WHEN 在chezmoi模板中 THEN 系统应该能够根据环境类型读取相应的clash配置文件
6. IF 配置文件不存在或无法解析 THEN 系统应该使用默认端口配置（7890/7891）并给出相应的警告信息

### Requirement 4

**User Story:** 作为一个开发者，我希望远程环境配置能够与本地环境区分开来，以便在不同环境中使用适合的工具和设置。

#### Acceptance Criteria

1. WHEN 系统检测到SSH连接环境 THEN 系统应该自动应用远程环境配置
2. WHEN 在远程环境中 THEN 系统应该禁用GUI相关的功能和工具
3. WHEN 在远程环境中 THEN 系统应该使用轻量级的工具替代方案
4. WHEN 在远程环境中 THEN 系统应该优化性能设置以适应网络延迟

### Requirement 5

**User Story:** 作为一个开发者，我希望能够基于现有架构进行最小化修改，利用已有的环境检测和模板系统，以便保持系统的稳定性和一致性。

#### Acceptance Criteria

1. WHEN 实现新功能 THEN 应该复用现有的环境检测逻辑（SSH_CONNECTION检测）
2. WHEN 添加server代理功能 THEN 应该利用现有的.chezmoitemplates/environments/remote.sh文件结构
3. WHEN 修改配置读取 THEN 应该扩展现有的.chezmoi.toml.tmpl中的代理配置逻辑
4. WHEN 需要安装工具 THEN 应该复用现有的run_once脚本模式和包管理器检测逻辑
5. WHEN 添加新的代理函数 THEN 应该遵循现有的函数命名和结构模式
6. WHEN 进行任何修改 THEN 都应该保持向后兼容，不影响现有desktop功能

### Requirement 6

**User Story:** 作为一个开发者，我希望通过渐进式增强现有功能，为server环境添加稳定的代理管理，而不破坏现有的任何功能。

#### Acceptance Criteria

1. WHEN 在server环境启动clash THEN 应该使用nohup确保进程在后台持续运行
2. WHEN 用户断开SSH连接 THEN clash进程应该继续运行不受影响
3. WHEN 添加server代理功能 THEN 应该作为现有remote.sh的增强，而不是替换
4. WHEN 实现新功能 THEN 应该复用现有的错误处理和日志记录模式
5. WHEN 系统重启后 THEN 用户应该能够通过相同的proxyon命令重新启动代理服务

### Requirement 7

**User Story:** 作为一个开发者，我希望系统能够准确检测环境类型并保持现有desktop功能完全不变，同时为server环境提供专门的功能实现。

#### Acceptance Criteria

1. WHEN 系统检测到SSH_CONNECTION或SSH_CLIENT环境变量 THEN 应该识别为server/remote环境
2. WHEN 在desktop环境（无SSH连接） THEN 所有现有功能应该保持完全不变，包括现有的proxyon/proxyoff/proxystatus实现
3. WHEN 在server环境 THEN 应该加载专门的server版本的代理管理功能
4. WHEN 环境检测完成 THEN 系统应该只加载对应环境的功能，避免功能冲突
5. WHEN 用户在不同环境使用相同命令 THEN 应该执行对应环境的实现版本

### Requirement 8

**User Story:** 作为一个开发者，我希望能够监控server环境中代理服务的运行状态，以便及时发现和解决问题。

#### Acceptance Criteria

1. WHEN 在server环境执行proxystatus命令 THEN 系统应该显示clash进程的PID、运行时间和日志文件状态
2. WHEN 检查server代理状态 THEN 系统应该测试代理连接的可用性并显示clash.log的最新内容
3. WHEN server代理服务异常 THEN 系统应该显示具体的错误信息和建议解决方案
4. WHEN 查看server日志 THEN 用户应该能够方便地访问和查看clash.log文件内容
5. WHEN clash进程在后台运行 THEN proxystatus应该能够显示进程的资源使用情况