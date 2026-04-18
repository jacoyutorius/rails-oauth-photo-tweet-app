require "rails_helper"

RSpec.describe Photo, type: :model do
  it "タイトルとユーザーがあれば有効であること" do
    user = create(:user)
    photo = build(:photo, title: "Sample Photo", user:)
    expect(photo).to be_valid
  end

  it "画像がなければ無効であること" do
    photo = build(:photo)
    photo.image.detach # テスト用に画像を外す

    expect(photo).not_to be_valid
  end

  it "タイトルがなければ無効であること" do
    photo = build(:photo, title: "")
    photo.valid?
    expect(photo.errors[:title]).to include("を入力してください")
  end

  it "タイトルが31文字以上なら無効であること" do
    photo = build(:photo, title: "a" * 31)
    photo.valid?
    expect(photo.errors[:title]).to include("は30文字以内で入力してください")
  end
end
