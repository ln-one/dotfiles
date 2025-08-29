# 个人 Dotfiles 配置

这是一个使用 [chezmoi](https://www.chezmoi.io/) 管理的、高度自动化和动态化的个人跨平台 Dotfiles 配置库。

本配置的核心目标是实现“一次配置，随处运行”，通过强大的模板和脚本能力，自动适应不同操作系统和使用环境，最大限度地减少手动干预。

## 核心理念

- **自动化 (Automation)**: 通过 `run_onchange_` 脚本自动安装软件包 (`Brewfile`)、验证环境，确保新机器的快速设置。
- **动态化 (Dynamic)**: 配置能自动识别当前环境（如 `desktop`, `remote`, `wsl`）和操作系统（`Linux`, `macOS`），并依此应用不同的配置。
- **模块化 (Modular)**: 复杂的逻辑被拆分到 `.chezmoitemplates` 目录下的各个模板中，使得配置结构清晰，易于维护和扩展。
- **性能优化 (Performance)**: 特别针对 Zsh 启动速度进行了优化，利用 `zsh-defer` 和 `evalcache` 等技术实现插件和命令的延迟加载，保证了秒开的终端体验。
- **安全 (Security)**: 通过与 1Password CLI 的深度集成，实现了密钥和敏感信息的安全管理，避免在 Git 仓库中明文存储任何凭证。

## ✨ 主要特性

- **跨平台支持**: 完美适配 **Linux** (桌面/服务器) 和 **macOS**。
- **Shell 环境**:
    - **Zsh** 为主，使用 [**Zim**](https://zimfw.sh/) 作为插件管理器，轻量且高效。
    - [**Starship**](https://starship.rs/) 提供现代化、美观且反应迅速的跨平台提示符。
    - 集成 `fzf`, `zoxide`, `eza`, `bat` 等现代化 CLI 工具，提升命令行效率。
- **编辑器**:
    - **Neovim** 作为主力编辑器，基于 [**LazyVim**](https://www.lazyvim.org/) 进行构建。
    - 深度定制的 [**Catppuccin**](https://github.com/catppuccin/catppuccin) 主题，并修复了 `bufferline` 的兼容性问题。
    - 配置了 `LSP`, `treesitter` 等，提供强大的代码智能和开发支持。
- **终端环境**:
    - 预设了 [**Ghostty**](https://github.com/ghostty-org/ghostty) 终端的配置文件。
    - 深度美化的 **Tmux** 配置，使用 `Tokyo Night` 主题，并集成了系统状态显示。
- **包管理**:
    - 通过 **Homebrew** 和 `Brewfile.tmpl` 模板统一管理跨平台软件包的安装。
- **密钥管理**:
    - 与 **1Password CLI** 无缝集成，自动拉取 API 密钥、SSH 配置、Git 用户信息等。
    - 实现 Git Commit 的 GPG 签名（通过 1Password 生成的 SSH Key）。
- **代理配置**:
    - 自动检测并配置系统代理，深度集成 `clash`，支持在远程服务器和本地桌面环境的代理切换。
- **主题管理**:
    - 在 Linux GNOME 桌面环境下，提供了 `dark` 和 `light` 命令一键切换系统、应用及终端的深浅主题。

## 📂 结构概览

- `.chezmoi.toml.tmpl`: 主配置文件，是所有配置的入口。它会根据当前环境动态包含不同的配置片段。
- `.chezmoitemplates/`: 核心模板库，是整个配置的“大脑”。
    - `config/`: 存放 `features`, `proxy`, `secrets` 等模块化配置。
    - `core/`: 存放各平台通用的 `aliases.sh`, `environment.sh`, `functions.sh` 等。
    - `platforms/`: 存放特定操作系统（`darwin`, `linux`）的脚本和配置。
    - `environments/`: 存放特定环境（`desktop`, `remote`）的脚本。
    - `shell/`: 存放 `bash` 和 `zsh` 的初始化和性能优化脚本。
- `run_onchange_*.sh.tmpl`: 在 `chezmoi apply` 时自动运行的脚本，用于安装软件、验证环境等。
- `dot_*`: 所有目标为家目录（`~`）的配置文件模板，如 `dot_zshrc.tmpl` 会生成 `.zshrc`。
- `scripts/`: 存放一些独立的辅助工具脚本，如备份、主题管理等。

## 🚀 快速开始

**前提**: 已安装 `git` 和 `chezmoi`。

1.  **初始化配置**:
    ```bash
    # 将 <repo-url> 替换为你的仓库地址
    chezmoi init <repo-url>
    ```

2.  **应用配置**:
    ```bash
    chezmoi apply -v
    ```
    `chezmoi` 会自动处理模板渲染、文件链接和脚本执行。

## 🔧 自定义

本配置库提供了多种方式进行个人化定制，而无需直接修改核心模板文件：

1.  **功能开关**:
    在 `.chezmoitemplates/config/features/` 目录下的 `.toml` 文件中，你可以通过设置 `true` 或 `false` 来启用或禁用大部分功能。

2.  **本地覆盖**:
    - **Shell 别名和函数**: 在 `.chezmoitemplates/local/user-overrides.sh` 文件中添加你自己的别名、函数或环境变量。此文件会被自动加载且优先级最高。
    - **chezmoi 变量**: 在 `~/.config/chezmoi/chezmoi.toml` 文件中覆盖 `[data]` 下的变量，例如：
      ```toml
      [data.user]
        name = "Your Name"
        email = "your.email@example.com"
      ```
      这会覆盖 `.chezmoi.toml.tmpl` 中的默认值。
