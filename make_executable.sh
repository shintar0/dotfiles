#!/bin/bash

### このスクリプトはプロジェクトのすべてのshファイルを実行可能にするためのものです。
### 新しい機能やスクリプトを追加した際に一括で実行可能にする際に利用することを想定しています。

# プロジェクトのルート（このスクリプトが置かれている場所）
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "[INFO] Searching for .sh files under $ROOT_DIR"

# find で .sh ファイルをすべて探して chmod +x
find "$ROOT_DIR" -type f -name "*.sh" | while read -r file; do
  chmod +x "$file"
  echo "[INFO] Made executable: $file"
done

echo "[INFO] All .sh files are now executable."
