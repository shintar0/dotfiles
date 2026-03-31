#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# ============================
# 共通：パッケージファイルを読み込んでインストール
# ============================
install_from_file() {
  local pkg_file="$1"

  # 空ファイルならスキップ
  if [ ! -s "$pkg_file" ]; then
    echo "[INFO] No packages to install in $pkg_file"
    return
  fi

  echo "[INFO] Installing packages from $pkg_file"

  # 1行ずつインストール
  while IFS= read -r pkg; do
    # 空行やコメントはスキップ
    [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
    sudo apt install -y "$pkg"
  done < "$pkg_file"
}

# ============================
# 1. パッケージインストール
# ============================
install_packages() {
  sudo apt update
  # 共通パッケージ
  install_from_file "$DOTFILES_DIR/packages/apt_common.txt"

  # devcontainer or local
  if [ "$DOTFILES_DEVCONTAINER" = "true" ]; then
    install_from_file "$DOTFILES_DIR/packages/apt_devcontainer.txt"
  else
    install_from_file "$DOTFILES_DIR/packages/apt_local.txt"
  fi
}

# ============================
# 2. シンボリックリンク作成
# ============================
files_and_paths=(
  ".bashrc:$HOME/.bashrc"
  ".gitconfig:$HOME/.gitconfig"
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

# 環境変数による条件分岐（関数）
check_environment() {
  if [ "$DOTFILES_GIT_REBASE" = "true" ]; then
    echo "[INFO] GITのPULLはリベースモードに設定されます"
    git config --global pull.rebase true
  fi

  # fish（DOTFILES_FISH）
  if [ "$DOTFILES_FISH" = "true" ]; then
    # install packages
    install_from_file "$DOTFILES_DIR/packages/apt_fish.txt"
    # fisherのinstall
    fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"
    # シンボリックリンクの追加
    files_and_path_fish=(
      ".config/fish/config.fish:$HOME/.config/fish/config.fish"
      ".config/fish/fish_plugins:$HOME/.config/fish/fish_plugins"
    )
    for entry in "${files_and_path_fish[@]}"; do
      IFS=":" read -r source_file destination_path <<< "$entry"
      create_symlink "$source_file" "$destination_path"
    done
    # fisher のプラグインインストール（fish 内で実行）
    fish -c "fisher update"
    # デフォルトシェルをfishに変更
    chsh -s /usr/bin/fish
  fi

  # ClaudeCode (DOTFILES_CLAUDE_CODE)
  if [ "$DOTFILES_CLAUDE_CODE" = "true" ]; then
    echo "[INFO] ClaudeCodeのインストールを開始します"
    curl -fsSL https://claude.ai/install.sh | bash
    echo "[INFO] ClaudeCodeのインストールが完了しました"
  fi
}


# ============================
# 実行フロー
# ============================
install_packages
create_symlinks
check_environment
echo "[INFO] 完了しました！"
