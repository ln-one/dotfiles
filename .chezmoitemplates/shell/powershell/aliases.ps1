# Define PowerShell aliases here

# Refresh PATH to ensure newly installed tools are available
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")

# Import Terminal-Icons if available
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module Terminal-Icons -ErrorAction SilentlyContinue
}

# eza aliases, with fallback to Get-ChildItem
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
    function global:tree { eza --tree --color=auto --icons @args }
} else {
    # Remove existing aliases first
    Remove-Alias -Name ls -Force -ErrorAction SilentlyContinue
    Remove-Alias -Name ll -Force -ErrorAction SilentlyContinue
    Remove-Alias -Name la -Force -ErrorAction SilentlyContinue
    Remove-Alias -Name l -Force -ErrorAction SilentlyContinue
    
    # Fallback to default PowerShell commands
    function global:ls { Get-ChildItem @args }
    function global:ll { Get-ChildItem -Force @args | Format-Table -AutoSize }
    function global:la { Get-ChildItem -Force @args }
    function global:l { Get-ChildItem @args }
}

# Other useful aliases
Set-Alias -Name cat -Value Get-Content -Force
Set-Alias -Name clear -Value Clear-Host -Force

# bat alias if available
if (Get-Command bat -ErrorAction SilentlyContinue) {
    function global:cat { bat @args }
}
