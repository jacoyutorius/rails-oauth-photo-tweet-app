require "net/http"
require "json"

class OauthController < ApplicationController
  before_action :require_login

  def callback
    # 認可コードを取得
    authorization_code = params[:code]

    # アクセストークンを取得
    access_token = fetch_access_token(authorization_code)

    if access_token.present?
      session[:access_token] = access_token
      redirect_to photos_path, notice: "アクセストークンを取得しました。"
    else
      redirect_to photos_path, alert: "アクセストークンの取得に失敗しました。"
    end
  end

  private

  # 認可コードをアクセストークンに交換する
  # 戻り値: アクセストークン文字列、取得に失敗した場合は nil
  def fetch_access_token(code)
    uri = URI.parse(oauth_token_url)
    request = Net::HTTP::Post.new(uri)
    request.set_form_data(
      code: code,
      client_id: oauth_client_id,
      client_secret: oauth_client_secret,
      redirect_uri: oauth_redirect_uri,
      grant_type: "authorization_code"
    )

    response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.request(request)
    end

    # デバッグ用
    # Rails.logger.info "----------response----------"
    # Rails.logger.info response.body
    # Rails.logger.info "----------------------------"

    response_body = JSON.parse(response.body)
    response_body.fetch("access_token", nil)
  rescue JSON::ParserError
    nil
  end
end
