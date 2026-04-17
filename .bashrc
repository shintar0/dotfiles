# ===== 環境変数読み込み =====
if [ -f ~/dotfiles/bash/env.sh ] ; then
    source ~/dotfiles/bash/env.sh
fi

# ===== 共通設定 =====
source ~/dotfiles/bash/common.sh

# ===== Macの場合 =====
# if [ "$DOTFILES_MAC" = "true" ]; then
  # todo: Mac用の設定
# else
  # DOTFILES_MAC=false
# fi

# ===== Host向けの設定 =====
if [ "$DOTFILES_HOST" = "true" ] ; then
    eval "$(starship init bash)"
fi

# todo: fix#13
eval "$(starship init bash)"
