# photo-app

Rails 8.1.3 / SQLite3 を使ったアプリケーションです。

## Docker Compose での起動

### 前提

- Docker
- Docker Compose

### 起動手順

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
