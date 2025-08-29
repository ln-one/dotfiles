# PowerShell initialization script

# Source aliases and environment variables
. '{{ .chezmoi.sourceDir }}/.chezmoitemplates/shell/powershell/aliases.ps1'
. '{{ .chezmoi.sourceDir }}/.chezmoitemplates/shell/powershell/environment.ps1'

# Source custom functions
. '{{ .chezmoi.sourceDir }}/.chezmoitemplates/shell/powershell/functions.ps1'
