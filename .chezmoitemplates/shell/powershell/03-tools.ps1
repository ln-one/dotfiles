# ========================================
# Third-party Tools Initialization
# ========================================

# Import Terminal-Icons if available
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module Terminal-Icons -ErrorAction SilentlyContinue
}

# PSReadLine Configuration
if (Get-Module -ListAvailable -Name PSReadLine) {
    # Set common options
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    Set-PSReadLineOption -PredictionViewStyle InlineView
    Set-PSReadLineOption -BellStyle None
    
    # Set prediction text color to gray
    Set-PSReadLineOption -Colors @{
        InlinePrediction = '#8A8A8A'
    }

    # Right arrow key accepts prediction suggestion
    Set-PSReadLineKeyHandler -Key RightArrow -Function AcceptSuggestion
    
    # Ctrl+Right arrow key accepts next word
    Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function AcceptNextSuggestionWord
    
    # Tab key for menu completion
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    
    # Up/Down arrow keys for history search
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    
    # Ctrl+R for reverse history search
    Set-PSReadLineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory
}

# Initialize Starship prompt (only if available)
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
} else {
    # Fallback prompt if starship is not available
    function prompt {
        $currentPath = (Get-Location).Path.Replace($env:USERPROFILE, "~")
        Write-Host "PS " -NoNewline -ForegroundColor Green
        Write-Host $currentPath -NoNewline -ForegroundColor Blue
        Write-Host ">" -NoNewline -ForegroundColor Green
        return " "
    }
}

# Initialize zoxide (smarter cd)
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell) -join "`n" })
}

# Initialize FZF keybindings (only if both fzf and PSFzf are available)
if ((Get-Command fzf -ErrorAction SilentlyContinue) -and (Get-Module -ListAvailable -Name PSFzf)) {
    try {
        Import-Module PSFzf -ErrorAction Stop
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    } catch {
        Write-Warning "Failed to initialize PSFzf: $_"
    }
}