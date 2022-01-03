FactoryBot.define do
    factory :friendships do
      sent_by { create(:user) }
      sent_to { create(:user) }
    end
  end