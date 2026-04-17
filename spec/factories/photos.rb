FactoryBot.define do
  factory :photo do
    sequence(:title) { |n| "photo-#{n}" }
    association :user
  end
end
