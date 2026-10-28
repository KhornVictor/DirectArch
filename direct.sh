#!/usr/bin/env sh
# ------------------------------------------------------------------------------
# Direct - Directory Navigation & Bookmark Manager Shell Integration
# Compatible with Zsh and Bash on Linux / Arch / Hyprland / macOS
# ------------------------------------------------------------------------------

# Detect the project directory if DIRECT_PROJECT_DIR is not already set
if [ -z "$DIRECT_PROJECT_DIR" ]; then
    if [ -n "$ZSH_VERSION" ]; then
        # Zsh: get script location
        DIRECT_PROJECT_DIR="${0:A:h}" 2>/dev/null
    elif [ -n "$BASH_SOURCE" ]; then
        # Bash: get script location
        DIRECT_PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
    fi
fi

# Fallback default if not detected
DIRECT_PROJECT_DIR="${DIRECT_PROJECT_DIR:-/home/victor/Tool/DirectV2}"

_direct_get_python() {
    if [ -x "${DIRECT_PROJECT_DIR}/.venv/bin/python" ]; then
        echo "${DIRECT_PROJECT_DIR}/.venv/bin/python"
    elif command -v python3 >/dev/null 2>&1; then
        echo "python3"
    elif command -v python >/dev/null 2>&1; then
        echo "python"
    else
        echo ""
    fi
}

direct() {
    local python_bin
    python_bin="$(_direct_get_python)"
    if [ -z "$python_bin" ]; then
        printf "\033[1;31mERROR\033[0m: Python 3.11+ is not found in PATH or .venv\n" >&2
        return 1
    fi

    local script_path="${DIRECT_PROJECT_DIR}/main.py"
    if [ ! -f "$script_path" ]; then
        printf "\033[1;31mERROR\033[0m: Direct script not found: %s\n" "$script_path" >&2
        return 1
    fi

    # Interactive menu (no arguments provided)
    if [ $# -eq 0 ]; then
        local jump_file
        jump_file="$(mktemp -t direct_jump.XXXXXX 2>/dev/null || echo "/tmp/direct_jump_${USER}_$$")"
        DIRECT_JUMP_FILE="$jump_file" DIRECT_CALLER_DIR="$PWD" "$python_bin" "$script_path"
        local exit_code=$?

        if [ -f "$jump_file" ]; then
            local target
            target="$(cat "$jump_file" 2>/dev/null)"
            rm -f "$jump_file"
            if [ $exit_code -eq 0 ] && [ -n "$target" ]; then
                # Expand tilde if present
                case "$target" in
                    "~"*) target="${HOME}${target#"~"}" ;;
                esac
                if [ -d "$target" ]; then
                    cd "$target" || return
                else
                    printf "\033[1;33mWARNING\033[0m: Selected directory does not exist: %s\n" "$target"
                fi
            fi
        fi
        return $exit_code
    fi

    # Direct passthrough for helper/listing flags
    case "$1" in
        -h|--help|help|-l|--list|ls|--list-keys|--complete)
            "$python_bin" "$script_path" "$@"
            return $?
            ;;
    esac

    # Shortcut jump: direct <name>
    local target
    target="$("$python_bin" "$script_path" "$1" 2>&1)"
    local exit_code=$?

    if [ $exit_code -eq 0 ] && [ -n "$target" ]; then
        # Expand tilde if present
        case "$target" in
            "~"*) target="${HOME}${target#"~"}" ;;
        esac
        if [ -d "$target" ]; then
            cd "$target" || return
        else
            printf "\033[1;31mERROR\033[0m: Directory does not exist on disk: %s\n" "$target" >&2
            return 1
        fi
    else
        printf "%s\n" "$target" >&2
        return $exit_code
    fi
}

# ------------------------------------------------------------------------------
# Shell Tab Completion Setup
# ------------------------------------------------------------------------------
if [ -n "$ZSH_VERSION" ]; then
    _direct_completion_zsh() {
        local python_bin
        python_bin="$(_direct_get_python)"
        [ -n "$python_bin" ] || return
        local -a shortcuts
        shortcuts=("${(@f)$("$python_bin" "${DIRECT_PROJECT_DIR}/main.py" --list-keys 2>/dev/null)}")
        _describe 'shortcuts' shortcuts
    }
    compdef _direct_completion_zsh direct 2>/dev/null || true
elif [ -n "$BASH_VERSION" ]; then
    _direct_completion_bash() {
        local python_bin
        python_bin="$(_direct_get_python)"
        [ -n "$python_bin" ] || return
        local cur="${COMP_WORDS[COMP_CWORD]}"
        local shortcuts
        shortcuts="$("$python_bin" "${DIRECT_PROJECT_DIR}/main.py" --list-keys 2>/dev/null)"
        COMPREPLY=($(compgen -W "$shortcuts" -- "$cur"))
    }
    complete -F _direct_completion_bash direct 2>/dev/null || true
fi
