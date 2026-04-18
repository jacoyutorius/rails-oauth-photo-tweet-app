require "rails_helper"
require "securerandom"

RSpec.describe User, type: :model do
  describe "validations" do
    it "メールアドレスが正規化されたうえでバリデーションが実施されること" do
      email = "user-#{SecureRandom.hex(4)}@example.com"

      user = create(
        :user,
        email: "  #{email.upcase}  ",
        password: "password",
        password_confirmation: "password"
      )

      expect(user.email).to eq(email)
    end

    it "メールアドレスの大文字小文字を区別せず重複が許可されないこと" do
      email = "user-#{SecureRandom.hex(4)}@example.com"

      create(:user, email: email)

      user = build(
        :user,
        email: email.upcase,
      )

      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("はすでに使用されています")
    end

    it "パスワードが必須であること" do
      user = build(:user, password: nil, password_confirmation: nil)

      expect(user).not_to be_valid
      expect(user.errors[:password]).to be_present
    end

    it "パスワードとパスワード(確認用)が一致していること" do
      user = build(:user, password: "password", password_confirmation: "different")

      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to be_present
    end
  end
end
