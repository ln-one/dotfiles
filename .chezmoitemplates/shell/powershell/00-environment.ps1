# ========================================
# PowerShell Environment Configuration
# ========================================

# Basic environment variables
$env:EDITOR = "{{ .preferences.editor }}"
$env:VISUAL = "{{ .preferences.editor }}"
$env:PAGER = "less"
$env:LANG = "en_US.UTF-8"

# Windows-specific optimizations
$env:POWERSHELL_TELEMETRY_OPTOUT = 1
$env:DOTNET_CLI_TELEMETRY_OPTOUT = 1

# Ensure local bin directory exists and is in PATH
$localBin = "$env:USERPROFILE\.local\bin"
if (-not (Test-Path $localBin)) {
    New-Item -ItemType Directory -Path $localBin -Force | Out-Null
}

if ($env:PATH -notlike "*$localBin*") {
    $env:PATH = "$localBin;$env:PATH"
}

# Refresh PATH to ensure newly installed tools are available
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")

{{- if and .features.enable_proxy .proxy.enabled }}
# Proxy configuration
{{- $http_proxy := .proxy.http_proxy | default "" }}
{{- $https_proxy := .proxy.https_proxy | default "" }}
{{- if $http_proxy }}
$env:HTTP_PROXY = "{{ $http_proxy }}"
$env:http_proxy = "{{ $http_proxy }}"
{{- end }}
{{- if $https_proxy }}
$env:HTTPS_PROXY = "{{ $https_proxy }}"
$env:https_proxy = "{{ $https_proxy }}"
{{- end }}
$env:NO_PROXY = "localhost,127.0.0.1,::1,.local"
$env:no_proxy = $env:NO_PROXY
{{- end }}