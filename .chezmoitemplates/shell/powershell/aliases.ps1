# Define PowerShell aliases here
# Example: Set-Alias -Name ls -Value Get-ChildItem

# Common cross-platform aliases
# eza aliases, with fallback to Get-ChildItem
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function global:ls { eza --color=auto --icons @args }
    function ll { eza -alF --color=auto --icons --git @args }
    function la { eza -a --color=auto --icons @args }
    function l { eza -F --color=auto --icons @args }
    function tree { eza --tree --color=auto --icons @args }
} else {
    Set-Alias -Name ls -Value Get-ChildItem
    Set-Alias -Name la -Value Get-ChildItem -Force
}
Set-Alias -Name cat -Value Get-Content
Set-Alias -Name clear -Value Clear-Host
