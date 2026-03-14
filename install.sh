#!/bin/zsh
# 解説：上記の1行は「シバン (Shebang)」と呼ばれます。
# 設計意図：単なるコメントではなく、OSに対して「このファイルを /bin/zsh で実行せよ」と明示するためのコードです。
#           これにより、実行権限を与えた後に `./install.sh` と打つだけで、正しいシェルで起動されます。

# --- エラーハンドリングの設定 ---
# 設計意図：Fail-fast（フェイルファスト）原則に基づき、エラー発生時に即座に中断し、不完全な状態での続行を防ぐ。
# 解説：set -e は「エラーが出たら即停止せよ」という命令です。
set -e

# 設計意図：異常終了時に、ユーザーが原因特定と復旧を行えるよう、視覚的なフィードバックとガイダンスを表示する。
# 解説：trap コマンドにより、スクリプト内でエラー（ERR）が起きた際、自動でこの関数が呼び出されます。
error_handler() {
    echo ""
    echo "❌ [Error] Setup failed midway."
    echo "🔍 [Check] Please check the specific error message displayed just above."
    echo "💡 [Tip] Common causes: Permission denied or missing source files in your dotfiles folder."
    exit 1
}
trap error_handler ERR

# ==============================================================================
# Script: install.sh
# Description: dotfiles（設定ファイル）をシステム上の適切な場所にシンボリックリンクとして配置し、
#              開発環境の構築・更新を自動化するためのスクリプトです。
# Usage: ./install.sh
# Notes: 既存の設定ファイルが実体として存在する場合、自動的に .bak としてバックアップを作成します。
# ==============================================================================

# --- 1. Configuration（設定とパスの解決） ---
# 設計意図：実行環境に依存せず、常にスクリプトの場所を起点とした絶対パスを動的に取得する。
# 解説：$(cd ...) は、どのディレクトリから実行しても dotfiles フォルダの場所を特定するための記述です。
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
# 設計意図：macOSにおける VS Code の標準パスを定義。将来的な拡張性を考慮し変数化。
VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
# 設計意図：macOSにおける Antigravity の標準パスを定義。将来的な拡張性を考慮し変数化。
ANTIGRAVITY_USER_DIR="$HOME/Library/Application Support/Antigravity/User"
# 設計意図：macOSにおける Karabiner-Elements の標準パスを定義。
KARABINER_DIR="$HOME/.config/karabiner"

echo "🚀 Starting environment setup..."

# --- 2. Helper Functions（共通関数の定義） ---
# 設計意図：DRY原則に基づき共通化。さらに各リンク作成時のコンテキスト（どのファイルか）をエラー時に明示する。
create_link() {
    local source_file=$1  # リンク元のファイル（実体）
    local target_file=$2  # リンクを配置する場所（宛先）

    # 設計意図：処理をブロック {} で囲み、その中のどこかで失敗したら || 以降の個別エラーメッセージを表示する。
    # 解説：|| は「左側が失敗したら右側を実行する」という意味です。
    {
        # 設計意図：既存の設定を破壊しないための安全策（Safety Guard）。
        if [ -f "$target_file" ] && [ ! -L "$target_file" ]; then
            echo "⚠️  Found existing file at $target_file. Moving to ${target_file}.bak"
            mv "$target_file" "${target_file}.bak"
        fi

        # 設計意図：-sf オプションを使用し、シンボリックリンクをアトミックに作成・更新する。
        ln -sf "$source_file" "$target_file"
    } || {
        # 解説：失敗したファイル名を具体的に表示することで、ユーザーが「どこを直すべきか」を即座に判断できます。
        echo "❌ Failed to create a link for: $target_file"
        return 1
    }
}

# --- 3. Main Tasks（主要な処理の実行） ---

# Shell Configuration
echo "🔗 Linking .zshrc..."
create_link "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

# VS Code Configurations
# 設計意図：ディレクトリ作成失敗時も、原因となるパスを明示して Fail-fast させる。
if [ ! -d "$VSCODE_USER_DIR" ]; then
    echo "📁 Creating VS Code directory..."
    # 解説：mkdir が失敗した場合、|| 以降が実行され、どのディレクトリ作成でコケたのかを表示します。
    mkdir -p "$VSCODE_USER_DIR" || { echo "❌ Failed to create directory: $VSCODE_USER_DIR"; exit 1; }
fi

echo "🔗 Linking VS Code settings..."
create_link "$DOTFILES_DIR/vscode/settings.json" "$VSCODE_USER_DIR/settings.json"

echo "🔗 Linking VS Code keybindings..."
create_link "$DOTFILES_DIR/vscode/keybindings.json" "$VSCODE_USER_DIR/keybindings.json"

# Antigravity Configurations
# 設計意図：ディレクトリ作成失敗時も、原因となるパスを明示して Fail-fast させる。
if [ ! -d "$ANTIGRAVITY_USER_DIR" ]; then
    echo "📁 Creating Antigravity directory..."
    # 解説：mkdir が失敗した場合、|| 以降が実行され、どのディレクトリ作成でコケたのかを表示します。
    mkdir -p "$ANTIGRAVITY_USER_DIR" || { echo "❌ Failed to create directory: $ANTIGRAVITY_USER_DIR"; exit 1; }
fi

# 設計意図：VS Code の設定と同じ構成にする。
echo "🔗 Linking Antigravity settings..."
create_link "$DOTFILES_DIR/vscode/settings.json" "$ANTIGRAVITY_USER_DIR/settings.json"

# 設計意図：VS Code の設定と同じ構成にする。
echo "🔗 Linking Antigravity keybindings..."
create_link "$DOTFILES_DIR/vscode/keybindings.json" "$ANTIGRAVITY_USER_DIR/keybindings.json"

# Karabiner Elements Configuration
# 設計意図：ディレクトリ作成失敗時も、原因となるパスを明示して Fail-fast させる。
if [ ! -d "$KARABINER_DIR" ]; then
    echo "📁 Creating Karabiner directory..."
    mkdir -p "$KARABINER_DIR" || { echo "❌ Failed to create directory: $KARABINER_DIR"; exit 1; }
fi

echo "🔗 Linking Karabiner settings..."
create_link "$DOTFILES_DIR/karabiner/karabiner.json" "$KARABINER_DIR/karabiner.json"

# 全ての工程が終わったことを知らせる。
echo "✅ All setup tasks completed successfully!"