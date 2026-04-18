# dotfiles

## OS

- debian
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
- ripgrep
- starship
- udev-gothic
- vscode

## ENV

### `DOTFILES_CLAUDE_CODE`

> 指定なし -> false

trueの場合のみClaudeCodeのインストールを実施

> [!TIP]
> 認証情報については `claude` コマンドでのログイン（[参考](https://code.claude.com/docs/ja/quickstart#%E3%82%B9%E3%83%86%E3%83%83%E3%83%97-2%EF%BC%9A%E3%82%A2%E3%82%AB%E3%82%A6%E3%83%B3%E3%83%88%E3%81%AB%E3%83%AD%E3%82%B0%E3%82%A4%E3%83%B3%E3%81%99%E3%82%8B)）を想定。詳しくは[Claude](docs.md#claude)を参照

### `DOTFILES_GIT_REBASE`

> 指定なし -> true

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
