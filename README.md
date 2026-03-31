# dotfiles

## OS

- ubuntu
- debian

## Target

- bash
- fish
- git

## ENV

### `DOTFILES_DEVCONTAINER`

- PackageInstall
    - true: `apt_common.txt`+`apt_local.txt`
    - false: `apt_common.txt`+`apt_devcontainer.txt`
- Bashのスクリプト
    - true: `common.sh` + `local.sh` + `secrets.sh`
    - false: `common.sh` + `devcontainer.sh`

### `DOTFILES_GIT_REBASE`

> 指定なし -> false

- true: `rebase`
- false: `merge`（gitのデフォルト）

### `DOTFILES_FISH`

> 指定なし -> false

- true: `fish`
- false: `bash`

## Usage

- `install.sh`: インストーラ実行コマンド（PKGインストール, SL作成, 設定の反映）
- `make_executable.sh`: （dev）shファイルを実行可能に一括変更

> [!TIP]
> VSCodeDevcontainerではDockerfileでrepositoryをclone, `install.sh`を実行すること。dotfilesの変更を適用させる場合はキャッシュを使わずリビルドする必要がある。

## Structure

```txt
dotfiles/
├ .config/
│ └ fish/            # fishの設定フォルダ 
├ bash/              # envごとの読込設定ファイル
├ packages/          # envごとのインストールパッケージファイル
├ .bashrc            # bash設定ファイル（ハブ）
├ .gitconfig         # git設定ファイル
├ install.sh         # インストーラ（メイン実行ファイル）
├ make_executable.sh # shファイルを実行可能に一括変更（開発用ファイル）
└ README.md
```

## Docs

その他設計は[こちら](docs.md)を参照

## License

This repository uses a custom license.  
Use of the software is not recommended. See [LICENSE.md](./LICENSE.md) for details.
日本語版は [LICENSE.ja.md](./LICENSE.ja.md) を参照してください。