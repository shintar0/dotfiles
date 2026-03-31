# dotfiles

## OS

- ubuntu
- debian

## Target

- bash
- ClaudeCode
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

> 指定なし -> true

- true: `rebase`
- false: `merge`

### `DOTFILES_FISH`

> 指定なし -> false

- true: `fish`
- false: `bash`

### `DOTFILES_CLAUDE_CODE`

> 指定なし -> false

trueの場合のみClaudeCodeのインストールを実施

> [!TIP]
> 認証情報については `claude` コマンドでのログイン（[参考](https://code.claude.com/docs/ja/quickstart#%E3%82%B9%E3%83%86%E3%83%83%E3%83%97-2%EF%BC%9A%E3%82%A2%E3%82%AB%E3%82%A6%E3%83%B3%E3%83%88%E3%81%AB%E3%83%AD%E3%82%B0%E3%82%A4%E3%83%B3%E3%81%99%E3%82%8B)）を想定。詳しくは[Claude](docs.md#claude)を参照

## Usage

- `install.sh`: インストーラ実行コマンド（PKGインストール, SL作成, 設定の反映）
- `make_executable.sh`: （dev）shファイルを実行可能に一括変更
- `clean.sh`: dotfiles の再インストールを安全に行うためのクリーン処理
    - `--dry-run`: ドライランオプションをつけることで実行はされず、影響だけ確認できます。

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