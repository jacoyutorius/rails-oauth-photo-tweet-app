# photo-app

Rails 8.1.3 / SQLite3 を使ったアプリケーションです。

## Docker Compose での起動

### 前提

- Docker
- Docker Compose

### 起動手順

事前に OAuth 用の環境変数を設定します。
(rails credentialsを利用することも検討したが、アプリケーション起動に必要な設定値を明確にしたいので、exportで読み込む形式としています)

```bash
export OAUTH_CLIENT_ID=#{提供されたclient_id}
export OAUTH_CLIENT_SECRET=#{提供されたclient_secret}
export OAUTH_AUTHORIZE_URL=http://unifa-recruit-my-tweet-app.ap-northeast-1.elasticbeanstalk.com/oauth/authorize
export OAUTH_REDIRECT_URI=http://localhost:3000/oauth/callback
export OAUTH_SCOPE=write_tweet
```

```bash
docker compose up --build
```

ブラウザで `http://localhost:3000` を開くとアプリにアクセスできます。

### 停止

```bash
docker compose down
```

不要な orphan container も含めて整理する場合は、以下を使います。

```bash
docker compose down --remove-orphans
```

## 補足

- Rails サーバ起動時に `bin/docker-entrypoint` で `db:prepare` が実行されます
- 開発用の SQLite ファイルはコンテナ内の `/rails/storage` に作成されます
- `OAUTH_CLIENT_ID` を設定すると、写真一覧に OAuth 認可画面へのリンクが表示されます
