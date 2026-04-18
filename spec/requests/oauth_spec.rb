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

    it "未ログイン時はログイン画面にリダイレクトする" do
      get "/oauth/callback", params: { code: "auth-code" }

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_session_path)
    end

    it "認可コードからアクセストークンを取得してsessionに保存する" do
      http_response = instance_double(Net::HTTPOK, body: { access_token: "access-token" }.to_json)
      allow(Net::HTTP).to receive(:start).and_return(http_response)

      user = create(:user)
      sign_in_as(user)

      get "/oauth/callback", params: { code: "auth-code" }

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(photos_path)
      expect(session[:access_token]).to eq("access-token")
    end

    it "アクセストークン取得に失敗した場合は一覧へ戻る" do
      http_response = instance_double(Net::HTTPOK, body: { error: "invalid_grant", error_description: "error message" }.to_json)
      allow(Net::HTTP).to receive(:start).and_return(http_response)

      user = create(:user)
      sign_in_as(user)

      get "/oauth/callback", params: { code: "auth-code" }

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(photos_path)
      expect(session[:access_token]).to be_nil
    end

    it "レスポンスがJSONでない場合は一覧へ戻る" do
      http_response = instance_double(Net::HTTPOK, body: "invalid response")
      allow(Net::HTTP).to receive(:start).and_return(http_response)

      user = create(:user)
      sign_in_as(user)

      get "/oauth/callback", params: { code: "auth-code" }

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(photos_path)
      expect(session[:access_token]).to be_nil
    end
  end
end
