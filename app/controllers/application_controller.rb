class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :oauth_authorize_url

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def oauth_authorize_url
    return nil if oauth_client_id.blank?

    query = {
      client_id: oauth_client_id,
      response_type: "code",
      redirect_uri: oauth_redirect_uri,
      scope: oauth_scope
    }.to_query

    "#{oauth_authorize_base_url}?#{query}"
  end

  def require_login
    return if current_user.present?

    redirect_to new_session_path, alert: "ログインしてください。"
  end

  def oauth_client_id
    ENV.fetch("OAUTH_CLIENT_ID")
  end

  def oauth_authorize_base_url
    ENV.fetch("OAUTH_AUTHORIZE_URL")
  end

  def oauth_redirect_uri
    ENV.fetch("OAUTH_REDIRECT_URI")
  end

  def oauth_scope
    ENV.fetch("OAUTH_SCOPE")
  end
end
