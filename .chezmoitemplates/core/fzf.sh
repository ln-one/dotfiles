# ========================================
# FZF unified integration configuration
# ========================================

{{- if .features.enable_fzf }}

# 1. Plugin loading
# forgit - Git fzf enhancement
{{- if eq (base .chezmoi.targetFile) ".zshrc" }}
  {{- if and .features.enable_git .features.enable_forgit }}
    {{- if stat (joinPath (env "HOMEBREW_PREFIX" | default "/opt/homebrew") "share/forgit/forgit.plugin.zsh") }}
      {{- if eq .chezmoi.os "darwin" }}
        source "/opt/homebrew/share/forgit/forgit.plugin.zsh"
      {{- else if eq .chezmoi.os "linux" }}
        source "/home/linuxbrew/.linuxbrew/share/forgit/forgit.plugin.zsh"
      {{- end }}
    {{- else if stat (joinPath .chezmoi.homeDir ".forgit/forgit.plugin.zsh") }}
      source "${HOME}/.forgit/forgit.plugin.zsh"
    {{- end }}
  {{- end }}
{{- end }}

# fzf-tab - Better completion experience
{{- if eq (base .chezmoi.targetFile) ".zshrc" }}
  {{- if stat (joinPath (env "ZIM_HOME" | default (joinPath .chezmoi.homeDir ".zim")) "modules/fzf-tab/fzf-tab.plugin.zsh") }}
    source "${ZIM_HOME}/modules/fzf-tab/fzf-tab.plugin.zsh"
  {{- else if stat (joinPath (env "HOMEBREW_PREFIX" | default "/opt/homebrew") "share/fzf-tab/fzf-tab.plugin.zsh") }}
    {{- if eq .chezmoi.os "darwin" }}
      source "/opt/homebrew/share/fzf-tab/fzf-tab.plugin.zsh"
    {{- else if eq .chezmoi.os "linux" }}
      source "/home/linuxbrew/.linuxbrew/share/fzf-tab/fzf-tab.plugin.zsh"
    {{- end }}
  {{- end }}
{{- end }}

# 2. fzf environment variables and behavior
export FZF_DEFAULT_OPTS="
  --height 40%
  --layout=reverse
  --border=rounded
  --info=inline-right
  --marker='▶'
  --pointer='◆'
  --separator='─'
  --scrollbar='│'
  --preview-window=:hidden
  --bind='ctrl-/:toggle-preview'
  --bind='ctrl-u:preview-page-up'
  --bind='ctrl-d:preview-page-down'
  --bind='ctrl-f:preview-page-down'
  --bind='ctrl-b:preview-page-up'
  --color=dark
  --color=fg:-1,bg:-1,hl:#c678dd,fg+:#ffffff,bg+:#4b5263,hl+:#d858fe
  --color=info:#98c379,prompt:#61afef,pointer:#be5046,marker:#e5c07b,spinner:#61afef,header:#61afef
  --color=border:#4b5263,separator:#4b5263,scrollbar:#4b5263
"

# 3. File/directory search command
{{- if or (stat "/opt/homebrew") (stat "/home/linuxbrew/.linuxbrew") }}
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --strip-cwd-prefix'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git --strip-cwd-prefix'
{{- else }}
  export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/\.git/*" 2>/dev/null'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
{{- end }}

# 4. Preview behavior
{{- if or (stat "/opt/homebrew") (stat "/home/linuxbrew/.linuxbrew") }}
  export FZF_CTRL_T_OPTS="
    --preview '([[ -f {} ]] && (bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || cat {} 2>/dev/null || echo {})) || ([[ -d {} ]] && (eza --tree --level=2 --color=always {} 2>/dev/null || tree -C -L 2 {} 2>/dev/null || ls -la {} 2>/dev/null))'
    --preview-window='right:50%:wrap'
    --bind='ctrl-/:change-preview-window(down,50%|right,50%|hidden|)'
    --bind='ctrl-y:execute-silent(echo {} | pbcopy)'
  "

  export FZF_ALT_C_OPTS="
    --preview 'eza --tree --level=2 --color=always {} 2>/dev/null || tree -C -L 2 {} 2>/dev/null || ls -la {} 2>/dev/null'
    --preview-window='right:50%:wrap'
    --bind='ctrl-/:change-preview-window(down,50%|right,50%|hidden|)'
  "
{{- else }}
  export FZF_CTRL_T_OPTS="
    --preview '([[ -f {} ]] && (bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || cat {} 2>/dev/null || echo {})) || ([[ -d {} ]] && (eza --tree --level=2 --color=always {} 2>/dev/null || tree -C -L 2 {} 2>/dev/null || ls -la {} 2>/dev/null))'
    --preview-window='right:50%:wrap'
    --bind='ctrl-/:change-preview-window(down,50%|right,50%|hidden|)'
    --bind='ctrl-y:execute-silent(echo {} | pbcopy)'
  "

  export FZF_ALT_C_OPTS="
    --preview 'eza --tree --level=2 --color=always {} 2>/dev/null || tree -C -L 2 {} 2>/dev/null || ls -la {} 2>/dev/null'
    --preview-window='right:50%:wrap'
    --bind='ctrl-/:change-preview-window(down,50%|right,50%|hidden|)'
  "
{{- end }}

# 5. History command search
export FZF_CTRL_R_OPTS="
  --preview 'echo {}'
  --preview-window='down:3:wrap'
  --bind='ctrl-/:toggle-preview'
  --bind='ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color='header:italic'
  --header='Press CTRL-Y to copy command into clipboard'
"

{{- else }}
# fzf feature is disabled
{{- end }}
