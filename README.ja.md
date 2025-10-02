# json-filter

`json-filter` は、主に標準入力から様々な入力に含まれる不完全なJSONデータを抽出，検証，整形し，さらには修正を試みる強力なコマンドラインツールです。ログ、APIレスポンス、またはJSONを含む可能性のあるあらゆるテキストストリームの処理に最適です。

## 特徴

- **インテリジェントなJSON抽出**: 堅牢な正規表現を使用して、より大きなテキストストリームやログに埋め込まれたJSONオブジェクトまたは配列を自動的に識別し、抽出します。
- **自動整形**: 有効なJSONは、読みやすさを向上させるために自動的に適切なインデントでフォーマットされます。
- **不完全なJSONの回復**: 不足している閉じ括弧（`}`）や角括弧（`]`）をインテリジェントに追加することで、不正な形式または切り詰められたJSONの修復を試みます。これは、部分的なJSON出力に対処する場合に特に役立ちます。
- **バイパスモード**: JSONの解析が失敗した場合でも、元の入力を標準出力に渡すことを可能にする `--bypass` フラグがあります。これにより、パイプラインの中断を防ぎます。
- **バージョン情報**: ツールのバージョン、コミットハッシュ、ビルド日時を表示する `--version` フラグをサポートしています。

## インストール

`json-filter` をインストールするには、Go (バージョン1.16以上) がインストールされていることを確認してください。

```bash
git clone https://github.com/magifd2/json-filter.git
cd json-filter
make
sudo mv bin/json-filter-cli /usr/local/bin/
```

## 使用方法

`json-filter` は標準入力から読み込み、処理されたJSONを標準出力に書き出します。

```bash
<JSONを含むコマンド出力> | json-filter [flags]
```

### フラグ

-   `--bypass`: JSONの解析が失敗した場合、エラーの代わりに元の出力を出力します。
    ```bash
    echo "Some text before {\"key\": \"value\"" | json-filter --bypass
    # 出力: Some text before {"key": "value"
    ```
-   `--version`: バージョン情報を表示して終了します。
    ```bash
    json-filter --version
    # 出力: json-filter-cli version: ..., commit: ..., built on: ...
    ```

### 例

**基本的なJSONの抽出と整形:**

```bash
echo 'INFO: User data: {"id": 123, "name": "Alice", "email": "alice@example.com"}' | json-filter
# 出力:
# {
#   "id": 123,
#   "name": "Alice",
#   "email": "alice@example.com"
# }
```

**不完全なJSONの処理:**

```bash
echo '{"data": {"item": "value"' | json-filter
# 出力:
# {
#   "data": {
#     "item": "value"
#   }
# }
```

**JSON配列の処理:**

```bash
echo '[{"id": 1, "name": "foo"}, {"id": 2, "name": "bar"}]' | json-filter
# 出力:
# [
#   {
#     "id": 1,
#     "name": "foo"
#   },
#   {
#     "id": 2,
#     "name": "bar"
#   }
# ]
```

**`curl` との併用:**

```bash
curl -s https://api.github.com/users/octocat | json-filter
# 出力: (GitHub APIからの整形されたJSONレスポンス)
```

## 開発

### ソースからのビルド

```bash
make
```

これにより、`bin/` ディレクトリに `json-filter-cli` 実行可能ファイルがビルドされます。

### テストの実行

(現在、テストは実装されていませんが、このセクションは将来の開発のためのプレースホルダーです。)

## 貢献

貢献を歓迎します！お気軽にプルリクエストを送信してください。

## ライセンス

このプロジェクトはMITライセンスの下でライセンスされています - 詳細については[LICENSE](LICENSE)ファイルを参照してください。

