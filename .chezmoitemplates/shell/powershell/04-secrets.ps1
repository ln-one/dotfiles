# ========================================
# 1Password Secrets Integration
# ========================================

{{- if .features.enable_1password }}
# 1Password CLI and SSH Agent integration
if (Get-Command op -ErrorAction SilentlyContinue) {
    # Test if 1Password SSH agent is available
    try {
        $null = ssh-add -l 2>$null
    } catch {
        Write-Warning "1Password SSH Agent not available. Make sure SSH agent is enabled in 1Password settings."
    }
    
    # Load 1Password secrets if available
    $secretsFile = "$env:USERPROFILE\.secrets.ps1"
    if (Test-Path $secretsFile) {
        . $secretsFile
    }
} else {
    Write-Host "1Password CLI not available, using fallback configuration" -ForegroundColor Yellow
}

{{- if .features.enable_ai_tools }}
# AI tools configuration
if ($env:OPENAI_API_KEY) {
}
{{- end }}
{{- else }}
Write-Host "1Password integration disabled" -ForegroundColor Yellow
{{- end }}