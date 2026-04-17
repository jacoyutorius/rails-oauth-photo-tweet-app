require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "normalizes email before validation" do
      user = described_class.create!(
        email: "  TEST@Example.COM  ",
        password: "password",
        password_confirmation: "password"
      )

      expect(user.email).to eq("test@example.com")
    end

    it "does not allow duplicate emails case-insensitively" do
      described_class.create!(
        email: "test@example.com",
        password: "password",
        password_confirmation: "password"
      )

      user = described_class.new(
        email: "TEST@example.com",
        password: "password",
        password_confirmation: "password"
      )

      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("has already been taken")
    end

    it "requires a password on create" do
      user = described_class.new(email: "test@example.com")

      expect(user).not_to be_valid
      expect(user.errors[:password]).to be_present
    end
  end
end
