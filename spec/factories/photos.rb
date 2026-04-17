FactoryBot.define do
  factory :photo do
    sequence(:title) { |n| "photo-#{n}" }
    association :user

    after(:build) do |photo|
      next if photo.image.attached?

      photo.image.attach(
        io: Rails.root.join("spec/fixtures/files/test-image.svg").open,
        filename: "test-image.svg",
        content_type: "image/svg+xml"
      )
    end
  end
end
