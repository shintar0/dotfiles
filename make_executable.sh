#!/bin/bash

### このスクリプトはプロジェクト内の .sh ファイルのうち、
### 「実行可能になっていないものだけ」を実行可能にします。

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "[INFO] Searching for .sh files under $ROOT_DIR"

find "$ROOT_DIR" -type f -name "*.sh" | while read -r file; do
  if [ ! -x "$file" ]; then
    chmod +x "$file"
    echo "[INFO] Made executable: $file"
  else
    echo "[INFO] Already executable: $file"
  fi
done

echo "[INFO] Done."
