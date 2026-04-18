require "rails_helper"
require "securerandom"

RSpec.describe User, type: :model do
  describe "validations" do
    it "バリデーション前にメールアドレスを正規化する" do
      email = "user-#{SecureRandom.hex(4)}@example.com"

      user = described_class.create!(
        email: "  #{email.upcase}  ",
        password: "password",
        password_confirmation: "password"
      )

      expect(user.email).to eq(email)
    end

    it "メールアドレスの大文字小文字を区別せず重複を許可しない" do
      email = "user-#{SecureRandom.hex(4)}@example.com"

      create(:user, email: email)

      user = build(
        :user,
        email: email.upcase,
      )

      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("はすでに使用されています")
    end

    it "作成時にパスワードを必須とする" do
      user = build(:user, password: nil, password_confirmation: nil)

      expect(user).not_to be_valid
      expect(user.errors[:password]).to be_present
    end
  end
end
