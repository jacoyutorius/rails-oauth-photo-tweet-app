# Repository Guidelines

## プロジェクト構成
- `app/` に Rails 本体のコードを置きます。`app/controllers` はコントローラ、`app/models` はモデル、`app/views` は ERB テンプレートです。
- `spec/` は RSpec 用です。`spec/models` はモデル spec、`spec/requests` は request spec、`spec/factories` は FactoryBot、`spec/fixtures/files` はアップロード用 fixture を置きます。
- `db/migrate` は migration、`db/schema.rb` は現在のスキーマです。
- `config/` には routes、環境設定、storage 設定があります。要件確認は `docs/rails_photo_app_作業手順書.md` を参照します。
- ローカル開発は `docker-compose.yml` と `Dockerfile` を使います。Active Storage の保存先は development では `storage/`、test では `tmp/storage/` です。

## ビルド・テスト・開発コマンド
- `docker compose up --build` : 開発環境を起動し、`http://localhost:3000` でアプリを開きます。
- `docker compose down` : コンテナを停止します。不要なコンテナも消す場合は `docker compose down --remove-orphans` を使います。
- `docker compose run --rm rails bin/rails db:migrate` : migration を適用します。
- `docker compose run --rm rails bundle exec rspec` : RSpec を全件実行します。
- `docker compose run --rm rails bundle exec rspec spec/requests/photos_spec.rb` : 特定の spec だけ実行します。
- `docker compose run --rm rails bin/rubocop` と `docker compose run --rm rails bin/brakeman` : スタイル確認とセキュリティ確認に使います。

## コーディング規約
- Rails の標準規約に従います。クラス名は CamelCase、ファイル名は snake_case、コントローラは複数形、モデルは単数形です。
- Ruby と ERB のインデントは 2 スペースです。
- コントローラは薄く保ち、バリデーションやルールは可能な限りモデルに置きます。
- パス生成は Rails の path helper を使い、パラメータは strong params で受けます。

## テスト方針
- テストは RSpec と FactoryBot を使います。挙動を変えたら対応する spec も更新します。
- spec 名は対象に合わせます。例: `spec/models/photo_spec.rb`、`spec/requests/sessions_spec.rb`。
- 画像アップロードのテストは `spec/fixtures/files` の fixture を使います。
- PR 前には最低でも変更箇所の spec を実行し、影響範囲が広い場合は全件実行します。
- テストケースは日本語で記述します。

## コミットと PR
- コミットメッセージは既存履歴に合わせて、短い日本語で具体的に書きます。例: `写真一覧ページを追加`、`不要な機能を削除した`。
- 1コミット 1目的を基本にし、機能追加・整理・テスト修正を混ぜすぎないようにします。
- PR には変更内容、確認コマンド、schema や route の変更有無を含めます。
- 画面変更が大きい場合だけスクリーンショットを付けます。

## セキュリティと設定
- 秘密情報はコミットしません。Rails credentials か環境変数で管理します。
- `config/environments/test.rb` と `spec/rails_helper.rb` は request spec の動作に影響するため、変更時は必ず関連 spec を回します。
