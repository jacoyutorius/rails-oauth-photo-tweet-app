require "rails_helper"

RSpec.describe Photo, type: :model do
  it "タイトルとユーザーがあれば有効である" do
    expect(build(:photo)).to be_valid
  end

  it "画像がなければ無効である" do
    photo = build(:photo)
    photo.image.detach

    expect(photo).not_to be_valid
  end

  it "タイトルがなければ無効である" do
    expect(build(:photo, title: "")).not_to be_valid
  end

  it "タイトルが31文字以上なら無効である" do
    expect(build(:photo, title: "a" * 31)).not_to be_valid
  end
end
