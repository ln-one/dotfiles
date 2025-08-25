# Enhanced Environment Detection Module
# Implements intelligent environment detection for chezmoi layered configuration
# Requirements: 5.1, 5.2

# Global variables for detection results
DETECTED_ENVIRONMENT=""
DETECTION_CONFIDENCE="unknown"
DETECTION_METHODS=()

# Logging functions for detection process
log_detection() {
    local level="$1"
    local message="$2"
    if [[ "${CHEZMOI_DEBUG:-}" == "true" ]]; then
        echo "[DETECTION-$level] $message" >&2
    fi
}

# Container environment detection
detect_container() {
    log_detection "DEBUG" "Checking for container environment"
    
    # Docker container detection
    if [[ -f "/.dockerenv" ]]; then
        DETECTION_METHODS+=("dockerenv_file")
        log_detection "INFO" "Container detected via /.dockerenv"
        return 0
    fi
    
    # Podman container detection
    if [[ -f "/run/.containerenv" ]]; then
        DETECTION_METHODS+=("containerenv_file")
        log_detection "INFO" "Container detected via /run/.containerenv"
        return 0
    fi
    
    # Additional container indicators
    if [[ -n "${container:-}" ]]; then
        DETECTION_METHODS+=("container_env_var")
        log_detection "INFO" "Container detected via \$container variable"
        return 0
    fi
    
    # Check for container-specific cgroups (v1 and v2)
    if [[ -f "/proc/1/cgroup" ]]; then
        if grep -q "docker\|lxc\|containerd" /proc/1/cgroup 2>/dev/null; then
            DETECTION_METHODS+=("cgroup_analysis")
            log_detection "INFO" "Container detected via cgroup analysis"
            return 0
        fi
    fi
    
    log_detection "DEBUG" "No container environment detected"
    return 1
}

# WSL environment detection
detect_wsl() {
    log_detection "DEBUG" "Checking for WSL environment"
    
    # WSL2 detection via environment variable
    if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
        DETECTION_METHODS+=("wsl_distro_name")
        log_detection "INFO" "WSL detected via \$WSL_DISTRO_NAME: $WSL_DISTRO_NAME"
        return 0
    fi
    
    # WSL detection via /proc/version
    if [[ -f "/proc/version" ]]; then
        if grep -qi "microsoft\|wsl" /proc/version 2>/dev/null; then
            DETECTION_METHODS+=("proc_version")
            log_detection "INFO" "WSL detected via /proc/version"
            return 0
        fi
    fi
    
    # WSL detection via /proc/sys/kernel/osrelease
    if [[ -f "/proc/sys/kernel/osrelease" ]]; then
        if grep -qi "microsoft\|wsl" /proc/sys/kernel/osrelease 2>/dev/null; then
            DETECTION_METHODS+=("kernel_osrelease")
            log_detection "INFO" "WSL detected via kernel osrelease"
            return 0
        fi
    fi
    
    # WSL interop detection
    if [[ -n "${WSLENV:-}" ]]; then
        DETECTION_METHODS+=("wslenv")
        log_detection "INFO" "WSL detected via \$WSLENV"
        return 0
    fi
    
    log_detection "DEBUG" "No WSL environment detected"
    return 1
}

# SSH remote environment detection
detect_remote() {
    log_detection "DEBUG" "Checking for remote SSH environment"
    
    # SSH connection detection
    if [[ -n "${SSH_CONNECTION:-}" ]]; then
        DETECTION_METHODS+=("ssh_connection")
        log_detection "INFO" "Remote SSH detected via \$SSH_CONNECTION"
        return 0
    fi
    
    if [[ -n "${SSH_CLIENT:-}" ]]; then
        DETECTION_METHODS+=("ssh_client")
        log_detection "INFO" "Remote SSH detected via \$SSH_CLIENT"
        return 0
    fi
    
    if [[ -n "${SSH_TTY:-}" ]]; then
        DETECTION_METHODS+=("ssh_tty")
        log_detection "INFO" "Remote SSH detected via \$SSH_TTY"
        return 0
    fi
    
    # Check for SSH agent forwarding
    if [[ -n "${SSH_AUTH_SOCK:-}" ]] && [[ "${SSH_AUTH_SOCK}" =~ /tmp/ssh- ]]; then
        DETECTION_METHODS+=("ssh_agent_forwarding")
        log_detection "INFO" "Remote SSH detected via SSH agent forwarding"
        return 0
    fi
    
    log_detection "DEBUG" "No remote SSH environment detected"
    return 1
}

