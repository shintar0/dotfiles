# dotfiles

## OS

- ubuntu
- debian

## Target

- bash

## ENV

- local
- VSCodeDevContainer（envに`DEVCONTAINER=true`を追加すること）

## Usage

- `install.sh`: インストーラ実行コマンド（PKGインストール, SL作成）
- `make_executable.sh`: （dev）shファイルを実行可能に一括変更

## Structure

```txt
dotfiles/
├ bash/              # envごとの読込設定ファイル
├ packages/          # envごとのインストールパッケージファイル
├ .bashrc            # bash設定ファイル（ハブ）
├ install.sh         # インストーラ（メイン実行ファイル）
├ make_executable.sh # shファイルを実行可能に一括変更（開発用ファイル）
└ README.md
```