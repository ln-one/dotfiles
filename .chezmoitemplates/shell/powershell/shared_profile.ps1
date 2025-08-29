# ========================================
# Main PowerShell Profile managed by chezmoi
# Modular configuration inspired by zsh/bash structure
# ========================================

# Load configuration modules in order
$moduleDir = "{{ .chezmoi.sourceDir }}\.chezmoitemplates\shell\powershell"

# 00 - Environment variables and PATH setup
{{ includeTemplate ".chezmoitemplates/shell/powershell/00-environment.ps1" . | indent 0 }}

# 01 - Aliases and shortcuts
$aliasFile = Join-Path $moduleDir "01-aliases.ps1"
if (Test-Path $aliasFile) { . $aliasFile }

# 02 - Custom functions
{{ includeTemplate ".chezmoitemplates/shell/powershell/02-functions.ps1" . | indent 0 }}

# 03 - Third-party tools initialization
$toolsFile = Join-Path $moduleDir "03-tools.ps1"
if (Test-Path $toolsFile) { . $toolsFile }

# 04 - Secrets and 1Password integration
{{ includeTemplate ".chezmoitemplates/shell/powershell/04-secrets.ps1" . | indent 0 }}

# Welcome message
Write-Host "PowerShell environment loaded successfully" -ForegroundColor Green



