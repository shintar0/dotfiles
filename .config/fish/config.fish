# ============================
# 基本設定
# ============================

# エディタ
set -gx EDITOR nvim
set -gx VISUAL nvim

# PATH の追加
if test -d $HOME/.local/bin
    fish_add_path $HOME/.local/bin
end

# ============================
# プラグイン連携
# ============================

# fzf.fish（キーバインド）
if type -q fzf_key_bindings
    fzf_key_bindings
end

# tide（プロンプト）
# 初回セットアップは対話式なので自動実行しない
if type -q tide
    # tide configure を実行したい場合はコメント解除
    # tide configure
end

# replay.fish（履歴強化）
# 特別な設定は不要だが、履歴共有を有効化すると相性が良い
set -g fish_history shared

# ============================
# 略語展開
# ============================

# ls
abbr ll "ls -alF"
abbr la "ls -A"
abbr l "ls -CF"

# git
abbr gs "git status"
abbr ga "git add"
abbr gc "git commit"
abbr gp "git push"
abbr gl "git pull"
abbr gr "git reset --soft HEAD^"
abbr gbd "git branch --merged main | grep -v "main" | xargs git branch -d"

# ============================
# 色設定（必要最低限）
# ============================

set -g fish_color_command green
set -g fish_color_param cyan
set -g fish_color_error red

# ============================
# ローカル設定
# ============================

if test -f ~/.config/fish/local.fish
    source ~/.config/fish/local.fish
end