# Desktop environment detection
detect_desktop() {
    log_detection "DEBUG" "Checking for desktop environment"
    
    # X11 display detection
    if [[ -n "${DISPLAY:-}" ]]; then
        DETECTION_METHODS+=("x11_display")
        log_detection "INFO" "Desktop detected via \$DISPLAY: $DISPLAY"
        return 0
    fi
    
    # Wayland display detection
    if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
        DETECTION_METHODS+=("wayland_display")
        log_detection "INFO" "Desktop detected via \$WAYLAND_DISPLAY: $WAYLAND_DISPLAY"
        return 0
    fi
    
    # Desktop session detection
    if [[ -n "${XDG_SESSION_TYPE:-}" ]]; then
        case "${XDG_SESSION_TYPE}" in
            "x11"|"wayland")
                DETECTION_METHODS+=("xdg_session_type")
                log_detection "INFO" "Desktop detected via \$XDG_SESSION_TYPE: $XDG_SESSION_TYPE"
                return 0
                ;;
        esac
    fi
    
    # GUI process detection (fallback)
    if command -v pgrep >/dev/null 2>&1; then
        local gui_processes=("gnome-session" "kde-session" "xfce4-session" "lxsession" "mate-session")
        for process in "${gui_processes[@]}"; do
            if pgrep -x "$process" >/dev/null 2>&1; then
                DETECTION_METHODS+=("gui_process_$process")
                log_detection "INFO" "Desktop detected via GUI process: $process"
                return 0
            fi
        done
    fi
    
    # macOS desktop detection
    if [[ "$(uname -s)" == "Darwin" ]]; then
        # Check for macOS GUI session
        if [[ -n "${TERM_PROGRAM:-}" ]] || command -v osascript >/dev/null 2>&1; then
            DETECTION_METHODS+=("macos_gui")
            log_detection "INFO" "Desktop detected on macOS"
            return 0
        fi
    fi
    
    log_detection "DEBUG" "No desktop environment detected"
    return 1
}

# Main environment detection function
detect_environment() {
    log_detection "INFO" "Starting environment detection"
    
    # Reset detection state
    DETECTED_ENVIRONMENT=""
    DETECTION_CONFIDENCE="unknown"
    DETECTION_METHODS=()
    
    # Detection priority order (as per design document)
    # 1. Container (highest priority)
    if detect_container; then
        DETECTED_ENVIRONMENT="container"
        DETECTION_CONFIDENCE="high"
    # 2. WSL
    elif detect_wsl; then
        DETECTED_ENVIRONMENT="wsl"
        DETECTION_CONFIDENCE="high"
    # 3. Remote SSH
    elif detect_remote; then
        DETECTED_ENVIRONMENT="remote"
        DETECTION_CONFIDENCE="high"
    # 4. Desktop (default fallback)
    elif detect_desktop; then
        DETECTED_ENVIRONMENT="desktop"
        DETECTION_CONFIDENCE="medium"
    else
        # No environment detected - use fallback
        DETECTED_ENVIRONMENT="desktop"
        DETECTION_CONFIDENCE="low"
        DETECTION_METHODS+=("fallback_default")
        log_detection "WARN" "No specific environment detected, using desktop fallback"
    fi
    
    log_detection "INFO" "Environment detection complete: $DETECTED_ENVIRONMENT (confidence: $DETECTION_CONFIDENCE)"
    log_detection "DEBUG" "Detection methods used: ${DETECTION_METHODS[*]}"
    
    echo "$DETECTED_ENVIRONMENT"
}

