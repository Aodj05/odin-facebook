FactoryBot.define do
    factory :post do
      content { Faker::FBUsers.quote }
      user { create(:user) }
    end
  end