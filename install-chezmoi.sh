#!/bin/bash
# Simplified Chezmoi Initialization Script
# Creates backup, installs Chezmoi, and provides rollback mechanism
# Requirements: 4.4, 7.3

set -euo pipefail

# Configuration
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
CHEZMOI_REPO="${CHEZMOI_REPO:-https://github.com/ln-one/dotfiles-chezmoi.git}"
LOG_FILE="./chezmoi-install.log"
CHEZMOI_SOURCE_DIR="$HOME/.local/share/chezmoi"
CHEZMOI_CONFIG_DIR="$HOME/.config/chezmoi"

# Colors and logging
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
log() { echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"; exit 1; }
info() { echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"; }

# Detect environment type
detect_environment() {
    if [[ -n "${SSH_CONNECTION:-}" ]] || [[ -n "${SSH_CLIENT:-}" ]]; then
        echo "server"
    elif [[ -f "/proc/version" ]] && grep -q "microsoft" "/proc/version"; then
        echo "wsl"
    elif [[ -n "${CONTAINER:-}" ]]; then
        echo "container"
    else
        echo "desktop"
    fi
}

# Create backup of existing dotfiles
create_backup() {
    log "Creating backup in $BACKUP_DIR..."
    mkdir -p "$BACKUP_DIR"
    
    local files=(".zshrc" ".bashrc" ".gitconfig" ".ssh/config" ".tmux.conf" ".shellrc")
    local backed_up=0
    
    for file in "${files[@]}"; do
        if [[ -f "$HOME/$file" ]]; then
            cp "$HOME/$file" "$BACKUP_DIR/" && backed_up=$((backed_up + 1))
            info "Backed up: $file"
        fi
    done
    
    # Backup entire .ssh directory if it exists
    [[ -d "$HOME/.ssh" ]] && cp -r "$HOME/.ssh" "$BACKUP_DIR/.ssh" && info "Backed up: .ssh directory"
    
    echo "$BACKUP_DIR" > "$HOME/.chezmoi-backup-location"
    log "Backup created successfully ($backed_up files)"
}

# Install Chezmoi
install_chezmoi() {
    if command -v chezmoi >/dev/null 2>&1; then
        log "Chezmoi already installed: $(chezmoi --version)"
        return 0
    fi
    
    log "Installing Chezmoi..."
    
    # Ensure ~/.local/bin directory exists
    mkdir -p "$HOME/.local/bin"
    
    if command -v curl >/dev/null 2>&1; then
        # Install Chezmoi to ~/.local/bin
        BINDIR="$HOME/.local/bin" sh -c "$(curl -fsLS get.chezmoi.io)" || error "Failed to install Chezmoi"
    else
        error "curl is required but not installed"
    fi
    
    # Add ~/.local/bin to PATH if not already there
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
        info "Added ~/.local/bin to PATH for this session"
    fi
    
    # Verify installation
    if command -v chezmoi >/dev/null 2>&1; then
        log "Chezmoi installed successfully: $(chezmoi --version)"
    else
        error "Chezmoi installation verification failed"
    fi
}

# Initialize Chezmoi with environment-specific config
init_chezmoi() {
    local env_type=$(detect_environment)
    log "Initializing Chezmoi for environment: $env_type"
    
    # Set environment variables for Chezmoi templates
    export CHEZMOI_ENVIRONMENT="$env_type"
    
    # Initialize Chezmoi (without --apply for safety)
    if [[ -d "$CHEZMOI_SOURCE_DIR" ]]; then
        warn "Chezmoi source directory already exists, updating..."
        chezmoi update || error "Failed to update Chezmoi"
    else
        chezmoi init "$CHEZMOI_REPO" || error "Failed to initialize Chezmoi"
    fi
    
    # Preview changes before applying
    info "Previewing changes..."
    chezmoi diff || true
    
    # Apply changes
    log "Applying Chezmoi configuration..."
    chezmoi apply || error "Failed to apply Chezmoi configuration"
    
    log "Chezmoi initialized successfully for $env_type environment"
}

# Cleanup function for failed installations
cleanup_failed_install() {
    warn "Cleaning up failed installation..."
    
    # Remove Chezmoi directories if they were created during this run
    [[ -d "$CHEZMOI_SOURCE_DIR" ]] && rm -rf "$CHEZMOI_SOURCE_DIR" && info "Removed Chezmoi source directory"
    [[ -d "$CHEZMOI_CONFIG_DIR" ]] && rm -rf "$CHEZMOI_CONFIG_DIR" && info "Removed Chezmoi config directory"
    
    # Remove Chezmoi binary if it was installed during this run
    local chezmoi_bin="$HOME/.local/bin/chezmoi"
    [[ -f "$chezmoi_bin" ]] && rm -f "$chezmoi_bin" && info "Removed Chezmoi binary"
    
    log "Cleanup completed"
}

# Rollback function
rollback() {
    local backup_location
    if [[ -f "$HOME/.chezmoi-backup-location" ]]; then
        backup_location=$(cat "$HOME/.chezmoi-backup-location")
        if [[ -d "$backup_location" ]]; then
            warn "Rolling back from $backup_location..."
            
            # Clean up current Chezmoi installation first
            cleanup_failed_install
            
            # Restore backed up files
            find "$backup_location" -type f -exec basename {} \; | while read -r file; do
                if [[ -f "$backup_location/$file" ]]; then
                    cp "$backup_location/$file" "$HOME/$file"
                    info "Restored: $file"
                fi
            done
            
            # Restore .ssh directory if it exists
            [[ -d "$backup_location/.ssh" ]] && cp -r "$backup_location/.ssh" "$HOME/.ssh"
            
            rm -f "$HOME/.chezmoi-backup-location"
            log "Rollback completed successfully"
        else
            error "Backup directory not found: $backup_location"
        fi
    else
        warn "No backup location file found"
    fi
}

# Verify installation
verify_installation() {
    log "Verifying installation..."
    
    # Check if Chezmoi is working
    if ! chezmoi --version >/dev/null 2>&1; then
        error "Chezmoi verification failed"
    fi
    
    # Check if source directory exists
    if [[ ! -d "$CHEZMOI_SOURCE_DIR" ]]; then
        error "Chezmoi source directory not found"
    fi
    
    # Check if basic config files were created
    local config_files=(".zshrc" ".bashrc")
    local missing_files=()
    
    for file in "${config_files[@]}"; do
        [[ ! -f "$HOME/$file" ]] && missing_files+=("$file")
    done
    
    if [[ ${#missing_files[@]} -gt 0 ]]; then
        warn "Some config files were not created: ${missing_files[*]}"
    fi
    
    log "Installation verification completed"
}

# Enhanced error handler
handle_error() {
    local exit_code=$?
    error "Installation failed with exit code $exit_code"
    
    # Attempt automatic cleanup and rollback
    if [[ -f "$HOME/.chezmoi-backup-location" ]]; then
        warn "Attempting automatic rollback..."
        cleanup_failed_install
        rollback
    else
        warn "No backup found, performing cleanup only..."
        cleanup_failed_install
    fi
    
    error "Installation failed. Check log file: $LOG_FILE"
}

# Main installation
main() {
    # Set up enhanced error handling
    trap 'handle_error' ERR
    
    case "${1:-}" in
        --rollback) rollback; exit 0 ;;
        --cleanup) cleanup_failed_install; exit 0 ;;
        --help) 
            echo "Usage: $0 [--rollback|--cleanup|--help]"
            echo "  --rollback  Restore from backup"
            echo "  --cleanup   Clean up failed installation"
            echo "  --help      Show this help"
            echo ""
            echo "Environment variables:"
            echo "  CHEZMOI_REPO  Git repository URL (default: https://github.com/ln-one/dotfiles-chezmoi.git)"
            exit 0 ;;
    esac
    
    # Initialize log file
    echo "Chezmoi Installation Log - $(date)" > "$LOG_FILE"
    
    log "Starting Chezmoi installation..."
    info "Environment: $(detect_environment)"
    info "Repository: $CHEZMOI_REPO"
    info "Log file: $LOG_FILE"
    
    # Pre-flight checks
    command -v curl >/dev/null 2>&1 || error "curl is required but not installed"
    command -v git >/dev/null 2>&1 || error "git is required but not installed"
    
    # Main installation steps
    create_backup
    install_chezmoi
    init_chezmoi
    verify_installation
    
    log "🎉 Installation completed successfully!"
    info "Backup saved to: $BACKUP_DIR"
    info "To rollback: bash $0 --rollback"
    info "Chezmoi source: $CHEZMOI_SOURCE_DIR"
    
    # Clean up trap
    trap - ERR
}

main "$@"