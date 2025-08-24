# Chezmoi 配置项目结构

## 📁 项目结构

```
.
├── .gitignore                          # Git 忽略文件配置
├── .chezmoitemplates/                  # Chezmoi 模板目录
│   ├── aliases.sh                      # 核心别名模块 (ls/ll/la)
│   ├── basic-functions.sh              # 基础函数模块 (mkcd, sysinfo)
│   ├── proxy-functions.sh              # 代理管理模块 (proxyon/proxyoff/proxystatus)
│   ├── theme-functions.sh              # 主题切换模块 (light/dark/themestatus)
│   └── shell-common.sh                 # 模块加载器
├── dot_bashrc.tmpl                     # Bash 配置模板
├── dot_zshrc.tmpl                      # Zsh 配置模板
├── test-templates.sh                   # 模板测试脚本
└── PROJECT_STRUCTURE.md               # 本文件
```

## 🧩 模块化设计

### 核心原则
- **模块化**: 每个功能独立的模板文件
- **按需加载**: 根据平台和环境条件加载
- **避免重复**: 通过 `includeTemplate` 实现代码复用
- **平台感知**: 使用 Chezmoi 的平台检测功能

### 模块说明

#### 1. `aliases.sh` - 核心别名模块
- **功能**: 提供基础文件操作别名
- **包含**: `ls`, `ll`, `la`, 导航别名, 安全操作别名
- **特性**: 智能检测现代工具 (eza/exa)

#### 2. `basic-functions.sh` - 基础函数模块
- **功能**: 提供基础实用函数
- **包含**: `mkcd`, `sysinfo`
- **特性**: 跨平台兼容

#### 3. `proxy-functions.sh` - 代理管理模块
- **功能**: 代理开关和状态管理
- **包含**: `proxyon`, `proxyoff`, `proxystatus`
- **限制**: 仅在 Linux 桌面环境加载
- **特性**: 支持环境变量和 GNOME 系统代理

#### 4. `theme-functions.sh` - 主题切换模块
- **功能**: WhiteSur 主题切换
- **包含**: `light`, `dark`, `themestatus`
- **限制**: 仅在 Linux GNOME 桌面环境加载
- **特性**: 支持 WhiteSur 主题和 fcitx5 集成

#### 5. `shell-common.sh` - 模块加载器
- **功能**: 统一加载所有模块
- **包含**: 环境变量设置 + 模块加载
- **特性**: 模块化架构的入口点

## 🔧 使用方式

### 在 Shell 配置中使用
```bash
# 在 dot_bashrc.tmpl 或 dot_zshrc.tmpl 中
{{ includeTemplate "shell-common.sh" . }}
```

### 单独使用模块
```bash
# 只加载别名
{{ includeTemplate "aliases.sh" . }}

# 只加载代理功能
{{ includeTemplate "proxy-functions.sh" . }}
```

## 🧪 测试

运行测试脚本验证所有模块：
```bash
./test-templates.sh
```

## 📋 迁移的功能

### ✅ 已迁移
- [x] 核心别名 (ls/ll/la)
- [x] 代理管理 (proxyon/proxyoff/proxystatus)
- [x] WhiteSur 主题切换 (light/dark/themestatus)
- [x] 基础函数 (mkcd/sysinfo)

### ❌ 已移除
- [x] proxyai 函数 (按用户要求移除)
- [x] 复杂的工具集成 (简化为核心功能)
- [x] 重型模块 (保持轻量化)

## 🎯 设计目标

1. **简化**: 只保留核心必需功能
2. **模块化**: 每个功能独立可测试
3. **平台感知**: 根据环境智能加载
4. **易维护**: 清晰的文件结构和职责分离
5. **向后兼容**: 保持原有功能接口不变