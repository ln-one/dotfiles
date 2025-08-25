# Implementation Plan

- [x] 1. 修改 Chezmoi 配置以支持 Zim 框架
  - 更新 `.chezmoi.toml.tmpl` 文件，添加 Zim 特性标志
  - 禁用 `enable_oh_my_zsh` 并启用 `enable_zim`
  - 保持所有其他现有特性标志不变
  - _Requirements: 1.1, 1.3, 7.2_

- [x] 2. 创建 Zim 模块配置文件
  - 创建 `dot_zimrc.tmpl` 文件定义 Zim 模块
  - 配置核心模块：environment, input, utility
  - 根据特性标志条件加载 fzf 模块
  - 配置补全系统和语法高亮模块
  - _Requirements: 2.1, 2.2, 2.3, 8.1_

- [x] 3. 实现 Zim 配置加载模块
  - 创建 `.chezmoitemplates/core/zim-config.sh` 文件
  - 实现 ZIM_HOME 环境变量设置
  - 实现 zimfw.zsh 自动下载逻辑（支持 curl 和 wget）
  - 实现自动模块安装和初始化脚本更新
  - 实现 init.zsh 加载和错误处理
  - _Requirements: 1.1, 1.2, 5.1, 6.1, 6.2, 6.3, 6.4, 6.5_

- [x] 4. 修改 shell 加载器以支持框架切换
  - 修改 `.chezmoitemplates/shell-common.sh` 文件
  - 添加条件逻辑以根据特性标志选择 Oh My Zsh 或 Zim
  - 确保其他所有模块加载保持不变
  - 保持现有的分层配置架构完整
  - _Requirements: 1.2, 5.2, 7.1, 7.3_

- [x] 5. 创建 Zim 安装脚本
  - 创建 `run_once_install-zim.sh.tmpl` 文件
  - 实现 Zim 框架的初始安装检查
  - 确保必要的目录结构存在
  - 处理不同平台的安装需求
  - _Requirements: 5.4, 6.1, 6.2, 6.3, 6.4, 6.5_

- [x] 5.1 解决 fzf 版本兼容性问题
  - ✅ 诊断并解决 fzf 0.48.0+ 新选项兼容性问题
  - ✅ 更新用户的 fzf 到最新版本 (0.65.1)
  - ✅ 重新生成 Zim fzf 模块的集成脚本
  - ✅ 修复 Zim 补全系统冲突问题
  - ✅ 验证所有 fzf 功能正常工作
  - _Requirements: 2.4, 8.2_

- [ ] 6. 验证 Git 功能集成
  - 测试 Zim utility 模块提供的 Git 别名
  - 确保与现有 Git 配置的兼容性
  - 验证 Git 状态显示功能正常
  - _Requirements: 2.1, 4.1_

- [ ] 7. 验证自动建议和语法高亮功能
  - 测试 zsh-users/zsh-autosuggestions 模块加载
  - 测试 zsh-users/zsh-syntax-highlighting 模块加载
  - 确保功能与 Oh My Zsh 版本对等
  - _Requirements: 2.2, 2.3_

- [x] 8. 验证并现代化 fzf 集成
  - ✅ 更新 fzf 配置以支持新版本 (0.48.0+) 的 `--zsh` 选项
  - ✅ 实现向后兼容的 fzf 集成方式（自动检测版本）
  - ✅ 优化 fzf 环境变量配置，利用新版本功能
  - ✅ 增强自定义 fzf 函数，添加更好的预览和交互
  - ✅ 添加 Git、Docker、systemd 等工具的 fzf 集成函数
  - ✅ 创建 `.zshenv` 文件处理 Ubuntu compinit 冲突问题
  - _Requirements: 2.4, 4.3_

- [ ] 9. 验证 Starship 提示符集成
  - 确保 Starship 在 Zim 框架下正常工作
  - 验证不与 Zim 内置提示符冲突
  - 测试条件加载逻辑（启用 Starship 时禁用 Zim 提示符）
  - _Requirements: 3.1, 4.2_

- [ ] 10. 测试多环境兼容性
- [ ] 10.1 测试 macOS 环境
  - 在 macOS 系统上应用配置
  - 验证 Homebrew 集成正常
  - 测试所有功能模块加载
  - _Requirements: 6.1_

- [ ] 10.2 测试 Linux 环境
  - 在 Linux 系统上应用配置
  - 验证包管理器集成正常
  - 测试所有功能模块加载
  - _Requirements: 6.2_

- [ ] 10.3 测试远程 SSH 环境
  - 在远程 SSH 连接中测试配置
  - 验证轻量化配置正确应用
  - 确保性能优化生效
  - _Requirements: 6.3_

- [ ] 11. 验证环境变量和路径配置保持不变
  - 测试 PATH 环境变量配置
  - 验证 fnm (Node.js) 环境配置
  - 测试 1Password SSH Agent 配置
  - 验证代理配置（如果启用）
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [ ] 12. 验证用户配置覆盖机制
  - 测试本地用户配置文件加载
  - 验证配置优先级正确
  - 确保用户自定义配置不受影响
  - _Requirements: 7.3, 5.3_

- [ ] 13. 创建配置验证和测试脚本
  - 编写功能验证脚本
  - 实现配置完整性检查
  - 创建回滚机制说明
  - _Requirements: 5.4_

- [ ] 14. 更新相关文档和注释
  - 更新配置文件中的注释
  - 记录 Zim 特定的配置选项
  - 创建迁移说明文档
  - _Requirements: 8.4_