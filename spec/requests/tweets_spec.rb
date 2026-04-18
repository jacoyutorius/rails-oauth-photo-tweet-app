require "rails_helper"

RSpec.describe "Tweets", type: :request do
  describe "POST /photos/:photo_id/tweet" do
    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with("TWEET_API_URL").and_return("http://example.com/api/tweets")
    end

    it "未ログイン時はログイン画面にリダイレクトすること" do
      photo = create(:photo)

      post photo_tweet_path(photo)

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_session_path)
    end

    it "ステータスコードが201 のとき投稿成功として画像一覧へ戻ること" do
      user = create(:user)
      photo = create(:photo, user: user, title: "tweet title")
      http_response = instance_double(Net::HTTPCreated, code: "201")

      sign_in_as(user)
      session[:access_token] = "access-token"

      allow(Net::HTTP).to receive(:start).and_return(http_response)

      post photo_tweet_path(photo)

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(photos_path)
    end

    it "ステータスコードが201 以外のとき投稿失敗として画像一覧へ戻ること" do
      user = create(:user)
      photo = create(:photo, user: user)
      http_response = instance_double(Net::HTTPBadRequest, code: "400")

      sign_in_as(user)
      session[:access_token] = "access-token"

      allow(Net::HTTP).to receive(:start).and_return(http_response)

      post photo_tweet_path(photo)

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(photos_path)
    end

    it "指定されたフォーマットのパラメータがAPIに送信されていること" do
      user = create(:user)
      photo = create(:photo, user: user, title: "tweet title")
      http_response = instance_double(Net::HTTPCreated, code: "201")
      request_double = instance_double(Net::HTTP::Post)
      http_double = instance_double(Net::HTTP)

      sign_in_as(user)
      allow_any_instance_of(ApplicationController).to receive(:access_token).and_return("access-token")

      # Net::HTTP::Post に設定されるヘッダと body を検証する。
      allow(Net::HTTP::Post).to receive(:new).and_return(request_double)
      expect(request_double).to receive(:[]=).with("Content-Type", "application/json")
      expect(request_double).to receive(:[]=).with("Authorization", "Bearer access-token")
      expect(request_double).to receive(:body=) do |body|
        parsed_body = JSON.parse(body)
        expect(parsed_body).to eq ({
          "text" => "tweet title",
          "url" => Rails.application.routes.url_helpers.rails_blob_url(photo.image, host: "www.example.com")
        })
      end

      # Net::HTTP.start のブロックに渡される http オブジェクトを差し替え、
      # 生成された request が request(request_double) に渡ることを確認する。
      expect(http_double).to receive(:request).with(request_double).and_return(http_response)
      allow(Net::HTTP).to receive(:start).and_yield(http_double)

      post photo_tweet_path(photo)

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(photos_path)
    end
  end
end
