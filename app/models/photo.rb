class Photo < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  validates :title, presence: true, length: { maximum: 30 }

  validate :image_must_be_attached

  private

  # 画像が添付されているかを検証するカスタムバリデーション
  def image_must_be_attached
    errors.add(:image, :blank) unless image.attached?
  end
end
