require "rails_helper"

RSpec.describe "Photos", type: :request do
  let(:image_file) do
    Rack::Test::UploadedFile.new(
      Rails.root.join("spec/fixtures/files/test-image.svg"),
      "image/svg+xml"
    )
  end

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
      expect(response.body).to include("ログアウト")
      expect(response.body).to include(newer_photo.title)
      expect(response.body).to include(older_photo.title)
      expect(response.body).not_to include("other")
      expect(response.body.index(newer_photo.title)).to be < response.body.index(older_photo.title)
    end
  end

  describe "GET /photos/new" do
    it "未ログイン時はログイン画面を表示する" do
      get new_photo_path
      follow_redirect!

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("ログイン")
    end

    it "ログイン中はアップロード画面を表示する" do
      user = create(:user)

      post session_path, params: {
        email: user.email,
        password: "password"
      }

      get new_photo_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("写真アップロード")
      expect(response.body).to include("写真一覧画面に戻る")
      expect(response.body).to include("ログアウト")
    end
  end

  describe "POST /photos" do
    it "有効な入力で写真を登録できる" do
      user = create(:user)

      post session_path, params: {
        email: user.email,
        password: "password"
      }

      expect do
        post photos_path, params: {
          photo: {
            title: "sample photo",
            image: image_file
          }
        }
      end.to change(user.photos, :count).by(1)

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(photos_path)
      expect(Photo.last.image).to be_attached

      follow_redirect!
      expect(response.body).to include("sample photo")
    end

    it "無効な入力では写真を登録できない" do
      user = create(:user)

      post session_path, params: {
        email: user.email,
        password: "password"
      }

      expect do
        post photos_path, params: {
          photo: {
            title: "",
            image: nil
          }
        }
      end.not_to change(Photo, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("写真アップロード")
      expect(response.body).to include("タイトルを入力してください")
      expect(response.body).to include("画像ファイルを入力してください")
    end

    it "タイトルが31文字以上だと登録できない" do
      user = create(:user)

      post session_path, params: {
        email: user.email,
        password: "password"
      }

      expect do
        post photos_path, params: {
          photo: {
            title: "a" * 31,
            image: image_file
          }
        }
      end.not_to change(Photo, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("タイトルは30文字以内で入力してください")
    end
  end
end
