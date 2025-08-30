# ========================================
# Theme Management Functions
# ========================================

{{- if and (eq .chezmoi.os "linux") (not (env "SSH_CONNECTION")) (lookPath "gsettings") }}
# Only load theme functions on Linux desktop with GNOME

THEME_DIR="${THEME_DIR:-$HOME/.Theme/WhiteSur-gtk-theme}"
THEME_SCRIPT="$DOTFILES_DIR/scripts/tools/theme-manager.sh"

# Load shared color helpers
{{- includeTemplate "core/colors.sh" . }}

# Switch to dark theme (WhiteSur Dark)
dark() {
    _cyan "Switching to dark theme..."

    if [[ -x "$THEME_SCRIPT" ]]; then
        _cyan "Using theme manager script for dark theme..."
        "$THEME_SCRIPT" dark
        return $?
    fi

    {{- if .features.enable_gsettings }}
    if [[ -d "$THEME_DIR" ]]; then
        _cyan "Setting WhiteSur dark theme..."
        (
            cd "$THEME_DIR" || { _red "Cannot enter theme directory"; return 1; }
            gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark-blue' 2>/dev/null || true
            gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Dark-blue' 2>/dev/null || true
            if [[ -x "./install.sh" ]]; then
                _cyan "Running theme install script..."
                ./install.sh -l 2>/dev/null || _yellow "Theme install script failed"
            fi
            gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
            {{- if .features.enable_fcitx5 }}
            local fcitx5_config="$HOME/.config/fcitx5/conf/classicui.conf"
            if [[ -f "$fcitx5_config" ]]; then
                sed -i "s/^Theme=.*/Theme=macOS-dark/" "$fcitx5_config" 2>/dev/null || true
                fcitx5 -r 2>/dev/null || true
            fi
            {{- end }}
        )
        _green "Switched to WhiteSur dark theme"
    else
        _yellow "WhiteSur theme not installed, using default dark theme"
        gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
    fi
    {{- end }}
}

# Switch to light theme (WhiteSur Light)
light() {
    _cyan "Switching to light theme..."

    if [[ -x "$THEME_SCRIPT" ]]; then
        _cyan "Using theme manager script for light theme..."
        "$THEME_SCRIPT" light
        return $?
    fi

    {{- if .features.enable_gsettings }}
    if [[ -d "$THEME_DIR" ]]; then
        _cyan "Setting WhiteSur light theme..."
        (
            cd "$THEME_DIR" || { _red "Cannot enter theme directory"; return 1; }
            gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Light-blue' 2>/dev/null || true
            gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Light-blue' 2>/dev/null || true
            if [[ -x "./install.sh" ]]; then
                _cyan "Running theme install script..."
                ./install.sh -l -c light 2>/dev/null || _yellow "Theme install script failed"
            fi
            gsettings set org.gnome.desktop.interface color-scheme 'prefer-light' 2>/dev/null || true
            {{- if .features.enable_fcitx5 }}
            local fcitx5_config="$HOME/.config/fcitx5/conf/classicui.conf"
            if [[ -f "$fcitx5_config" ]]; then
                sed -i "s/^Theme=.*/Theme=macOS-light/" "$fcitx5_config" 2>/dev/null || true
                fcitx5 -r 2>/dev/null || true
            fi
            {{- end }}
        )
        _green "Switched to WhiteSur light theme"
    else
        _yellow "WhiteSur theme not installed, using default light theme"
        gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-light' 2>/dev/null || true
    fi
    {{- end }}
}

# Show theme status
themestatus() {
    _bold "Theme status:"
    echo ""

    if [[ -x "$THEME_SCRIPT" ]]; then
        "$THEME_SCRIPT" status
        return
    fi

    {{- if .features.enable_gsettings }}
    local gtk_theme=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'")
    local shell_theme=$(gsettings get org.gnome.shell.extensions.user-theme name 2>/dev/null | tr -d "'")
    local color_scheme=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null | tr -d "'")
    _cyan "GNOME theme:"
    echo "  GTK: ${gtk_theme:-unknown}"
    echo "  Shell: ${shell_theme:-unknown}"
    echo "  Color scheme: ${color_scheme:-unknown}"
    if [[ -d "$THEME_DIR" ]]; then
        _green "  WhiteSur: installed"
    else
        _red "  WhiteSur: not installed"
    fi
    {{- if .features.enable_fcitx5 }}
    local fcitx5_config="$HOME/.config/fcitx5/conf/classicui.conf"
    if [[ -f "$fcitx5_config" ]]; then
        local fcitx5_theme=$(grep "^Theme=" "$fcitx5_config" 2>/dev/null | cut -d'=' -f2 || echo "unset")
        _cyan "  fcitx5: ${fcitx5_theme}"
    fi
    {{- end }}
    {{- else }}
    _red "gsettings not available"
    {{- end }}
}

{{- else }}
# Placeholder functions for non-GNOME environments
dark()   { _yellow "WhiteSur theme switching is only available on Linux GNOME desktop"; }
light()  { _yellow "WhiteSur theme switching is only available on Linux GNOME desktop"; }
themestatus() { _yellow "Theme status is only available on Linux GNOME desktop"; }
{{- end }}