require "rails_helper"
require "securerandom"

RSpec.describe "Users", type: :request do
  describe "GET /users/new" do
    it "returns success" do
      get new_user_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /users" do
    it "creates a user with valid params" do
      email = "user-#{SecureRandom.hex(4)}@example.com"

      post users_path, params: {
        user: {
          email: email,
          password: "password",
          password_confirmation: "password"
        }
      }

      expect(response).to have_http_status(:found)
      expect(User.find_by(email: email)).to be_present
    end

    it "does not create a user with invalid params" do
      expect do
        post users_path, params: {
          user: {
            email: "",
            password: "password",
            password_confirmation: "different"
          }
        }
      end.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
