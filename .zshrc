# ===== 環境変数読み込み =====
if [ -f ~/dotfiles/zsh/env.zsh ]; then
    source ~/dotfiles/zsh/env.zsh
fi

# ===== 共通設定 =====
source ~/dotfiles/zsh/common.zsh

# ===== Macの場合 =====
# if [ "$DOTFILES_MAC" = "true" ]; then
  # todo: Mac用の設定
# fi

# ===== Host向けの設定 =====
if [ "$DOTFILES_HOST" = "true" ] && command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi
