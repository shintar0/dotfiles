#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# シンボリックリンクを作成するファイルとパスのリスト
files_and_paths=(
  ".bashrc:$HOME/.bashrc"
)

# シンボリックリンクを作成する関数
create_symlink() {
  local source_file="$DOTFILES_DIR/$1"
  local destination_path=$2

  # 退避先のファイル名
  backup_file="${destination_path}.bak"

  # バックアップファイルが存在する場合は削除
  if [ -e "$destination_path" ] && [ ! -L "$destination_path" ]; then
    # バックアップ
    mv "$destination_path" "$backup_file"
  fi

  # シンボリックリンクの作成（既存のリンクは強制上書き）
  ln -sf "$source_file" "$destination_path"
}

# ファイルとパスのリストをループしてシンボリックリンクを作成
for entry in "${files_and_paths[@]}"; do
  IFS=":" read -r source_file destination_path <<< "$entry"
  create_symlink "$source_file" "$destination_path"
done