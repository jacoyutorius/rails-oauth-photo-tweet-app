require "rails_helper"
require "securerandom"

RSpec.describe User, type: :model do
  describe "validations" do
    it "normalizes email before validation" do
      email = "user-#{SecureRandom.hex(4)}@example.com"

      user = described_class.create!(
        email: "  #{email.upcase}  ",
        password: "password",
        password_confirmation: "password"
      )

      expect(user.email).to eq(email)
    end

    it "does not allow duplicate emails case-insensitively" do
      email = "user-#{SecureRandom.hex(4)}@example.com"

      create(:user, email: email)

      user = build(
        :user,
        email: email.upcase,
      )

      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("has already been taken")
    end

    it "requires a password on create" do
      user = build(:user, password: nil, password_confirmation: nil)

      expect(user).not_to be_valid
      expect(user.errors[:password]).to be_present
    end
  end
end
