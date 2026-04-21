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

  # aptでインストールしない
  echo "[INFO] ClaudeCodeのインストールを開始します"
  if curl -fsSL https://claude.ai/install.sh | bash; then
    echo "[INFO] ClaudeCodeのインストールが完了しました"
    SUMMARY_PACKAGES+=("Claude Code")
  else
    echo "[ERROR] ClaudeCodeのインストールに失敗しました" >&2
  fi
}

# ============================
# 2. シンボリックリンク作成
# ============================
files_and_paths=(
  ".bashrc:$HOME/.bashrc"
  ".gitconfig:$HOME/.gitconfig"
  ".claude/CLAUDE.md:$HOME/.claude/CLAUDE.md"
  ".config/bat/config:$HOME/.config/bat/config"
  ".config/Code/User/settings.json:$HOME/.config/Code/User/settings.json"
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
  SUMMARY_ENV+=(".gitconfig → タブをスペース8個に変換")

  if [ "$DOTFILES_HOST" = "true" ]; then
    echo "[INFO] Host向けの環境設定を行います"

    # Ghostty
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"; then
      SUMMARY_ENV+=("DOTFILES_HOST=true → Ghostty インストール済み")
    else
      echo "[ERROR] Ghosttyのインストールに失敗しました" >&2
      SUMMARY_ENV+=("DOTFILES_HOST=true → Ghostty インストール失敗")
    fi

    # starship
    if curl -sS https://starship.rs/install.sh | sh -s -- --yes; then
      starship preset gruvbox-rainbow -o ~/.config/starship.toml
      SUMMARY_ENV+=("DOTFILES_HOST=true → starship インストール済み (gruvbox-rainbow)")
    else
      echo "[ERROR] starshipのインストールに失敗しました" >&2
      SUMMARY_ENV+=("DOTFILES_HOST=true → starship インストール失敗")
    fi

    # chrome
    tmpdeb="/tmp/google-chrome.deb"
    if curl -fsSL -o "$tmpdeb" https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
      && sudo apt install -y "$tmpdeb"; then
      SUMMARY_ENV+=("DOTFILES_HOST=true → Google Chrome インストール済み")
    else
      echo "[ERROR] Google Chromeのインストールに失敗しました" >&2
      SUMMARY_ENV+=("DOTFILES_HOST=true → Google Chrome インストール失敗")
    fi
    rm -f "$tmpdeb"

    # Obsidian
    tmpdeb_obsidian="/tmp/obsidian.deb"
    OBSIDIAN_VERSION=$(curl -sI "https://github.com/obsidianmd/obsidian-releases/releases/latest" | grep -i location | sed 's/.*tag\/v//' | tr -d '\r\n')
    if curl -fsSL -o "$tmpdeb_obsidian" "https://github.com/obsidianmd/obsidian-releases/releases/latest/download/obsidian_${OBSIDIAN_VERSION}_amd64.deb" \
      && sudo apt install -y "$tmpdeb_obsidian"; then
        SUMMARY_ENV+=("DOTFILES_HOST=true → Obsidian インストール済み")
    else
        echo "[ERROR] Obsidianのインストールに失敗しました" >&2
        SUMMARY_ENV+=("DOTFILES_HOST=true → Obsidian インストール失敗")
    fi
    rm -f "$tmpdeb_obsidian"
    # Obsidian vault clone
    if [ ! -d "$HOME/Documents/obsidian-vault" ]; then
        if git clone git@github.com:shintar0/obsidian-vault.git "$HOME/Documents/obsidian-vault"; then
            SUMMARY_ENV+=("DOTFILES_HOST=true → Obsidian vault clone済み")
        else
            echo "[ERROR] Obsidian vaultのcloneに失敗しました" >&2
            SUMMARY_ENV+=("DOTFILES_HOST=true → Obsidian vault clone失敗")
        fi
    else
        echo "[INFO] Obsidian vaultはすでに存在します: $HOME/Documents/obsidian-vault"
    fi

    # UDEVGothic35NFLG
    FONT_DIR="$HOME/.local/share/fonts"
    FONT_TMP="/tmp/udev-gothic"
    UDEV_GOTHIC_URL=$(curl -fsSL https://api.github.com/repos/yuru7/udev-gothic/releases/latest \
      | grep -oP '"browser_download_url":\s*"\K[^"]+UDEVGothic_NF[^"]+\.zip')

    mkdir -p "$FONT_DIR" "$FONT_TMP"

    if curl -fsSL -o "$FONT_TMP/udev-gothic.zip" "$UDEV_GOTHIC_URL" \
      && unzip -o "$FONT_TMP/udev-gothic.zip" -d "$FONT_TMP" \
      && find "$FONT_TMP" -name "*.ttf" -exec cp {} "$FONT_DIR/" \; \
      && fc-cache -fv; then
      echo "[INFO] UDEV Gothic 35NFLGのインストールが完了しました"
      SUMMARY_ENV+=("DOTFILES_HOST=true → UDEV Gothic 35NFLG インストール済み")
    else
      echo "[ERROR] UDEV Gothic 35NFLGのインストールに失敗しました" >&2
      SUMMARY_ENV+=("DOTFILES_HOST=true → UDEV Gothic 35NFLG インストール失敗")
    fi

    rm -rf "$FONT_TMP"

    # VSCode
    echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections
    tmpdeb_vscode="/tmp/vscode.deb"
    if curl -fsSL -o "$tmpdeb_vscode" "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" \
      && sudo apt install -y "$tmpdeb_vscode"; then
        SUMMARY_ENV+=("DOTFILES_HOST=true → VSCode インストール済み")

        # 拡張機能のインストール
        vscode_ext_file="$DOTFILES_DIR/vscode/extensions.txt"
        if [[ -f "$vscode_ext_file" ]]; then
          echo "VSCode 拡張機能をインストール中..."
          ext_ok=0
          ext_fail=0
          while IFS= read -r ext || [[ -n "$ext" ]]; do
            [[ -z "$ext" || "$ext" == \#* ]] && continue
            if code --install-extension "$ext" --force; then
              echo "  ✓ $ext"
              (( ext_ok++ ))
            else
              echo "  [WARN] 拡張機能のインストール失敗: $ext" >&2
              (( ext_fail++ ))
            fi
          done < "$vscode_ext_file"
          if (( ext_fail == 0 )); then
            SUMMARY_ENV+=("DOTFILES_HOST=true → VSCode Extensions: ${ext_ok}件 インストール済み")
          else
            SUMMARY_ENV+=("DOTFILES_HOST=true → VSCode Extensions: ${ext_ok}件 成功 / ${ext_fail}件 失敗")
          fi
        else
          echo "[WARN] 拡張機能リストが見つかりません: $vscode_ext_file" >&2
        fi
    else
      echo "[ERROR] VSCodeのインストールに失敗しました" >&2
      SUMMARY_ENV+=("DOTFILES_HOST=true → VSCode インストール失敗")
    fi
    rm -f "$tmpdeb_vscode"
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
