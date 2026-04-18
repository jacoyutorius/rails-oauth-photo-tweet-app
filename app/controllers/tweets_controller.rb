require "net/http"
require "json"

class TweetsController < ApplicationController
  before_action :require_login
  before_action :set_photo

  def create
    response = post_tweet

    if response.code.to_i == 201
      redirect_to photos_path, notice: "ツイートを投稿しました。"
    else
      redirect_to photos_path, alert: "ツイートの投稿に失敗しました。"
    end
  end

  private

  def set_photo
    @photo = current_user.photos.find(params[:photo_id])
  end

  # ツイート投稿のAPIリクエストを送信する。
  # レスポンス: Net::HTTPResponse オブジェクト
  def post_tweet
    uri = URI.parse(tweet_api_url)
    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer #{access_token}"
    request.body = {
      text: @photo.title,
      url: rails_blob_url(@photo.image)
    }.to_json

    Net::HTTP.start(uri.host, uri.port) do |http|
      http.request(request)
    end
  end
end
