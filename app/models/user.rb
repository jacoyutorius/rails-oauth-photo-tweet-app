class User < ApplicationRecord
  before_validation :normalize_email

  has_secure_password

  validates :email, presence: true, uniqueness: { case_sensitive: false }

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
