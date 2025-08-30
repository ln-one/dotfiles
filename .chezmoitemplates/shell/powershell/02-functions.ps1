# ========================================
# PowerShell Custom Functions
# ========================================

# Quick edit function
function edit {
    param([string]$Path)
    
    if ($Path) {
        & $env:EDITOR $Path
    } else {
        Write-Host "Usage: edit <file>" -ForegroundColor Yellow
    }
}

# System information
function sysinfo {
    Write-Host "System Information:" -ForegroundColor Cyan
    Write-Host "OS: $((Get-CimInstance Win32_OperatingSystem).Caption)"
    Write-Host "Version: $((Get-CimInstance Win32_OperatingSystem).Version)"
    Write-Host "Architecture: $env:PROCESSOR_ARCHITECTURE"
    Write-Host "PowerShell: $($PSVersionTable.PSVersion)"
    Write-Host "User: $env:USERNAME"
    Write-Host "Computer: $env:COMPUTERNAME"
}