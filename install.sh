#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Direct Installer for Linux / Arch / Hyprland / macOS
# ------------------------------------------------------------------------------

set -e

INSTALL_DIR="${1:-$HOME/Tool/DirectV2}"
REPO_URL="https://github.com/KhornVictor/DirectV2.git"

printf "\n\033[1;36m🚀 Installing Direct...\033[0m\n\n"

# 1. Prerequisite checks
if ! command -v git >/dev/null 2>&1; then
    printf "\033[1;31m❌ Error: Git is not installed or not in PATH.\033[0m\n" >&2
    exit 1
fi

PYTHON_CMD=""
if command -v python3 >/dev/null 2>&1; then
    PYTHON_CMD="python3"
elif command -v python >/dev/null 2>&1; then
    PYTHON_CMD="python"
fi

if [ -z "$PYTHON_CMD" ]; then
    printf "\033[1;31m❌ Error: Python 3.11+ is not installed or not in PATH.\033[0m\n" >&2
    exit 1
fi

# Check Python version >= 3.11
PY_VERSION="$("$PYTHON_CMD" -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
PY_MAJOR="$("$PYTHON_CMD" -c 'import sys; print(sys.version_info.major)')"
PY_MINOR="$("$PYTHON_CMD" -c 'import sys; print(sys.version_info.minor)')"

if [ "$PY_MAJOR" -lt 3 ] || { [ "$PY_MAJOR" -eq 3 ] && [ "$PY_MINOR" -lt 11 ]; }; then
    printf "\033[1;31m❌ Error: Python 3.11+ is required (found %s).\033[0m\n" "$PY_VERSION" >&2
    exit 1
fi

# 2. Prepare destination directory and clone repository
if [ -d "$INSTALL_DIR/.git" ]; then
    printf "\033[1;33mℹ️  Direct repository already exists at %s. Updating...\033[0m\n" "$INSTALL_DIR"
    git -C "$INSTALL_DIR" pull origin main || printf "\033[1;33m⚠️ Warning: Failed to pull latest changes from remote. Using existing files.\033[0m\n"
elif [ -d "$INSTALL_DIR" ]; then
    printf "\033[1;33mℹ️  Target folder %s already exists.\033[0m\n" "$INSTALL_DIR"
else
    printf "\033[1;36m📦 Cloning Direct repository into %s...\033[0m\n" "$INSTALL_DIR"
    mkdir -p "$(dirname "$INSTALL_DIR")"
    git clone "$REPO_URL" "$INSTALL_DIR"
fi

# 3. Setup Python virtual environment
printf "\033[1;36m🐍 Setting up Python virtual environment...\033[0m\n"
VENV_PATH="$INSTALL_DIR/.venv"
if [ ! -d "$VENV_PATH" ]; then
    "$PYTHON_CMD" -m venv "$VENV_PATH"
    printf "\033[1;32m✓ Virtual environment created at %s\033[0m\n" "$VENV_PATH"
else
    printf "\033[1;32m✓ Virtual environment already exists at %s\033[0m\n" "$VENV_PATH"
fi

# Ensure executable permissions
chmod +x "$INSTALL_DIR/direct.sh" 2>/dev/null || true

# 4. Display or configure shell configuration
printf "\n\033[1;32m========================================================\033[0m\n"
printf "\033[1;32m🎉 Direct has been installed successfully at: %s\033[0m\n" "$INSTALL_DIR"
printf "\033[1;32m========================================================\033[0m\n\n"

SNIPPET="
# --- Direct: Directory Navigation & Bookmark Manager ---
export DIRECT_PROJECT_DIR=\"$INSTALL_DIR\"
if [ -f \"\$DIRECT_PROJECT_DIR/direct.sh\" ]; then
    source \"\$DIRECT_PROJECT_DIR/direct.sh\"
fi"

# Add to ~/.zshrc or ~/.bashrc if not already present
ADDED=0
for RC_FILE in "$HOME/.zshrc" "$HOME/.bashrc"; do
    if [ -f "$RC_FILE" ]; then
        if ! grep -q "DIRECT_PROJECT_DIR" "$RC_FILE"; then
            printf "%s\n" "$SNIPPET" >> "$RC_FILE"
            printf "\033[1;32m✓ Added Direct configuration to %s\033[0m\n" "$RC_FILE"
            ADDED=1
        else
            printf "\033[1;33mℹ️  Direct configuration already exists in %s\033[0m\n" "$RC_FILE"
        fi
    fi
done

if [ "$ADDED" -eq 1 ]; then
    printf "\n\033[1;33m📌 Reload your shell session:\033[0m\n"
    if [ -n "$ZSH_VERSION" ] || [ -f "$HOME/.zshrc" ]; then
        printf "   source ~/.zshrc\n"
    else
        printf "   source ~/.bashrc\n"
    fi
fi

printf "\n\033[1;33m💡 Usage:\033[0m\n"
printf "   direct        # Open interactive menu (List, Jump, Add, Update, Remove)\n"
printf "   direct <name> # Jump directly to bookmark (e.g. direct hypr)\n"
printf "   direct -l     # List bookmarks non-interactively\n\n"
