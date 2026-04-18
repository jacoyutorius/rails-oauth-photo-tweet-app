class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)

    if user&.authenticate(params[:password].to_s)
      session[:user_id] = user.id
      redirect_to photos_path, notice: "ログインしました。"
    else
      flash.now[:alert] = "メールアドレスまたはパスワードが正しくありません。"
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    session.delete(:user_id)
    session.delete(:access_token)
    redirect_to new_session_path, notice: "ログアウトしました。"
  end
end
