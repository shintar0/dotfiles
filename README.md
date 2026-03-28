# dotfiles

## OS

- ubuntu
- debian

## Target

- bash
- git

## ENV

| 環境変数 | 影響箇所 |
| --- | --- |
| DOTFILES_DEVCONTAINER | PackageInstall, Bash |
| DOTFILES_GIT_REBASE | true -> rebase, 指定なし -> merge |

## Usage

- `install.sh`: インストーラ実行コマンド（PKGインストール, SL作成, 設定の反映）
- `make_executable.sh`: （dev）shファイルを実行可能に一括変更

## Structure

```txt
dotfiles/
├ bash/              # envごとの読込設定ファイル
├ packages/          # envごとのインストールパッケージファイル
├ .bashrc            # bash設定ファイル（ハブ）
├ .gitconfig         # git設定ファイル
├ install.sh         # インストーラ（メイン実行ファイル）
├ make_executable.sh # shファイルを実行可能に一括変更（開発用ファイル）
└ README.md
```