# Get detection confidence level
get_detection_confidence() {
    echo "$DETECTION_CONFIDENCE"
}

# Get detection methods used
get_detection_methods() {
    printf '%s\n' "${DETECTION_METHODS[@]}"
}

# Validate detected environment
validate_environment() {
    local env="$1"
    case "$env" in
        "container"|"wsl"|"remote"|"desktop")
            return 0
            ;;
        *)
            log_detection "ERROR" "Invalid environment: $env"
            return 1
            ;;
    esac
}

# Export functions for use in other scripts
export -f detect_environment
export -f get_detection_confidence
export -f get_detection_methods
export -f validate_environment

# Environment Detection Failure Handling
# Requirements: 5.3, 5.4

# Manual environment override support
get_manual_environment() {
    local manual_env=""
    
    # Check for manual environment specification (highest priority)
    if [[ -n "${CHEZMOI_ENVIRONMENT:-}" ]]; then
        manual_env="$CHEZMOI_ENVIRONMENT"
        log_detection "INFO" "Manual environment specified via \$CHEZMOI_ENVIRONMENT: $manual_env"
    elif [[ -n "${FORCE_ENVIRONMENT:-}" ]]; then
        manual_env="$FORCE_ENVIRONMENT"
        log_detection "INFO" "Manual environment specified via \$FORCE_ENVIRONMENT: $manual_env"
    fi
    
    # Validate manual environment
    if [[ -n "$manual_env" ]]; then
        if validate_environment "$manual_env"; then
            echo "$manual_env"
            return 0
        else
            log_detection "ERROR" "Invalid manual environment specified: $manual_env"
            return 1
        fi
    fi
    
    return 1
}

# Fallback environment detection with safety mechanisms
detect_environment_with_fallback() {
    log_detection "INFO" "Starting environment detection with fallback handling"
    
    # Reset detection state
    DETECTED_ENVIRONMENT=""
    DETECTION_CONFIDENCE="unknown"
    DETECTION_METHODS=()
    
    # 1. Check for manual environment override first
    local manual_env
    if manual_env=$(get_manual_environment); then
        DETECTED_ENVIRONMENT="$manual_env"
        DETECTION_CONFIDENCE="manual"
        DETECTION_METHODS+=("manual_override")
        log_detection "INFO" "Using manual environment override: $DETECTED_ENVIRONMENT"
        echo "$DETECTED_ENVIRONMENT"
        return 0
    fi
    
    # 2. Attempt automatic detection
    local auto_detected
    if auto_detected=$(detect_environment); then
        # Verify the detection result
        if validate_environment "$auto_detected" && [[ "$DETECTION_CONFIDENCE" != "unknown" ]]; then
            log_detection "INFO" "Automatic detection successful: $auto_detected"
            echo "$auto_detected"
            return 0
        else
            log_detection "WARN" "Automatic detection returned invalid result: $auto_detected"
        fi
    fi
    
    # 3. Detection failed - use intelligent fallback
    log_detection "WARN" "Environment detection failed, applying fallback strategy"
    
    # Fallback strategy based on available indicators
    local fallback_env="desktop"  # Safe default
    
    # Check for minimal indicators to make educated guess
    if [[ -f "/.dockerenv" ]] || [[ -f "/run/.containerenv" ]]; then
        fallback_env="container"
        DETECTION_METHODS+=("fallback_container_files")
    elif [[ -n "${SSH_CONNECTION:-}${SSH_CLIENT:-}${SSH_TTY:-}" ]]; then
        fallback_env="remote"
        DETECTION_METHODS+=("fallback_ssh_vars")
    elif [[ -n "${WSL_DISTRO_NAME:-}" ]] || grep -qi "microsoft\|wsl" /proc/version 2>/dev/null; then
        fallback_env="wsl"
        DETECTION_METHODS+=("fallback_wsl_indicators")
    else
        # Default to desktop for safety
        fallback_env="desktop"
        DETECTION_METHODS+=("fallback_safe_default")
    fi
    
    DETECTED_ENVIRONMENT="$fallback_env"
    DETECTION_CONFIDENCE="fallback"
    
    log_detection "INFO" "Fallback environment selected: $DETECTED_ENVIRONMENT"
    echo "$DETECTED_ENVIRONMENT"
    return 0
}

