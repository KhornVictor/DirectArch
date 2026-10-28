# DirectV2 🚀

A lightweight, fast directory navigation and shortcut bookmark manager for Linux (Arch / Hyprland / Zsh / Bash) and Windows (PowerShell).

Jump instantly to any project directory, or launch an interactive terminal menu to browse, add, update, and remove paths.

---

## 📋 What is Direct?

Direct replaces long `cd` navigation paths with short, memorable aliases.

- **Instant Directory Jump**: Type `direct <name>` (e.g., `direct hypr`, `direct tool`) to jump directly to any configured folder.
- **Interactive Terminal Menu**: Type `direct` with no arguments to view all bookmarks with options to:
  - Jump to a path by number or name
  - **Add** a new path shortcut (defaults to your current directory if omitted)
  - **Update** existing destination folders
  - **Remove** shortcuts
- **Environment & Tilde Expansion**: Supports `~` (e.g. `~/.config/hypr`) and environment variables (`$HOME`, `$VAR`).
- **TOML Configuration**: All shortcuts are automatically synchronized with [`path.toml`](path.toml).
- **Tab Completion**: Type `direct ` and press `Tab` in Zsh, Bash, or PowerShell to auto-complete configured shortcut names.
- **Zero Overhead**: Direct sub-second jumps.

---

## ⚙️ Requirements

- **Operating System**: Linux (Arch, Ubuntu, Fedora, etc.) or Windows 10/11
- **Shell**: Zsh, Bash, or PowerShell 5.1 / 7+
- **Python**: Python 3.11 or higher
- **Git**: Git in your `PATH`

---

## 📥 Installation

### 🐧 Linux (Arch / Hyprland / Zsh / Bash)

#### Option 1: Quick Install (Recommended)

Run the installer script:

```bash
curl -fsSL https://raw.githubusercontent.com/KhornVictor/DirectV2/main/install.sh | bash
```

Or run `install.sh` from your cloned directory:

```bash
./install.sh
```

#### Option 2: Manual Setup

1. **Clone the repository**:

   ```bash
   git clone https://github.com/KhornVictor/DirectV2.git ~/Tool/DirectV2
   ```

2. **Setup Python virtual environment**:

   ```bash
   cd ~/Tool/DirectV2
   python3 -m venv .venv
   ```

3. **Add Direct to your shell profile**:

   For **Zsh** (`~/.zshrc`):
   ```zsh
   # --- Direct: Directory Navigation & Bookmark Manager ---
   export DIRECT_PROJECT_DIR="$HOME/Tool/DirectV2"
   if [ -f "$DIRECT_PROJECT_DIR/direct.sh" ]; then
       source "$DIRECT_PROJECT_DIR/direct.sh"
   fi
   ```

   For **Bash** (`~/.bashrc`):
   ```bash
   # --- Direct: Directory Navigation & Bookmark Manager ---
   export DIRECT_PROJECT_DIR="$HOME/Tool/DirectV2"
   if [ -f "$DIRECT_PROJECT_DIR/direct.sh" ]; then
       source "$DIRECT_PROJECT_DIR/direct.sh"
   fi
   ```

4. **Reload your shell**:

   ```bash
   source ~/.zshrc    # for zsh
   source ~/.bashrc   # for bash
   ```

---

### 🪟 Windows (PowerShell)

1. **Clone and setup**:

   ```powershell
   git clone https://github.com/KhornVictor/DirectV2.git C:\Tool\Direct
   python -m venv C:\Tool\Direct\.venv
   ```

2. **Add to your PowerShell profile** (`notepad $PROFILE`):

   ```powershell
   # --- Direct: Directory Navigation & Bookmark Manager ---
   if (Test-Path "C:\Tool\Direct\profile.ps1") {
       . "C:\Tool\Direct\profile.ps1"
   }
   ```

3. **Reload profile**:

   ```powershell
   . $PROFILE
   ```

---

## 💻 Usage

### 1. Interactive Menu

Run `direct` without arguments:

```bash
direct
```

Output:

```text
Available paths:
   1. config     -> ~/.config
   2. hypr       -> ~/.config/hypr
   3. tool       -> ~/Tool

Actions:
  [1-3] Select path | [a] Add | [u] Update | [d] Delete | [q] Quit

Choice> 
```

- **Select path**: Type the number (e.g. `2`) or name (`hypr`) and press Enter to navigate directly to that directory.
- **`a` (Add)**: Prompts for shortcut name and target path (press Enter to bookmark your current folder).
- **`u` (Update)**: Select an existing shortcut to change its destination path.
- **`d` (Delete)**: Select a shortcut to remove it (with confirmation).
- **`q` (Quit)**: Exit the menu without changing directory.

---

### 2. Direct Jump

Jump directly to any bookmarked path by name:

```bash
direct hypr
direct tool
```

---

### 3. Tab Completion

Type `direct` followed by the first letter of a shortcut and press `Tab`:

```bash
direct h<Tab>    # Autocompletes to 'direct hypr'
```

---

### 4. Non-interactive Listing & Help

```bash
direct -l        # List all shortcuts non-interactively
direct --help    # Show help and usage options
```

---

## 📁 Configuration File (`path.toml`)

All shortcuts are stored in [`path.toml`](path.toml). You can edit them via the interactive menu or directly in the file:

```toml
[paths]
hypr = '~/.config/hypr'
tool = '~/Tool'
config = '~/.config'
```

---

## 📄 License

This project is licensed under the [MIT License](license) - free for everyone to use, modify, and distribute.
