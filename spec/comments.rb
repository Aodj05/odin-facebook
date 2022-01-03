FactoryBot.define do
    factory :comment do
      body { "MyText" }
      author { create(:user) }
      commentable { create(:post) }
    end
  end