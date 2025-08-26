# Implementation Plan

- [x] 1. 分析现有配置中的路径引用
  - 扫描所有模板文件中的系统包管理器路径引用
  - 识别需要统一的工具路径和别名
  - 记录所有硬编码的 apt/yum 相关路径
  - _Requirements: 8.1, 8.2, 7.1, 7.2_

- [x] 2. 统一工具路径引用
- [x] 2.1 更新环境配置模板中的路径
  - 修改 `.chezmoitemplates/core/environment.sh` 中的工具路径引用
  - 将 `/usr/bin/batcat` 改为 `$(brew --prefix)/bin/bat`
  - 将 `/usr/bin/fdfind` 改为 `$(brew --prefix)/bin/fd`
  - 统一所有工具的路径为 Homebrew 标准路径
  - _Requirements: 8.1, 8.5, 7.3_

- [x] 2.2 更新别名配置中的路径
  - 修改 `.chezmoitemplates/core/aliases.sh` 中的工具别名
  - 移除 batcat → bat 的别名映射逻辑
  - 移除 fdfind → fd 的别名映射逻辑
  - 统一使用 Homebrew 标准命令名
  - _Requirements: 8.1, 8.5_

- [x] 2.3 更新 fzf 配置中的工具路径
  - 修改 `.chezmoitemplates/core/fzf-config.sh` 中的工具检测
  - 将 `lookPath "fd"` 和 `lookPath "rg"` 改为直接使用 Homebrew 路径
  - 更新 FZF_DEFAULT_COMMAND 中的工具路径
  - _Requirements: 8.1, 7.3_

- [x] 3. 清理冗余安装脚本
- [x] 3.1 删除独立工具安装脚本
  - 删除 `run_once_install-community-tools.sh.tmpl`
  - 删除 `run_once_install-starship.sh.tmpl`
  - 删除 `run_once_install-fzf.sh.tmpl`
  - 删除 `run_once_install-zoxide.sh.tmpl`
  - 删除 `run_once_install-nerd-fonts.sh.tmpl`
  - 删除 `run_once_install-version-managers.sh.tmpl`
  - _Requirements: 2.1, 2.2_

- [x] 3.2 删除复杂的工具安装脚本
  - 删除 `run_once_install-tools.sh.tmpl` (复杂的多包管理器逻辑)
  - 删除 `run_once_install-evalcache.sh.tmpl`
  - 删除 `run_once_install-fnm.sh.tmpl`
  - 删除 `run_once_install-zim.sh.tmpl`
  - _Requirements: 2.1, 2.2, 8.1_

- [x] 3.3 保留必要的安装脚本
  - 保留 `run_once_install-homebrew.sh.tmpl` (可选，用户可手动安装)
  - 保留 `run_once_install-1password-cli.sh.tmpl` (特殊安装需求)
  - 保留 `run_once_setup-1password-ssh.sh.tmpl` (配置脚本，非安装)
  - _Requirements: 4.4_

- [x] 4. 优化 Brewfile 配置
- [x] 4.1 整合所有工具到 Brewfile
  - 将删除脚本中的工具添加到 `Brewfile.tmpl`
  - 添加 starship, fzf, zoxide 等工具
  - 添加 fnm, evalcache 相关工具 (如果有 brew 版本)
  - 添加 Nerd Fonts (通过 brew cask)
  - _Requirements: 1.1, 1.3, 3.1_

- [x] 4.2 移除包名映射逻辑
  - 统一使用 Homebrew 标准包名 (bat 而非 batcat)
  - 统一使用 Homebrew 标准包名 (fd 而非 fd-find)
  - 统一使用 Homebrew 标准包名 (ripgrep 而非 rg)
  - 移除所有平台特定的包名条件判断
  - _Requirements: 8.1, 8.5_

- [x] 4.3 优化条件安装逻辑
  - 保持现有的特性标志条件 (`{{ if .features.* }}`)
  - 简化平台条件 (只保留 cask vs brew 的区别)
  - 移除包管理器可用性检测条件
  - _Requirements: 3.3, 6.2_

- [x] 5. 更新环境验证脚本
- [x] 5.1 简化验证逻辑
  - 修改 `run_onchange_verify-environment.sh.tmpl`
  - 移除系统包管理器检测逻辑
  - 只保留 Homebrew 路径和工具验证
  - 简化工具可用性检查 (假设都通过 Homebrew 安装)
  - _Requirements: 2.2, 8.1_

- [x] 5.2 更新包安装验证脚本
  - 修改 `run_onchange_install-brew-packages.sh.tmpl`
  - 移除包管理器检测和环境设置逻辑
  - 简化为纯 `brew bundle` 执行
  - 移除复杂的错误处理 (依赖 Homebrew 内置处理)
  - _Requirements: 2.1, 8.1_

- [x] 6. 清理模板中的包管理器检测
- [x] 6.1 移除系统包管理器检测逻辑
  - 搜索并移除所有 `command -v apt` 检测
  - 搜索并移除所有 `command -v yum` 检测
  - 搜索并移除所有 `command -v dnf` 检测
  - 移除相关的条件安装逻辑
  - _Requirements: 8.1, 8.3_

- [x] 6.2 简化工具可用性检查
  - 将 `lookPath` 检查改为直接使用 Homebrew 路径
  - 移除工具别名检测逻辑 (batcat/bat, fdfind/fd)
  - 统一工具命令检测为 Homebrew 标准名称
  - _Requirements: 8.1, 8.5_

- [x] 7. 测试和验证重构结果
- [x] 7.1 创建测试脚本验证路径统一
  - 编写脚本检查所有配置文件中的路径引用
  - 验证没有遗留的系统包管理器路径
  - 验证所有工具路径都指向 Homebrew
  - _Requirements: 7.5, 8.1_

- [x] 7.2 验证 Brewfile 完整性
  - 确认所有删除脚本中的工具都已添加到 Brewfile
  - 验证条件安装逻辑正确
  - 测试 `brew bundle install --dry-run` 执行
  - _Requirements: 1.1, 3.1_

- [x] 7.3 测试环境配置完整性
  - 验证删除脚本后环境配置仍然完整
  - 测试所有工具的环境变量和路径配置
  - 确认 shell 集成功能正常
  - _Requirements: 3.4, 7.3_

- [x] 8. 更新文档和说明
- [x] 8.1 更新 README 安装说明
  - 更新安装流程说明 (用户手动安装 Homebrew)
  - 更新工具列表 (统一为 Homebrew 版本)
  - 移除系统包管理器相关说明
  - _Requirements: 6.1_

- [x] 8.2 创建迁移指南
  - 编写从旧系统迁移的步骤说明
  - 说明如何清理旧的系统包安装
  - 提供故障排除指南
  - _Requirements: 4.1, 4.2_