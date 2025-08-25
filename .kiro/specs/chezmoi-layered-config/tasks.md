# Implementation Plan

- [x] 1. 创建分层目录结构
  - 在 `.chezmoitemplates/` 下创建 `core/`, `platforms/linux/`, `platforms/darwin/`, `environments/`, `local/` 目录
  - 验证目录结构创建成功
  - _Requirements: 1.1, 2.1_

- [x] 2. 移动核心配置文件到 core 层
- [x] 2.1 移动通用配置文件到 core 目录
  - 移动 `environment.sh`, `aliases.sh`, `basic-functions.sh` 到 `core/`
  - 移动 `starship-config.sh`, `oh-my-zsh-config.sh`, `zsh-performance-tweaks.sh` 到 `core/`
  - 移动 `fzf-config.sh`, `zoxide-config.sh` 到 `core/`
  - _Requirements: 1.1, 1.2_

- [x] 2.2 验证核心配置文件移动
  - 检查所有文件是否正确移动到 `core/` 目录
  - 验证文件内容保持不变
  - _Requirements: 1.3, 1.4_

- [ ] 3. 移动平台特定配置文件
- [x] 3.1 移动 Linux 特定配置到 platforms/linux
  - 移动 `proxy-functions.sh` 到 `platforms/linux/`
  - 移动 `theme-functions.sh` 到 `platforms/linux/`
  - _Requirements: 2.1, 2.3_

- [x] 3.2 创建 macOS 特定配置文件
  - 创建 `platforms/darwin/macos-specific.sh` 文件
  - 从现有配置中提取 macOS 特定功能
  - _Requirements: 2.2, 2.4_

- [ ] 4. 实现增强的环境检测功能
- [ ] 4.1 创建环境检测模块
  - 在 `core/` 中创建 `environment-detection.sh`
  - 实现容器、WSL、SSH、桌面环境的检测逻辑
  - _Requirements: 5.1, 5.2_

- [ ] 4.2 添加环境检测失败处理
  - 实现检测失败时的回退机制
  - 添加手动环境指定支持
  - _Requirements: 5.3, 5.4_

- [ ] 5. 创建环境特定配置文件
- [ ] 5.1 创建桌面环境配置
  - 创建 `environments/desktop.sh`
  - 配置完整的开发工具和 GUI 相关功能
  - _Requirements: 3.1_

- [ ] 5.2 创建远程环境轻量化配置
  - 创建 `environments/remote.sh`
  - 实现轻量化配置，跳过 GUI 和重型工具
  - _Requirements: 3.2, 7.1, 7.2_

- [ ] 5.3 创建容器环境最小化配置
  - 创建 `environments/container.sh`
  - 实现最小化配置，优化启动速度
  - _Requirements: 3.3, 7.4_

- [ ] 5.4 创建 WSL 环境混合配置
  - 创建 `environments/wsl.sh`
  - 实现 WSL 优化的混合配置
  - _Requirements: 3.4_

- [ ] 6. 重构 shell-common.sh 为分层加载器
- [ ] 6.1 实现配置分层加载逻辑
  - 重写 `shell-common.sh` 为分层配置加载器
  - 按照 核心→平台→环境→用户 的顺序加载配置
  - _Requirements: 6.1, 6.2_

- [ ] 6.2 更新 includeTemplate 路径引用
  - 更新所有 `includeTemplate` 调用的路径
  - 确保路径指向新的分层目录结构
  - _Requirements: 6.3_

- [ ] 7. 实现用户配置覆盖机制
- [ ] 7.1 创建用户本地配置层支持
  - 创建 `local/user-overrides.sh` 模板
  - 创建 `local/local-config.sh` 模板
  - _Requirements: 4.1, 4.2_

- [ ] 7.2 实现外部配置文件支持
  - 添加 `~/.chezmoi.local.sh` 外部配置文件支持
  - 实现配置优先级处理 (用户配置最高优先级)
  - _Requirements: 4.3, 4.4_

- [ ] 8. 实现配置验证和诊断功能
- [ ] 8.1 创建配置验证器
  - 创建 `core/config-validator.sh`
  - 实现配置文件语法和结构验证
  - _Requirements: 8.1, 8.2_

- [ ] 8.2 创建配置诊断工具
  - 实现配置效果检查和工具可用性验证
  - 添加自动修复选项和修复指导
  - _Requirements: 8.3, 8.4_

- [ ] 9. 实现配置加载日志和调试功能
- [ ] 9.1 添加配置来源追踪
  - 实现配置项来源记录功能
  - 添加配置合并过程的详细日志
  - _Requirements: 6.3, 6.4_

- [ ] 9.2 创建配置调试工具
  - 实现配置加载过程的调试输出
  - 添加配置冲突检测和报告
  - _Requirements: 6.4_

- [ ] 10. 更新主配置文件引用
- [ ] 10.1 更新 dot_zshrc.tmpl
  - 更新 `dot_zshrc.tmpl` 中的 `includeTemplate` 调用
  - 确保指向新的 `shell-common.sh` 加载器
  - _Requirements: 1.2, 6.1_

- [ ] 10.2 更新 dot_bashrc.tmpl
  - 更新 `dot_bashrc.tmpl` 中的配置加载逻辑
  - 确保 bash 环境也使用分层配置
  - _Requirements: 1.2, 6.1_

- [ ] 11. 创建测试套件
- [ ] 11.1 创建单元测试
  - 创建环境检测逻辑测试
  - 创建配置加载和合并测试
  - _Requirements: 8.1, 5.1_

- [ ] 11.2 创建集成测试
  - 创建完整配置分层测试
  - 创建跨平台兼容性测试
  - _Requirements: 2.4, 3.4_

- [ ] 12. 验证和优化
- [ ] 12.1 测试现有功能兼容性
  - 验证所有现有功能正常工作
  - 确保配置迁移不破坏现有行为
  - _Requirements: 1.3, 4.4_

- [ ] 12.2 性能优化验证
  - 测试 shell 启动时间
  - 验证轻量化配置的性能提升
  - _Requirements: 7.3, 7.4_