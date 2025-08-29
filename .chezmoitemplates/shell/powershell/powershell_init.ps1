# PowerShell initialization script

# Source aliases
. '{{ .chezmoi.sourceDir }}/.chezmoitemplates/shell/powershell/aliases.ps1'

# Source environment variables and functions (if they exist)
$envFile = '{{ .chezmoi.homeDir }}/.config/powershell/environment.ps1'
if (Test-Path $envFile) {
    . $envFile
}

$functionsFile = '{{ .chezmoi.homeDir }}/.config/powershell/functions.ps1'
if (Test-Path $functionsFile) {
    . $functionsFile
}

# PSReadLine Configuration (ensure module is available)
if (Get-Module -ListAvailable -Name PSReadLine) {
    # Set common options
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    Set-PSReadLineOption -PredictionViewStyle InlineView
    Set-PSReadLineOption -BellStyle None
    
    # 设置预测文本颜色为灰色
    Set-PSReadLineOption -Colors @{
        InlinePrediction = '#8A8A8A'
    }

    # 右箭头键接受预测建议
    Set-PSReadLineKeyHandler -Key RightArrow -Function AcceptSuggestion
    
    # Ctrl+右箭头键接受下一个单词
    Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function AcceptNextSuggestionWord
    
    # Tab 键用于菜单补全
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    
    # 上下箭头键用于历史搜索
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    
    # Ctrl+R 用于反向历史搜索
    Set-PSReadLineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory
}

# Refresh PATH to ensure newly installed tools are available
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")

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

