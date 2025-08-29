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

# Network utilities
function myip {
    try {
        $ip = Invoke-RestMethod -Uri "https://api.ipify.org" -TimeoutSec 5
        Write-Host "Public IP: $ip" -ForegroundColor Green
    } catch {
        Write-Warning "Failed to get public IP"
    }
    
    $localIPs = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -ne "127.0.0.1" }
    Write-Host "Local IPs:" -ForegroundColor Cyan
    $localIPs | ForEach-Object { Write-Host "  $($_.IPAddress)" }
}

# Reload PowerShell profile
function Reload-Profile {
    if (Test-Path $PROFILE) {
        . $PROFILE
        Write-Host "PowerShell profile reloaded" -ForegroundColor Green
    } else {
        Write-Warning "PowerShell profile not found"
    }
}

# Find files and directories
function find {
    param(
        [string]$Name,
        [string]$Path = "."
    )
    
    if ($Name) {
        Get-ChildItem -Path $Path -Recurse -Name "*$Name*" -ErrorAction SilentlyContinue
    } else {
        Write-Host "Usage: find <name> [path]" -ForegroundColor Yellow
    }
}

# Extract archives
function extract {
    param([string]$Path)
    
    if (-not $Path -or -not (Test-Path $Path)) {
        Write-Host "Usage: extract <archive-file>" -ForegroundColor Yellow
        return
    }
    
    $extension = [System.IO.Path]::GetExtension($Path).ToLower()
    
    switch ($extension) {
        ".zip" { Expand-Archive -Path $Path -DestinationPath . }
        ".7z" { 
            if (Get-Command 7z -ErrorAction SilentlyContinue) {
                7z x $Path
            } else {
                Write-Warning "7z command not found"
            }
        }
        default { Write-Warning "Unsupported archive format: $extension" }
    }
}

