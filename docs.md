# DOCS

## 設計思想

- このリポジトリは 環境構築の自動化を求めた dotfiles リポジトリ
- packageのインストールやファイルの配置、シンボリックリンクの作成まで行う
- インストールの要否が分かれるパッケージに関しては環境変数でインストールするかを指定できるようにしている
    - ubuntuの自宅サーバ上で動くdevcontainerでの開発を基本としている
    - そのため ubuntu debian を動作対象のOSとしている
- `LICENSE.md`にもあるが、ポートフォリオや他PJからの参照の都合でpublicリポジトリにしているため、クレデンシャルファイルや機密情報などは絶対にgit管理対象にしない
- 自動テストは将来的に対応予定

## Claude

Claudeは`ANTHROPIC_API_KEY`が環境変数として設定されていると優先してそれを利用する。もちろんAPIKEYが一番楽ではあるがセキュリティリスクを考慮して、そのやり方は避ける方針でこのリポジトリは設計実装する。

基本的には`claude`コマンドでの初回ログインは許容し、VSCodeDevcontainerの場合は、ホストの認証情報（`~/.config/claude/`）をマウントして利用することで利便性を向上させる仕組みとする。

### VSCodeDevcontainerでのベストプラクティス

```json
"mounts": [
  "source=${localEnv:HOME}/.config/claude,target=/root/.config/claude,type=bind,consistency=cached"
]
```

## zsh

シェルは zsh を採用している。Ubuntu ホストでは `install.sh` が自動でインストール・デフォルトシェル設定まで行う。

### VSCodeDevcontainerでのベストプラクティス

DevContainer で zsh を使うには `common-utils` feature を追加してデフォルトシェルを zsh に設定する。

```json
"features": {
  "ghcr.io/devcontainers/features/common-utils:2": {
    "installZsh": true,
    "configureZshAsDefaultShell": true,
    "installOhMyZsh": false
  }
}
```

dotfiles の `.zshrc` を適用するには、VS Code の dotfiles 機能を使う。

```json
"dotfiles.repository": "shintar0/dotfiles",
"dotfiles.installCommand": "bash install.sh"
```

ただし `install.sh` はホスト向け処理（Ghostty・Chrome・Obsidian など）も含むため、コンテナ内では `DOTFILES_HOST` を設定しないことで自動的にスキップされる。

zsh プラグイン（`zsh-autosuggestions`・`zsh-syntax-highlighting`・`zsh-abbr`）は `install.sh` 実行時に `~/.local/share/zsh/plugins/` へ clone される。
