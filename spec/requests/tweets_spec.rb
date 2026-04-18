require "rails_helper"

RSpec.describe "Tweets", type: :request do
  describe "POST /photos/:photo_id/tweet" do
    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with("TWEET_API_URL").and_return("http://example.com/api/tweets")
    end

    it "未ログイン時はログイン画面にリダイレクトする" do
      photo = create(:photo)

      post photo_tweet_path(photo)

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_session_path)
    end

    it "201 のとき投稿成功として一覧へ戻る" do
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

    it "201 以外のとき投稿失敗として一覧へ戻る" do
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
  end
end
