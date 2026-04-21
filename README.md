# dotfiles

## OS

- ubuntu
- macOS（予定）

## Target

- bash
- bat
- chrome
- claude
- eza
- fzf
- git
- git-delta
- ghostty
- neovim
- obsidian
- ripgrep
- starship
- udev-gothic
- vscode

## ENV

### `DOTFILES_GIT_REBASE`

> 指定なし -> false

- true: `rebase`
- false: `merge`

### `DOTFILES_MAC`

> [!NOTE]
> 現在`dotfiles`はMacには未対応

trueの場合下記の処理を追加（予定）

- [homebrew](https://brew.sh/ja/)に対応（予定）
- `.bash_profile`（予定）
    - macOS にログインしたときに表示される “zsh がデフォルトになりました” という案内メッセージを表示しない（予定）
    - macOS の bash は .bashrc を自動で読み込まないのでログインシェルでも .bashrc を読み込むようにする（予定）
- `packages/brew_mac.txt`（予定）
    - [docker-compose](https://docs.docker.com/compose/)（予定）    

### `DOTFILES_HOST`

> [!NOTE]
> 現在`dotfiles`は`DOTFILES_HOST`には未対応

下記全て予定

- `packages/apt_host.txt`
    - [ghostty](https://ghostty.org/)
        - テーマ: UDEV Gothic 35NFLG
        - フォント: Gruvbox Dark
    - [mise](https://mise.jdx.dev/)
    - [starship](https://starship.rs/ja-JP/)
        - プリセット: [Gruvbox Rainbow](https://starship.rs/ja-JP/presets/gruvbox-rainbow)
    - [VisualStudioCode](https://code.visualstudio.com/)
        - [拡張] 日本語対応
        - [拡張] テーマ
        - settings.json

## Usage

- `clean.sh`: dotfiles の再インストールを安全に行うためのクリーン処理
    - `--dry-run`: ドライランオプションをつけることで実行はされず、影響だけ確認できます。
- `install.sh`: インストーラ実行コマンド（PKGインストール, SL作成, 設定の反映）
- `make_executable.sh`: （dev）shファイルを実行可能に一括変更

> [!TIP]
> VSCodeDevcontainerではDockerfileでrepositoryをclone, `install.sh`を実行すること。dotfilesの変更を適用させる場合はキャッシュを使わずリビルドする必要がある。

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

## Docs

その他設計は[こちら](docs.md)を参照

## License

This repository uses a custom license.  
Use of the software is not recommended. See [LICENSE.md](./LICENSE.md) for details.
日本語版は [LICENSE.ja.md](./LICENSE.ja.md) を参照してください。
