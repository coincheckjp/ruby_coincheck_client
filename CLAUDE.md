# CLAUDE.md

`ruby_coincheck_client` gemを扱うAIアシスタント向けガイド。

## プロジェクト概要

[Coincheck](https://coincheck.com/) 暗号資産取引所APIのRubyクライアントライブラリ。RubyGem (`ruby_coincheck_client`) として公開。現在のバージョン: **0.3.0**。

CoincheckのREST APIをRubyメソッドでラップし、取引・口座管理・マーケットデータ取得を提供する。ランタイム依存はゼロで、Ruby標準ライブラリ (`net/http`, `uri`, `openssl`, `json`) のみ使用。

## リポジトリ構成

```
lib/
  ruby_coincheck_client.rb              # モジュール定義、require
  ruby_coincheck_client/
    coincheck_client.rb                 # メインのCoincheckClientクラス（全APIメソッド）
    version.rb                          # VERSION定数
spec/
  spec_helper.rb                        # RSpec + WebMockセットアップ
  ruby_coincheck_client_spec.rb         # モジュールレベルのテスト
  ruby_coincheck_client/
    coincheck_client_spec.rb            # クライアント結合テスト（WebMockスタブ使用）
examples/
  public.rb                             # パブリックAPI使用例
  private.rb                            # 認証付きAPI使用例
bin/
  console                               # gemをロードしたIRBコンソール
  setup                                 # bundle installを実行
```

## ビルド・テストコマンド

```bash
# 依存関係のインストール
bundle install

# テスト実行（デフォルトRakeタスク）
bundle exec rake

# テストを直接実行
bundle exec rspec

# gemをロードした対話コンソール
bin/console

# リリース（先にversion.rbを更新すること）
bundle exec rake release
```

## テスト構成

- **フレームワーク**: RSpec（`.rspec`で `--format documentation --color` を設定）
- **HTTPモック**: WebMock — テスト内の全HTTPリクエストをスタブ化
- **環境変数**: Dotenvで`.env`ファイルを読み込み（サンプル用APIキー）
- **CI**: CircleCI v2（`.circle.yml`）、`circleci/ruby:2.4.1-node-browsers`イメージ使用

テストは`spec/`配下に格納。既存テストはパブリックAPIメソッド（`read_trades`、`read_order_books`、`read_rate`）と認証付きメソッド1件（`read_balance`）をカバー。HTTPステータスコードとJSONレスポンスのパースを検証する。

## アーキテクチャ

### 単一クラス設計

全機能は`CoincheckClient`クラスに集約（トップレベルに定義、モジュール配下ではない）。`RubyCoincheckClient`モジュールは`VERSION`定数のみ保持。

### コンストラクタ

```ruby
CoincheckClient.new(key, secret, params = {})
```

- `key`/`secret`: API認証情報（パブリックエンドポイントではnil）
- `params[:base_url]`: ベースURLの上書き（デフォルト: `https://coincheck.com/`）
- `params[:ssl]`: SSLの切り替え（デフォルト: `true`）

### メソッド命名規則

| プレフィックス | HTTPメソッド | 用途             |
|----------------|-------------|------------------|
| `read_`        | GET         | データ取得       |
| `create_`      | POST        | リソース作成     |
| `delete_`      | DELETE      | リソース削除     |
| `cancel_`      | DELETE      | 注文キャンセル   |

### パブリックAPI vs プライベートAPIメソッド

- **パブリックメソッド**（認証不要）: `read_ticker`, `read_all_trades`, `read_rate`, `read_order_books`, `read_orders_rate`
- **プライベートメソッド**（key/secret必須）: その他全て — 残高、注文、送金、銀行口座、出金

### 認証

プライベートエンドポイントは3つのヘッダーによるHMAC-SHA256署名を使用:
- `ACCESS-KEY` — APIキー
- `ACCESS-NONCE` — マイクロ秒タイムスタンプ
- `ACCESS-SIGNATURE` — `nonce + uri + body` のHMAC-SHA256

`get_signature`プライベートメソッドがこれを処理する。

### HTTP層

プライベートヘルパーメソッド（`request_for_get`、`request_for_post`、`request_for_delete`）がHTTP通信を担当。全レスポンスはJSONからRubyハッシュにパースされる。`custom_header`メソッドが`Content-Type: application/json`と`User-Agent`ヘッダーを付与。

## コード規約

- **インデント**: スペース2つ
- **命名**: メソッド・変数は`snake_case`
- **文字列**: シングルクォート優先、式展開時はダブルクォート
- **ハッシュキー**: メソッド内はシンボル、JSONパース結果は文字列キー
- **デフォルトペア**: 多くのメソッドで `pair: "btc_jpy"` がデフォルト
- **戻り値**: 全APIメソッドはパース済みJSON（Ruby Hash/Array）を返す
- **クラス変数**: `@@base_url`と`@@ssl`（インスタンス間で共有）
- **リンター未設定** — RuboCop等のツールなし

## 依存関係

### ランタイム

なし — Ruby標準ライブラリのみ。

### 開発用

- `bundler` (~> 1.9)
- `rake` (~> 10.0)
- `rspec`
- `dotenv`
- `webmock`

## 注意事項

- `.env`はgitignore対象 — APIキーは絶対にコミットしないこと
- `lib/ruby_coincheck_client.rb`が`.gitignore`に含まれている（ローカルで生成/上書きされる）
- HTTP層でSSL検証が無効化されている（`VERIFY_NONE`）
- `create_orders`メソッドが未定義の`position_id`変数を参照している（`coincheck_client.rb` 66行目）— 既知のバグ
- テストが現在のクライアントに存在しないメソッドを呼び出している（例: `read_trades` vs `read_all_trades`）、またrawレスポンスオブジェクトに対してアサートしている — テストスイートの更新が必要な可能性あり
