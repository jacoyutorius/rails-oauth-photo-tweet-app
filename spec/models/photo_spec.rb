require "rails_helper"

RSpec.describe Photo, type: :model do
  it "is valid with a title and user" do
    expect(build(:photo)).to be_valid
  end

  it "is invalid without a title" do
    expect(build(:photo, title: "")).not_to be_valid
  end

  it "is invalid when the title is longer than 30 characters" do
    expect(build(:photo, title: "a" * 31)).not_to be_valid
  end
end
