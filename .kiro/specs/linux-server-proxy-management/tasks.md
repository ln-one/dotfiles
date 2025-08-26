# Implementation Plan

- [x] 1. 修复现有远程环境配置问题
  - 修复zshrc中的函数定义错误和别名冲突
  - 确保starship在远程环境中能够正确安装
  - 验证基础shell配置在远程环境中正常工作
  - _Requirements: 1.1, 1.4_

- [x] 2. 扩展chezmoi配置读取逻辑支持subscription.yaml
  - 修改.chezmoi.toml.tmpl中的代理配置读取部分
  - 在远程环境检测中添加对subscription.yaml的优先支持
  - 保持desktop环境的现有配置读取逻辑完全不变
  - 添加配置文件存在性检查和错误处理
  - _Requirements: 3.1, 3.2, 3.5_

- [ ] 3. 增强远程环境代理管理函数
  - 扩展.chezmoitemplates/environments/remote.sh中的代理函数
  - 实现server专用的proxyon函数（使用nohup和subscription.yaml）
  - 实现server专用的proxyoff函数（停止clash进程和清理环境变量）
  - 实现server专用的proxystatus函数（显示进程状态和日志信息）
  - _Requirements: 2.3, 2.4, 2.5, 2.6_

- [ ] 4. 添加自动依赖安装支持
  - 创建或扩展run_once脚本以自动安装starship
  - 添加对不同Linux发行版包管理器的检测和支持
  - 确保在远程环境中能够自动下载和安装缺失的工具
  - 使用chezmoi的条件模板避免在desktop环境重复安装
  - _Requirements: 1.2, 1.5, 5.4_

- [ ] 5. 实现环境隔离和功能分离
  - 确保desktop环境继续使用现有的proxy-functions.sh
  - 确保remote环境使用扩展后的remote.sh中的代理函数
  - 验证环境检测机制能够正确区分desktop和server环境
  - 测试函数名称不冲突，环境变量正确设置
  - _Requirements: 7.1, 7.2, 7.3, 7.4_

- [ ] 6. 添加配置文件解析和端口检测
  - 实现从subscription.yaml中解析端口配置的逻辑
  - 添加对config.yaml的回退支持
  - 实现默认端口配置（7890/7891）作为最后备选
  - 在chezmoi模板中正确设置代理相关的数据变量
  - _Requirements: 3.3, 3.4_

- [ ] 7. 实现进程管理和日志处理
  - 在proxyon中实现nohup启动clash进程的逻辑
  - 在proxyoff中实现正确停止clash进程的逻辑
  - 在proxystatus中添加日志文件检查和显示功能
  - 添加进程状态检测和PID管理
  - _Requirements: 6.1, 6.2, 6.5, 8.1, 8.2_

- [ ] 8. 添加错误处理和用户友好提示
  - 为配置文件不存在的情况添加清晰的错误信息
  - 为clash二进制不存在的情况添加安装指导
  - 为端口冲突添加检测和解决建议
  - 为权限问题添加检查和修复提示
  - _Requirements: 8.3, 8.4_

- [ ] 9. 本地测试和验证
  - 测试配置读取逻辑的扩展不影响desktop环境
  - 验证环境检测机制的准确性
  - 测试chezmoi模板的条件逻辑正确性
  - 确保所有现有功能保持完全不变
  - _Requirements: 7.5_

- [ ] 10. 服务器环境手动测试（需要在实际服务器上执行）
  - 在Ubuntu 24.04 Server上测试chezmoi apply的完整流程
  - 验证starship和其他工具的自动安装
  - 测试server环境的代理函数功能
  - 验证nohup进程管理和日志记录
  - 测试网络连接和代理功能
  - _Requirements: 2.1, 2.2, 6.1, 8.1, 8.5_

- [ ] 11. 集成测试和问题修复
  - 根据服务器测试结果修复发现的问题
  - 优化配置和函数实现
  - 确保在不同Linux发行版上的兼容性
  - 验证所有需求都得到正确实现
  - _Requirements: 1.5, 5.6_

- [ ] 12. 文档更新和使用指南
  - 更新README.md中的代理管理部分
  - 添加服务器环境的使用说明
  - 创建故障排除指南
  - 提供配置示例和最佳实践
  - _Requirements: 8.4_