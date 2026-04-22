# ===== dotfiles のパス（クローン先を変えた場合はここを修正）=====
DOTFILES_DIR="${HOME}/dotfiles"

# ===== 環境変数読み込み =====
if [ -f "${DOTFILES_DIR}/zsh/env.zsh" ]; then
    source "${DOTFILES_DIR}/zsh/env.zsh"
fi

# ===== 共通設定 =====
source "${DOTFILES_DIR}/zsh/common.zsh"

# ===== Macの場合 =====
# if [ "$DOTFILES_MAC" = "true" ]; then
  # todo: Mac用の設定
# fi

# ===== Starship =====
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi
