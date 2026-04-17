# Rails課題 作業手順書

## 目的
写真管理アプリケーション（OAuth連携付き）を、要件を満たしつつ実装するための作業順序。

## 実装ステップ
1. 着手前確認（課題文・OAuth情報・外部アプリ疎通）
2. Railsアプリ作成（rails new / Git初期化）
3. DB設計（users, photos）
4. 認証基盤（login/logout/session/current_user）
5. 写真一覧（自分の写真のみ、新しい順）
6. 写真アップロード（title/image、バリデーション）
7. OAuth認可画面への遷移
8. OAuth callbackでtoken取得
9. ツイート投稿API連携
10. テスト
11. README整備
12. 提出前チェック

## モデル案
### users
- email
- password_digest

### photos
- title
- user_id
- image

## 重要要件
- メールアドレスは大文字小文字を無視
- 未ログイン時は保護ページへ入れない
- titleは30文字以内
- tokenはsession保存
- ツイート成功はHTTP 201

## 推奨コミット単位
- 初期作成
- モデル追加
- ログイン
- 一覧
- アップロード
- OAuth導線
- token取得
- 投稿機能
- README / テスト

## README記載事項
- セットアップ手順
- DB作成 / migrate / seed
- 起動方法
- 環境変数
- テスト方法
- かかった時間
