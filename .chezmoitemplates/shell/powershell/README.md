# PowerShell Configuration Structure

This directory contains a modular PowerShell configuration inspired by zsh/bash structure.

## File Structure

```
.chezmoitemplates/shell/powershell/
├── 00-environment.ps1.tmpl    # Environment variables and PATH setup
├── 01-aliases.ps1             # Command aliases and shortcuts
├── 02-functions.ps1.tmpl      # Custom functions and utilities
├── 03-tools.ps1               # Third-party tools initialization
├── 04-secrets.ps1.tmpl        # 1Password integration and secrets
├── shared_profile.ps1.tmpl    # Main profile that loads all modules
└── README.md                  # This file
```

## Loading Order

1. **00-environment.ps1.tmpl** - Sets up environment variables, PATH, and basic configuration
2. **01-aliases.ps1** - Defines command aliases and shortcuts
3. **02-functions.ps1.tmpl** - Loads custom functions and utilities
4. **03-tools.ps1** - Initializes third-party tools (Starship, PSReadLine, etc.)
5. **04-secrets.ps1.tmpl** - Handles 1Password integration and secret loading

## Features

- **Modular Design**: Each aspect of configuration is separated into its own file
- **Template Support**: Files ending in `.tmpl` support chezmoi templating
- **Conditional Loading**: Features are loaded based on availability and configuration
- **Fallback Support**: Graceful degradation when tools are not available
- **Consistent Structure**: Similar to zsh/bash configuration patterns

## Usage

The main entry point is `shared_profile.ps1.tmpl`, which is included in the PowerShell profile.
All modules are loaded automatically in the correct order.

## Customization

To add new functionality:
1. Add to the appropriate numbered file (e.g., new aliases in `01-aliases.ps1`)
2. Create a new numbered file if needed (e.g., `05-custom.ps1`)
3. Update `shared_profile.ps1.tmpl` to include the new file