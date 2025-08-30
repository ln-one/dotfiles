# ========================================
# Third-party Tools Initialization
# ========================================

# Import Terminal-Icons if available

# Import posh-git if available/too slow
#{{- if .features.enable_posh_git }}
#Import-Module posh-git -ErrorAction SilentlyContinue
#{{- end }}

# PSReadLine Configuration
{{- if .features.enable_psreadline }}
# Set common options
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle InlineView
Set-PSReadLineOption -BellStyle None

# Set prediction text color to gray
Set-PSReadLineOption -Colors @{
    InlinePrediction = '#8A8A8A'
}

# Ctrl+Right arrow key accepts next word
Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function AcceptNextSuggestionWord

# Tab key for menu completion
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Up/Down arrow keys for history search
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Ctrl+R for reverse history search
Set-PSReadLineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory

# Ctrl+D to exit (note: this runs 'exit', but only manual 'exit' input will always close Windows Terminal window due to terminal behavior)
Set-PSReadLineKeyHandler -Key Ctrl+d -ScriptBlock { exit }
{{- end }}

# Initialize Starship prompt (only if available)
{{- if .features.enable_starship }}
Invoke-Expression (&starship init powershell)
{{- else }}
# Fallback prompt if starship is not available
function prompt {
    $currentPath = (Get-Location).Path.Replace($env:USERPROFILE, "~")
    Write-Host "PS " -NoNewline -ForegroundColor Green
    Write-Host $currentPath -NoNewline -ForegroundColor Blue
    Write-Host ">" -NoNewline -ForegroundColor Green
    return " "
}
{{- end }}

# Initialize zoxide (smarter cd)
{{- if .features.enable_zoxide }}
Invoke-Expression (& { (zoxide init powershell) -join "`n" })
{{- end }}

# Initialize FZF keybindings (only if both fzf and PSFzf are available)
{{- if and .features.enable_fzf .features.enable_psfzf }}
try {
    Import-Module PSFzf -ErrorAction Stop
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
} catch {
    Write-Warning "Failed to initialize PSFzf: $_"
}
{{- end }}