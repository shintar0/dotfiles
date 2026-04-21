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
  while IFS= read -r pkg || [[ -n "$pkg" ]]; do
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
# 1-2. GitHub CLI (gh) のインストール
# ============================
install_gh() {
  if command -v gh &>/dev/null; then
    echo "[INFO] gh はすでにインストールされています"
    SUMMARY_PACKAGES+=("gh (既存)")
    return
  fi

  echo "[INFO] GitHub CLI (gh) のインストールを開始します"
  sudo mkdir -p -m 755 /etc/apt/keyrings
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt update
  if sudo apt install -y gh; then
    echo "[INFO] GitHub CLI (gh) のインストールが完了しました"
    SUMMARY_PACKAGES+=("gh")
  else
    echo "[ERROR] GitHub CLI (gh) のインストールに失敗しました" >&2
  fi
}

# ============================
# 2. zshプラグインのインストール
# ============================
install_zsh_plugins() {
  local plugin_dir="${HOME}/.local/share/zsh/plugins"
  mkdir -p "$plugin_dir"

  local plugins=(
    "https://github.com/zsh-users/zsh-autosuggestions"
    "https://github.com/zsh-users/zsh-syntax-highlighting"
    "https://github.com/olets/zsh-abbr"
  )

  for repo in "${plugins[@]}"; do
    local name="${repo##*/}"
    if [ -d "${plugin_dir}/${name}" ]; then
      echo "[INFO] プラグイン更新: ${name}"
      git -C "${plugin_dir}/${name}" pull --ff-only 2>/dev/null || true
    else
      echo "[INFO] プラグインインストール: ${name}"
      if git clone --depth=1 "$repo" "${plugin_dir}/${name}"; then
        SUMMARY_PACKAGES+=("zsh plugin: ${name}")
      else
        echo "[ERROR] プラグインのインストールに失敗しました: ${name}" >&2
      fi
    fi
  done

  # zsh-abbr のサブモジュール（zsh-job-queue）を初期化
  if [ -f "${plugin_dir}/zsh-abbr/.gitmodules" ]; then
    echo "[INFO] zsh-abbr サブモジュールを初期化します"
    git -C "${plugin_dir}/zsh-abbr" submodule update --init
  fi
}

# ============================
# 3. シンボリックリンク作成
# ============================
files_and_paths=(
  ".zshrc:$HOME/.zshrc"
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

# ============================
# 4. デフォルトシェルをzshに設定
# ============================
set_default_shell() {
  local zsh_path
  zsh_path="$(command -v zsh 2>/dev/null)"

  if [ -z "$zsh_path" ]; then
    echo "[WARN] zshが見つかりません。デフォルトシェルの変更をスキップします"
    return
  fi

  if [ "$SHELL" = "$zsh_path" ]; then
    echo "[INFO] すでにzshがデフォルトシェルです"
    SUMMARY_ENV+=("デフォルトシェル → zsh (変更なし)")
    return
  fi

  if sudo chsh -s "$zsh_path" "$USER" 2>/dev/null; then
    echo "[INFO] デフォルトシェルをzshに変更しました: ${zsh_path}"
    SUMMARY_ENV+=("デフォルトシェル → zsh (${zsh_path})")
  else
    echo "[WARN] デフォルトシェルの変更に失敗しました（コンテナ環境では正常です）"
  fi
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

    # Docker Desktop
    # 1. Docker apt リポジトリのセットアップ
    sudo apt install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
    sudo apt update

    # 2. KVM 仮想化サポート（Docker Desktop の動作に必須）
    sudo modprobe kvm
    sudo usermod -aG kvm "$USER"
    SUMMARY_ENV+=("DOTFILES_HOST=true → KVM: $USER を kvm グループに追加 (再ログイン後に有効)")

    # 3. Docker Desktop .deb のダウンロード＆インストール
    tmpdeb_docker="/tmp/docker-desktop-amd64.deb"
    if curl -fsSL -o "$tmpdeb_docker" "https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb" \
      && sudo apt install -y "$tmpdeb_docker"; then
      # 4. ログイン時に自動起動
      systemctl --user enable docker-desktop 2>/dev/null || true
      SUMMARY_ENV+=("DOTFILES_HOST=true → Docker Desktop インストール済み (再ログイン後に利用可能)")
    else
      echo "[ERROR] Docker Desktopのインストールに失敗しました" >&2
      SUMMARY_ENV+=("DOTFILES_HOST=true → Docker Desktop インストール失敗")
    fi
    rm -f "$tmpdeb_docker"
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
  echo "【インストール後に必要な作業】"
  echo "  1. GitHub CLI 認証:"
  echo "       gh auth login"
  echo "     ※ ブラウザまたはトークンで認証してください"
  echo ""
  echo "============================================"
}

# ============================
# 実行フロー
# ============================
install_packages
install_gh
install_zsh_plugins
create_symlinks
check_environment
set_default_shell
print_summary
echo "[INFO] 完了しました！"
