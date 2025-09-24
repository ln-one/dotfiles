# Cross-Platform Dotfiles with Chezmoi

A dotfiles management system built with [Chezmoi](https://www.chezmoi.io/) that provides consistent development environments across macOS, Linux, and Windows. Features automatic environment detection and modular configuration.

## Features   

### Environment Detection
- Automatic environment classification: Desktop, Remote (SSH), WSL, Container
- Dynamic feature activation based on available tools
- Platform-aware configuration for macOS, Linux, Windows
- Proxy detection and management

### Development Tools
- Shell configuration: Zsh with Zim framework, Bash compatibility
- Modern CLI tools: `eza`, `bat`, `fd`, `ripgrep`, `zoxide`
- Development utilities: fzf, forgit, tmux
- Editor support: Neovim (LazyVim), VS Code

### Security & Secrets
- 1Password CLI integration with SSH agent
- SSH configuration with signing key support
- Environment-aware security (secrets disabled in remote environments)
- Git signing with 1Password keys

### Package Management
- Homebrew integration with templated Brewfiles
- Cross-platform installation scripts
- Development environment setup: Node.js, Python, Ruby, Go, Rust

### Performance
- Fast shell startup with deferred loading
- Evalcache for expensive operations
- Conditional feature loading
- Optimized completion system

### Networking
- Proxy management with Clash integration (Linux)
- Environment-specific proxy configuration
- Network connectivity testing

## Architecture

### Modular Configuration System
```
.chezmoitemplates/
├── config/                 # Configuration and feature detection
│   ├── features/          # Platform-specific feature flags
│   │   ├── core-features.toml
│   │   ├── dev-features.toml
│   │   ├── linux-features.toml
│   │   ├── macos-features.toml
│   │   └── windows-features.toml
│   ├── proxy/             # Proxy configuration templates
│   │   ├── proxy-detection.toml
│   │   ├── proxy-clash-config.toml
│   │   └── proxy-*.toml
│   ├── secrets/           # 1Password and secrets management
│   │   ├── secrets-1password.toml
│   │   └── secrets-fallback.toml
│   └── environment-packages.toml
├── core/                   # Base shell functionality
│   ├── aliases.sh         # Common aliases
│   ├── colors.sh          # Color definitions
│   ├── environment.sh     # Environment variables
│   ├── functions.sh       # Utility functions
│   └── fzf.sh            # FZF configuration
├── environments/           # Context-aware configurations
│   ├── desktop.sh         # Desktop environment features
│   └── remote.sh          # SSH/remote optimizations
├── local/                  # User customization templates
│   ├── user-overrides.sh  # Personal overrides
│   └── sample-external-config.sh
├── platforms/              # OS-specific configurations
│   ├── darwin/            # macOS-specific features
│   │   └── macos-specific.sh
│   ├── linux/             # Linux desktop/server features
│   │   ├── proxy-functions.sh
│   │   └── theme-functions.sh
│   └── windows/           # Windows PowerShell tools
│       └── winget-helpers.ps1
├── shell/                  # Shell-specific implementations
│   ├── bash/              # Bash configuration
│   │   └── bash_init.sh
│   ├── powershell/        # PowerShell modules
│   │   ├── 00-environment.ps1
│   │   ├── 01-aliases.ps1
│   │   ├── 02-functions.ps1
│   │   ├── 03-tools.ps1
│   │   ├── 04-secrets.ps1
│   │   └── shared_profile.ps1
│   └── zsh/               # Zsh with Zim framework
│       ├── zim-config.sh
│       ├── zsh_init.sh
│       └── zsh-performance-tweaks.sh
└── shell-common.sh         # Common shell configuration loader
```

### Configuration Layers (Priority Order)
1. **Core Layer**: Universal base functionality
2. **Platform Layer**: OS-specific optimizations  
3. **Environment Layer**: Context-aware features (desktop/remote/container)
4. **User Layer**: Personal overrides and local customizations

## Quick Start

### Prerequisites
```bash
# Install Chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)"

# Install Homebrew (recommended)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Installation
```bash
# Initialize dotfiles repository
chezmoi init ln-one/dotfiles

# Preview changes (recommended for first-time users)
chezmoi diff

# Apply configuration
chezmoi apply

# Packages will be installed automatically via run_onchange scripts
```

### Platform-Specific Setup

#### macOS
```bash
# Homebrew packages and Cask applications installed automatically
# Includes: 1Password, VS Code, iTerm2, Docker, Nerd Fonts
```

#### Linux (Desktop)
```bash
# Includes proxy management, theme switching, desktop integration
# GNOME/KDE compatibility with gsettings integration
```

#### Windows
```powershell
# PowerShell modules and winget packages installed automatically
# Includes: Starship, modern CLI tools, Nerd Fonts, 1Password CLI
```

## Configuration

### User Configuration
Edit `.chezmoi.toml.tmpl` to customize:
```toml
[data.user]
  name = "your-name"
  email = "your-email@example.com"

[data.preferences]
  shell = "zsh"          # zsh, bash
  editor = "nvim"        # nvim, code, vim
  theme = "dark"         # dark, light
  ls_tool = "eza"        # eza, exa, ls
```

### Feature Toggles
Modify `.chezmoitemplates/config/features/*.toml`:
- **Core features**: 1Password, proxy, AI tools, Starship
- **Development tools**: Node.js, Python, Docker, Git enhancements
- **Platform features**: macOS apps, Linux desktop integration, Windows tools

### Local Overrides
Create personal customizations:
```bash
# Shell customizations
~/.chezmoitemplates/local/user-overrides.sh

# External configuration files
~/.chezmoi.local.sh                    # Per-user overrides
/etc/chezmoi/config.sh                 # System-wide configuration
$(pwd)/.chezmoi.local.sh               # Project-specific settings
```

## Included Tools

### Shell & Terminal
- **Zsh**: Modern shell with Zim framework
- **Starship**: Cross-shell prompt with Tokyo Night theme
- **Tmux**: Terminal multiplexer with modern configuration
- **Modern CLI tools**: eza, bat, fd, ripgrep, fzf, zoxide

### Development Environment
- **Editors**: Neovim (LazyVim), VS Code configurations
- **Version managers**: fnm (Node.js), pyenv (Python), rbenv (Ruby)
- **Git enhancement**: forgit (fzf integration), advanced Git configuration
- **Container tools**: Docker, Docker Compose (platform-specific)

### Security & Networking
- **1Password CLI**: Secure credential and SSH key management
- **SSH configuration**: Advanced SSH config with proxy support
- **Proxy management**: Clash integration with GUI/CLI controls
- **Network tools**: curl, wget, advanced connectivity testing

### Platform-Specific Applications

#### macOS (via Homebrew Cask)
- 1Password, VS Code, iTerm2, Docker Desktop
- Firefox, Chrome, Slack, Zoom
- Nerd Fonts for icon support

#### Windows (via winget)
- Git, Starship, modern CLI tools
- 1Password CLI, Neovim
- JetBrains Mono, Cascadia Code, Fira Code Nerd Fonts

## Additional Features

### Performance
- Fast shell startup with deferred loading
- Evalcache for expensive operations
- Completion system with daily cache refresh
- Conditional feature activation

### Environment Support
- SSH detection for lightweight remote configuration
- Container-optimized settings
- WSL integration
- Automatic proxy configuration

### Security
- 1Password SSH agent integration
- Git commit signing
- Vault-based secret management
- Environment isolation for secrets

## File Structure

```
├── .chezmoi.toml.tmpl              # Main configuration template
├── .chezmoiignore                  # Files excluded from management
├── .chezmoitemplates/              # Template components
│   ├── config/                     # Feature flags and environment detection
│   ├── core/                       # Base shell functionality
│   ├── environments/               # Context-aware settings (desktop/remote)
│   ├── local/                      # User customization templates
│   ├── platforms/                  # OS-specific configurations
│   ├── shell/                      # Shell-specific implementations
│   └── shell-common.sh             # Common shell configuration loader
├── dot_bashrc.tmpl                 # Bash configuration
├── dot_gitconfig.tmpl              # Git configuration
├── dot_secrets.tmpl                # 1Password secrets (Unix)
├── dot_secrets.ps1.tmpl            # 1Password secrets (Windows)
├── dot_tmux.conf.tmpl              # Tmux configuration
├── dot_zimrc.tmpl                  # Zim framework configuration
├── dot_zshenv.tmpl                 # Zsh environment variables
├── dot_zshrc.tmpl                  # Zsh configuration
├── dot_config/                     # XDG config directory
│   ├── ghostty/                    # Terminal emulator config
│   ├── nvim/                       # Neovim configuration
│   └── starship.toml.tmpl          # Starship prompt configuration
├── dot_ssh/                        # SSH configuration
│   ├── allowed_signers.tmpl        # Git signing keys
│   └── config.tmpl                 # SSH client configuration
├── private_Documents/              # Private/encrypted files
│   └── PowerShell/                 # Windows PowerShell profile
├── run_onchange_*                  # Installation and setup scripts
├── Brewfile.tmpl                   # Homebrew package definitions
├── docs/                           # Documentation (empty)
└── scripts/                        # Additional utility scripts (empty)
```

## Development

### Adding New Features
1. **Feature detection**: Add to appropriate `*-features.toml` file
2. **Implementation**: Create template in relevant platform/environment directory
3. **Integration**: Include in `shell-common.sh` or platform-specific loader
4. **Testing**: Use `chezmoi diff` and `chezmoi apply --dry-run`

### Testing Changes
```bash
# Preview all changes
chezmoi diff

# Apply specific file
chezmoi apply ~/.zshrc

# Force re-run installation scripts
chezmoi apply --force

# Debug template rendering
chezmoi execute-template < .chezmoi.toml.tmpl
```

### Performance Profiling
```bash
# Zsh startup profiling (add to .zshrc temporarily)
zmodload zsh/zprof
# ... configuration ...
zprof
```

## Contributing

This dotfiles system is designed to be both personal and shareable. Contributions are welcome:

1. **Bug reports**: Issues with specific platforms or environments
2. **Feature requests**: New tools, optimizations, or platform support
3. **Performance improvements**: Startup time optimizations, caching strategies
4. **Documentation**: Usage examples, troubleshooting guides

## License

MIT License