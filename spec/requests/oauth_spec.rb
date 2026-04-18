require "rails_helper"

RSpec.describe "Oauth", type: :request do
  describe "GET /oauth/callback" do
    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with("OAUTH_CLIENT_ID").and_return("client-id")
      allow(ENV).to receive(:fetch).with("OAUTH_CLIENT_SECRET").and_return("client-secret")
      allow(ENV).to receive(:fetch).with("OAUTH_REDIRECT_URI").and_return("http://localhost:3000/oauth/callback")
      allow(ENV).to receive(:fetch).with("OAUTH_TOKEN_URL").and_return("http://example.com/oauth/token")
    end

    it "未ログイン時はログイン画面にリダイレクトすること" do
      get "/oauth/callback", params: { code: "auth-code" }

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_session_path)
    end

    it "認可コードから取得したアクセストークンがsessionに保存されること" do
      http_response = instance_double(Net::HTTPOK, body: { access_token: "access-token" }.to_json)
      allow(Net::HTTP).to receive(:start).and_return(http_response)

      user = create(:user)
      sign_in_as(user)

      get "/oauth/callback", params: { code: "auth-code" }

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(photos_path)
      expect(session[:access_token]).to eq("access-token")
    end

    it "アクセストークン取得に失敗した場合は画像一覧へ戻ること" do
      http_response = instance_double(Net::HTTPOK, body: { error: "invalid_grant", error_description: "error message" }.to_json)
      allow(Net::HTTP).to receive(:start).and_return(http_response)

      user = create(:user)
      sign_in_as(user)

      get "/oauth/callback", params: { code: "auth-code" }

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(photos_path)
      expect(session[:access_token]).to be_nil
    end

    it "HTTPリクエストに失敗した場合は画像一覧へ戻ること" do
      allow(Net::HTTP).to receive(:start).and_raise(StandardError.new("network error"))

      user = create(:user)
      sign_in_as(user)

      get "/oauth/callback", params: { code: "auth-code" }

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(photos_path)
      expect(session[:access_token]).to be_nil
    end

    it "認証サーバーに指定されたform_dataが送信されること" do
      http_response = instance_double(Net::HTTPOK, body: { access_token: "access-token" }.to_json)
      request_double = instance_double(Net::HTTP::Post)
      http_double = instance_double(Net::HTTP)

      user = create(:user)
      sign_in_as(user)

      # Net::HTTP::Post に設定される form_data を検証する。
      allow(Net::HTTP::Post).to receive(:new).and_return(request_double)
      expect(request_double).to receive(:set_form_data).with(
        code: "auth-code",
        client_id: "client-id",
        client_secret: "client-secret",
        redirect_uri: "http://localhost:3000/oauth/callback",
        grant_type: "authorization_code"
      )

      # Net::HTTP.start のブロックに渡される http オブジェクトを差し替え、
      # 生成された request が request(request_double) に渡ることを確認する。
      expect(http_double).to receive(:request).with(request_double).and_return(http_response)
      allow(Net::HTTP).to receive(:start).and_yield(http_double)

      get "/oauth/callback", params: { code: "auth-code" }

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(photos_path)
      expect(session[:access_token]).to eq("access-token")
    end
  end
end
