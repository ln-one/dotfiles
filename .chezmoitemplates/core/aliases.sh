# ========================================
# Common Aliases
# ========================================
# Static aliases based on feature flags, no runtime detection

{{- $ls_tool := .preferences.ls_tool | default "ls" }}
{{- if eq $ls_tool "eza" }}
# Eza aliases
alias ls='eza --color=auto --icons'
alias ll='eza -alF --color=auto --icons --git'
alias la='eza -a --color=auto --icons'
alias l='eza -F --color=auto --icons'
alias tree='eza --tree --color=auto --icons'
{{- else if eq $ls_tool "exa" }}
# Exa aliases
alias ls='exa --color=auto --icons'
alias ll='exa -alF --color=auto --icons --git'
alias la='exa -a --color=auto --icons'
alias l='exa -F --color=auto --icons'
alias tree='exa --tree --color=auto --icons'
{{- else }}
# Traditional ls aliases
{{- if eq .chezmoi.os "linux" }}
alias ls='ls --color=auto'
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
{{- else if eq .chezmoi.os "darwin" }}
alias ls='ls -G'
alias ll='ls -alFG'
alias la='ls -AG'
alias l='ls -CFG'
{{- end }}
{{- end }}

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Create parent directories
alias mkdir='mkdir -pv'

# Safe operations
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Disk usage
alias df='df -h'

# Process viewing
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias psgrep='ps aux | grep -v grep | grep'

# Network and System
alias ping='ping -c 5'
alias ports='netstat -tulanp'

# System info
{{- if eq .chezmoi.os "linux" }}
alias meminfo='free -m -l -t'
alias cpuinfo='lscpu'
{{- else if eq .chezmoi.os "darwin" }}
alias meminfo='vm_stat'
alias cpuinfo='sysctl -n machdep.cpu.brand_string'
{{- end }}

# Development Tools

# Docker shortcuts (based on feature flag)
{{- if eq .environment "desktop" }}
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs -f'
{{- end }}

# Quick Actions

# Clear screen
alias c='clear'
alias cls='clear'

# History search
alias h='history'
alias hg='history | grep'

# Platform-specific Aliases

{{- if eq .chezmoi.os "darwin" }}
# macOS specific aliases
alias finder='open -a Finder .'
alias preview='open -a Preview'
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'
alias python="python3"
{{- else if eq .chezmoi.os "linux" }}
# Linux specific aliases
alias service='sudo systemctl'
alias journal='sudo journalctl'
{{- end }}