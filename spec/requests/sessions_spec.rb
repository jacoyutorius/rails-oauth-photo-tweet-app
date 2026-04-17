require "rails_helper"

RSpec.describe "Sessions", type: :request do
  describe "GET /" do
    it "未ログイン時はログイン画面にリダイレクトする" do
      get root_path

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "GET /session/new" do
    it "ログイン画面を表示する" do
      get new_session_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("ログイン")
    end
  end

  describe "POST /session" do
    let!(:user) { create(:user) }

    it "正しい認証情報でログインできる" do
      post session_path, params: {
        email: user.email,
        password: "password"
      }

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(photos_path)
      expect(session[:user_id]).to eq(user.id)
    end

    it "誤った認証情報ではログインできない" do
      post session_path, params: {
        email: user.email,
        password: "wrong-password"
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(session[:user_id]).to be_nil
      expect(response.body).to include("メールアドレスまたはパスワードが正しくありません。")
    end
  end
end
