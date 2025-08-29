# PowerShell initialization script

# Source aliases and environment variables
. '{{ .chezmoi.sourceDir }}/.chezmoitemplates/shell/powershell/aliases.ps1'
. '{{ .chezmoi.sourceDir }}/.chezmoitemplates/shell/powershell/environment.ps1'

# Source custom functions
. '{{ .chezmoi.sourceDir }}/.chezmoitemplates/shell/powershell/functions.ps1'

# PSReadLine Configuration (ensure module is available)
if (Get-Module -ListAvailable -Name PSReadLine) {
    # Set common options
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -BellStyle None

    # Set key handlers for history search based on current input
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}