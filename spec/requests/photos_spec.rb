require "rails_helper"

RSpec.describe "Photos", type: :request do
  describe "GET /photos" do
    it "未ログイン時はログイン画面にリダイレクトする" do
      get photos_path

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_session_path)
    end

    it "ログイン中のユーザーの写真を新しい順で表示する" do
      user = create(:user)
      other_user = create(:user)
      older_photo = create(:photo, user: user, title: "older", created_at: 2.days.ago)
      newer_photo = create(:photo, user: user, title: "newer", created_at: 1.day.ago)
      create(:photo, user: other_user, title: "other")

      post session_path, params: {
        email: user.email,
        password: "password"
      }

      get photos_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("写真一覧")
      expect(response.body).to include(newer_photo.title)
      expect(response.body).to include(older_photo.title)
      expect(response.body).not_to include("other")
      expect(response.body.index(newer_photo.title)).to be < response.body.index(older_photo.title)
    end
  end
end
