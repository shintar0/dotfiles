#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
DRY_RUN=false

# ============================
# 引数処理
# ============================
for arg in "$@"; do
  case "$arg" in
    --dry-run)
      DRY_RUN=true
      echo "[INFO] Dry-run mode enabled (no changes will be made)"
      ;;
  esac
done

files_and_paths=(
  ".zshrc:$HOME/.zshrc"
  ".gitconfig:$HOME/.gitconfig"
  ".claude/CLAUDE.md:$HOME/.claude/CLAUDE.md"
  ".config/bat/config:$HOME/.config/bat/config"
  ".config/Code/User/settings.json:$HOME/.config/Code/User/settings.json"
  ".config/ghostty/config.ghostty:$HOME/.config/ghostty/config.ghostty"
  ".config/nvim/init.lua:$HOME/.config/nvim/init.lua"
)

# ============================
# パッケージ確認
# ============================
check_packages() {
  echo "=== Checking installed packages ==="

  for pkg_file in "$DOTFILES_DIR"/packages/*.txt; do
    echo "[FILE] $pkg_file"
    while IFS= read -r pkg; do
      [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue

      echo -n "Checking $pkg ... "

      if dpkg -s "$pkg" >/dev/null 2>&1; then
        echo "installed (apt)"
        continue
      fi

      if command -v snap >/dev/null 2>&1 && snap list "$pkg" >/dev/null 2>&1; then
        echo "installed (snap)"
        continue
      fi

      if command -v flatpak >/dev/null 2>&1 && flatpak list | grep -q "$pkg"; then
        echo "installed (flatpak)"
        continue
      fi

      echo "not installed"
    done < "$pkg_file"
  done
}

# ============================
# シンボリックリンク削除
# ============================
remove_symlinks() {
  echo "=== Removing symlinks ==="

  for entry in "${files_and_paths[@]}"; do
    IFS=":" read -r source_file destination_path <<< "$entry"

    if [ -L "$destination_path" ]; then
      echo "Removing symlink: $destination_path"

      if [ "$DRY_RUN" = false ]; then
        rm "$destination_path"
      fi
    else
      echo "Skipping (not a symlink): $destination_path"
    fi
  done
}

# ============================
# バックアップ削除
# ============================
remove_backups() {
  echo "=== Removing backup files (*.bak) ==="

  find "$HOME" -maxdepth 1 -name "*.bak" | while read -r file; do
    echo "Deleting backup: $file"

    if [ "$DRY_RUN" = false ]; then
      rm "$file"
    fi
  done
}

# ============================
# 実行フロー
# ============================
check_packages
remove_symlinks
remove_backups

echo "[INFO] Clean completed (dry-run: $DRY_RUN)"
