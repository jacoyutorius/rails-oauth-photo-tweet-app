FactoryBot.define do
  factory :photo do
    sequence(:title) { |n| "photo-#{n}" }
    association :user

    after(:build) do |photo|
      next if photo.image.attached?

      photo.image.attach(
        io: Rails.root.join("spec/fixtures/files/test-image.jpg").open,
        filename: "test-image.jpg",
        content_type: "image/jpeg"
      )
    end
  end
end
