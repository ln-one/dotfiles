# ========================================
# PowerShell Aliases Configuration
# ========================================

# Directory navigation shortcuts
function .. { Set-Location .. }
function ... { Set-Location ../.. }
function .... { Set-Location ../../.. }

# Enhanced directory listing with eza (if available)
if (Get-Command eza -ErrorAction SilentlyContinue) {
    # Remove existing aliases first
    Remove-Alias -Name ls -Force -ErrorAction SilentlyContinue
    Remove-Alias -Name ll -Force -ErrorAction SilentlyContinue
    Remove-Alias -Name la -Force -ErrorAction SilentlyContinue
    Remove-Alias -Name l -Force -ErrorAction SilentlyContinue
    
    function global:ls { eza -F --color=auto --icons @args }
    function global:ll { eza -alF --color=auto --icons --git @args }
    function global:la { eza -a --color=auto --icons @args }
    function global:l { eza -F --color=auto --icons @args }
    function global:lt { eza --tree --color=auto --icons @args }
} else {
    # Fallback to default PowerShell commands
    Remove-Alias -Name ls -Force -ErrorAction SilentlyContinue
    Remove-Alias -Name ll -Force -ErrorAction SilentlyContinue
    Remove-Alias -Name la -Force -ErrorAction SilentlyContinue
    Remove-Alias -Name l -Force -ErrorAction SilentlyContinue
    
    function global:ls { Get-ChildItem @args }
    function global:ll { Get-ChildItem -Force @args | Format-Table -AutoSize }
    function global:la { Get-ChildItem -Force @args }
    function global:l { Get-ChildItem @args }
    function global:lt { tree /f @args }
}

# Enhanced cat with bat (if available)
if (Get-Command bat -ErrorAction SilentlyContinue) {
    function global:cat { bat @args }
} else {
    Set-Alias -Name cat -Value Get-Content -Force
}

# Git shortcuts
function gs { git status @args }
function ga { git add @args }
function gc { git commit @args }
function gp { git push @args }
function gl { git log --oneline -10 @args }
function gd { git diff @args }
function gb { git branch @args }
function gco { git checkout @args }

# Common aliases
Set-Alias -Name clear -Value Clear-Host -Force
function grep { Select-String @args }
function which { Get-Command @args }
function touch { New-Item -ItemType File @args }
function mkdir { New-Item -ItemType Directory @args }