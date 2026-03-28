# ===== 共通設定 =====
source ~/dotfiles/bash/common.sh

# ===== 環境ごとの設定 =====
if [ "$DOTFILES_DEVCONTAINER" = "true" ]; then
  source ~/dotfiles/bash/devcontainer.sh
else
  # secrets.sh があれば読み込む（無ければ無視）
  [ -f ~/dotfiles/bash/secrets.sh ] && source ~/dotfiles/bash/secrets.sh
fi
