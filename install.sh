#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# ============================
# 1. パッケージインストール
# ============================
install_packages() {
  if [ "$DEVCONTAINER" = "true" ]; then
    pkg_file="$DOTFILES_DIR/packages/apt_devcontainer.txt"
  else
    pkg_file="$DOTFILES_DIR/packages/apt_local.txt"
  fi

  echo "[INFO] Installing packages from $pkg_file"

  # 空ファイルならスキップ
  if [ ! -s "$pkg_file" ]; then
    echo "[INFO] No packages to install"
    return
  fi

  sudo apt update

  # 1行ずつインストール
  while IFS= read -r pkg; do
    # 空行やコメントはスキップ
    [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
    sudo apt install -y "$pkg"
  done < "$pkg_file"
}

# ============================
# 2. シンボリックリンク作成
# ============================
files_and_paths=(
  ".bashrc:$HOME/.bashrc"
)

create_symlink() {
  local source_file="$DOTFILES_DIR/$1"
  local destination_path=$2

  backup_file="${destination_path}.bak"

  if [ -e "$destination_path" ] && [ ! -L "$destination_path" ]; then
    echo "[INFO] バックアップ作成: $backup_file"
    mv "$destination_path" "$backup_file"
  fi

  echo "[INFO] シンボリックリンク作成: $destination_path → $source_file"
  ln -sf "$source_file" "$destination_path"
}

create_symlinks() {
  for entry in "${files_and_paths[@]}"; do
    IFS=":" read -r source_file destination_path <<< "$entry"
    create_symlink "$source_file" "$destination_path"
  done
}

# ============================
# 実行フロー
# ============================
install_packages
create_symlinks

echo "[INFO] 完了しました！"