# Recovery mechanism for detection failures
recover_from_detection_failure() {
    local error_context="$1"
    
    log_detection "ERROR" "Detection failure context: $error_context"
    
    # Create a safe minimal environment configuration
    DETECTED_ENVIRONMENT="desktop"
    DETECTION_CONFIDENCE="recovery"
    DETECTION_METHODS+=("recovery_mode")
    
    log_detection "WARN" "Entering recovery mode with minimal desktop configuration"
    
    # Set safe environment variables for recovery
    export CHEZMOI_RECOVERY_MODE="true"
    export CHEZMOI_DETECTED_ENV="$DETECTED_ENVIRONMENT"
    
    echo "$DETECTED_ENVIRONMENT"
}

# Comprehensive environment detection with error handling
safe_detect_environment() {
    local max_retries=3
    local retry_count=0
    local detected_env=""
    
    log_detection "INFO" "Starting safe environment detection"
    
    while [[ $retry_count -lt $max_retries ]]; do
        retry_count=$((retry_count + 1))
        log_detection "DEBUG" "Detection attempt $retry_count of $max_retries"
        
        # Attempt detection with error handling
        if detected_env=$(detect_environment_with_fallback 2>/dev/null); then
            if validate_environment "$detected_env"; then
                log_detection "INFO" "Safe detection successful on attempt $retry_count: $detected_env"
                export CHEZMOI_DETECTED_ENV="$detected_env"
                export CHEZMOI_DETECTION_CONFIDENCE="$DETECTION_CONFIDENCE"
                echo "$detected_env"
                return 0
            else
                log_detection "WARN" "Detection attempt $retry_count returned invalid environment: $detected_env"
            fi
        else
            log_detection "WARN" "Detection attempt $retry_count failed"
        fi
        
        # Brief pause between retries
        sleep 0.1
    done
    
    # All retries failed - enter recovery mode
    log_detection "ERROR" "All detection attempts failed, entering recovery mode"
    detected_env=$(recover_from_detection_failure "max_retries_exceeded")
    
    export CHEZMOI_DETECTED_ENV="$detected_env"
    export CHEZMOI_DETECTION_CONFIDENCE="$DETECTION_CONFIDENCE"
    echo "$detected_env"
    return 1  # Indicate that fallback was used
}

# Environment detection status check
check_detection_status() {
    echo "Environment Detection Status:"
    echo "  Detected Environment: ${DETECTED_ENVIRONMENT:-unknown}"
    echo "  Detection Confidence: ${DETECTION_CONFIDENCE:-unknown}"
    echo "  Detection Methods: ${DETECTION_METHODS[*]:-none}"
    echo "  Recovery Mode: ${CHEZMOI_RECOVERY_MODE:-false}"
    
    if [[ "${DETECTION_CONFIDENCE}" == "fallback" ]] || [[ "${DETECTION_CONFIDENCE}" == "recovery" ]]; then
        echo "  Status: WARNING - Using fallback detection"
        return 1
    elif [[ "${DETECTION_CONFIDENCE}" == "low" ]]; then
        echo "  Status: CAUTION - Low confidence detection"
        return 2
    else
        echo "  Status: OK"
        return 0
    fi
}

# Export additional functions
export -f detect_environment_with_fallback
export -f safe_detect_environment
export -f check_detection_status
export -f get_manual_environment
export -f recover_from_detection_failure

# Set up detection result variables for use by other scripts
if [[ -z "${CHEZMOI_DETECTED_ENV:-}" ]]; then
    # Perform initial detection if not already done
    CHEZMOI_DETECTED_ENV=$(safe_detect_environment)
    export CHEZMOI_DETECTED_ENV
fi