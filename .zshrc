# ==============================================================================
# .zshrc - 開発者向けターミナル環境設定 (更新日：2026-03-09)
# ==============================================================================

# --- 1. シェル基本設定 ---
setopt prompt_subst      # プロンプト内での変数展開を有効化
setopt auto_cd            # ディレクトリ名のみの入力で移動を許可
setopt correct            # コマンドのスペルミスを自動修正提案

# --- 2. 補完機能 (Completion) ---
autoload -Uz compinit && compinit
# 補完候補の選択：大文字小文字を無視、部分一致、ドットファイルも対象
zstyle ':completion:*' matcher-list 'm:{a-z A-Z}={A-Z a-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*:default' menu select=2        # Tab連打で矢印選択を有効化
zstyle ':completion:*' _extensions                   # 拡張子も補完対象
zstyle ':completion:*' keep-prefix                   # 入力済みの接頭辞を維持
setopt glob_dots                                     # 隠しファイルも補完

# 補完画面の配色設定 (di=シアン, ex=赤)
# ls -G の表示色と同期させ、視認性を統一
zstyle ':completion:*' list-colors 'di=36' 'ln=35' 'so=32' 'pi=33' 'ex=31' 'bd=46;34' 'cd=43;34' 'su=41;30' 'sg=46;30' 'tw=42;30' 'ow=43;30'

# --- 3. Gitステータス表示 (VCS Info) ---
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
zstyle ':vcs_info:git:*' formats '(%b)'              # ブランチ名を (branch) 形式で取得

# --- 4. プロンプト設定 (Prompt) ---
# %~: ホームからの相対パスを表示（階層が深いRails開発に対応）
# \n: 2行構成にすることで入力スペースを確保し、視認性を向上
# yellow: ブランチ名の強調色
# cyan: ディレクトリ名の識別色
PROMPT='%F{cyan}%~%f %F{yellow}${vcs_info_msg_0_}%f
$ '

# --- 5. 安全・リスク管理 (Safety & Guard) ---
# 破壊的な操作の前に必ず確認メッセージを出すことで、不慮の事故を防ぎます
alias rm='rm -i'                                   # 削除前に確認
alias cp='cp -i'                                   # 上書きコピー前に確認
alias mv='mv -i'                                   # 上書き移動前に確認

# --- 6. エイリアス・カラー設定 (Daily Use) ---
export CLICOLOR=1
export LSCOLORS="Gxfxcxdxbxegedabagacad"             # ディレクトリをシアンに設定
alias ls='ls -G'                                     # ls に色をつける
alias ll='ls -lG'                                    # 詳細リスト表示の短縮
alias la='ls -laG'                                   # 全ファイル表示の短縮

# --- 7. 外部ツール設定 (External Tools) ---
# Homebrew: パスを通すことで brew コマンドを有効化
eval "$(/opt/homebrew/bin/brew shellenv)"

# rbenv: Rubyのバージョン管理を自動初期化
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# nodenv: Node.jsのバージョン管理を自動初期化
export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init -)"
