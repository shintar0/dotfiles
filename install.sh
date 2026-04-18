#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# ============================
# サマリー用の記録配列
# ============================
SUMMARY_PACKAGES=()
SUMMARY_SYMLINKS=()
SUMMARY_ENV=()

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
    SUMMARY_PACKAGES+=("$pkg")
  done < "$pkg_file"
}

# ============================
# 1. パッケージインストール
# ============================
install_packages() {
  sudo apt update
  # 共通パッケージ
  install_from_file "$DOTFILES_DIR/packages/apt_common.txt"
}

# ============================
# 2. シンボリックリンク作成
# ============================
files_and_paths=(
  ".bashrc:$HOME/.bashrc"
  ".gitconfig:$HOME/.gitconfig"
  ".claude/CLAUDE.md:$HOME/.claude/CLAUDE.md"
  ".config/bat/config:$HOME/.config/bat/config"
  ".config/ghostty/config.ghostty:$HOME/.config/ghostty/config.ghostty"
  ".config/nvim/init.lua:$HOME/.config/nvim/init.lua"
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
  SUMMARY_SYMLINKS+=("$destination_path → $source_file")
}

create_symlinks() {
  for entry in "${files_and_paths[@]}"; do
    IFS=":" read -r source_file destination_path <<< "$entry"
    mkdir -p "$(dirname "$destination_path")"
    create_symlink "$source_file" "$destination_path"
  done
}

# 環境変数による条件分岐（関数）
check_environment() {
  if [ "$DOTFILES_GIT_REBASE" = "true" ]; then
    echo "[INFO] GITのPULLはリベースモードに設定されます"
    git config --global pull.rebase true
    SUMMARY_ENV+=("DOTFILES_GIT_REBASE=true  → git pull はリベースモード")
  else
    echo "[INFO] GITのPULLはマージモードに設定されます"
    git config --global pull.rebase false
    SUMMARY_ENV+=("DOTFILES_GIT_REBASE=false → git pull はマージモード")
  fi
  # tabをspace*8に変更
  sed -i 's/\t/        /g' .gitconfig

  # ClaudeCode (DOTFILES_CLAUDE_CODE)
  if [ "$DOTFILES_CLAUDE_CODE" = "true" ]; then
    echo "[INFO] ClaudeCodeのインストールを開始します"
    if curl -fsSL https://claude.ai/install.sh | bash; then
      echo "[INFO] ClaudeCodeのインストールが完了しました"
      SUMMARY_ENV+=("DOTFILES_CLAUDE_CODE=true → Claude Code インストール済み")
    else
      echo "[ERROR] ClaudeCodeのインストールに失敗しました" >&2
      SUMMARY_ENV+=("DOTFILES_CLAUDE_CODE=true → Claude Code インストール失敗")
    fi
  fi

  ## Macの場合
  # Homebrewのインストール
  # docker-compose, ghostty, miseのインストール

  ## Host向け
  if [ "$DOTFILES_HOST" = "true" ]; then
    echo "[INFO] Host向けの環境設定を行います（未対応）"
    # Ghostty
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"
    # starship
    curl -sS https://starship.rs/install.sh | sh  -s -- --yes
    starship preset gruvbox-rainbow -o ~/.config/starship.toml
    # chrome
    tmpdeb="/tmp/google-chrome.deb"
    curl -fsSL -o "$tmpdeb" https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt install -y "$tmpdeb"
    rm -f "$tmpdeb"
    # TODO: パッケージ追加インストール
  fi
}


# ============================
# サマリー表示
# ============================
print_summary() {
  echo ""
  echo "============================================"
  echo "  インストール結果サマリー"
  echo "============================================"

  echo ""
  echo "【インストールしたパッケージ】"
  if [ ${#SUMMARY_PACKAGES[@]} -eq 0 ]; then
    echo "  (なし)"
  else
    for pkg in "${SUMMARY_PACKAGES[@]}"; do
      echo "  - $pkg"
    done
  fi

  echo ""
  echo "【作成したシンボリックリンク】"
  if [ ${#SUMMARY_SYMLINKS[@]} -eq 0 ]; then
    echo "  (なし)"
  else
    for link in "${SUMMARY_SYMLINKS[@]}"; do
      echo "  - $link"
    done
  fi

  echo ""
  echo "【環境設定 (環境変数)】"
  if [ ${#SUMMARY_ENV[@]} -eq 0 ]; then
    echo "  (なし)"
  else
    for env in "${SUMMARY_ENV[@]}"; do
      echo "  - $env"
    done
  fi

  echo ""
  echo "============================================"
}

# ============================
# 実行フロー
# ============================
install_packages
create_symlinks
check_environment
print_summary
echo "[INFO] 完了しました！"
