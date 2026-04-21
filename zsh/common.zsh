#####
# zsh history settings
export HISTFILE="${HOME}/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=50000
setopt HIST_IGNORE_DUPS     # 連続重複を記録しない
setopt HIST_IGNORE_SPACE    # スペース始まりは記録しない
setopt SHARE_HISTORY        # 複数ターミナル間で履歴を共有
setopt APPEND_HISTORY       # 追記モード
setopt EXTENDED_HISTORY     # タイムスタンプ付きで記録

export PATH="${HOME}/.local/bin:${PATH}"

#####
# 補完システム
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
#####
# eza
# ANSIカラーのみを使ったLS_COLORS（ターミナルテーマに完全追従）
export LS_COLORS="\
di=1;34:\
ln=36:\
so=35:\
pi=33:\
ex=32:\
bd=1;33:\
cd=1;33:\
su=31:\
sg=31:\
tw=1;34:\
ow=1;34:"
export EZA_COLORS="\
di=1;34:\
ln=36:\
so=35:\
pi=33:\
ex=32:\
bd=1;33:\
cd=1;33:\
su=31:\
sg=31:\
tw=1;34:\
ow=1;34:"

#####
# fzf
# macOS (Homebrew)
[ -f /usr/local/opt/fzf/shell/completion.zsh ]    && source /usr/local/opt/fzf/shell/completion.zsh
[ -f /usr/local/opt/fzf/shell/key-bindings.zsh ]  && source /usr/local/opt/fzf/shell/key-bindings.zsh
# Ubuntu (apt)
[ -f /usr/share/doc/fzf/examples/completion.zsh ]   && source /usr/share/doc/fzf/examples/completion.zsh
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh

#####
# プラグイン
_ZSH_PLUGIN_DIR="${HOME}/.local/share/zsh/plugins"

[ -f "${_ZSH_PLUGIN_DIR}/zsh-autosuggestions/zsh-autosuggestions.zsh" ] \
    && source "${_ZSH_PLUGIN_DIR}/zsh-autosuggestions/zsh-autosuggestions.zsh"

# zsh-abbr: abbreviation ファイルを dotfiles で管理
ABBR_USER_ABBREVIATIONS_FILE="${DOTFILES_DIR}/zsh/abbreviations"
[ -f "${_ZSH_PLUGIN_DIR}/zsh-abbr/zsh-abbr.zsh" ] \
    && source "${_ZSH_PLUGIN_DIR}/zsh-abbr/zsh-abbr.zsh"

# cat: batcat (Ubuntu) / bat (その他) を abbr で設定
if command -v batcat >/dev/null 2>&1; then
    abbr --quiet --force cat="batcat"
elif command -v bat >/dev/null 2>&1; then
    abbr --quiet --force cat="bat"
fi


# zsh-syntax-highlighting は必ず最後にsource
[ -f "${_ZSH_PLUGIN_DIR}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] \
    && source "${_ZSH_PLUGIN_DIR}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
