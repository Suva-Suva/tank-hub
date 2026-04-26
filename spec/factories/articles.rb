# spec/factories/articles.rb
FactoryBot.define do
  factory :article do
    association :game
    association :author, factory: :user
    sequence(:title) { |n| "Статья ##{n}" }
    sequence(:slug) { |n| "article-#{n}" }
    body { "Контент статьи..." }
    status { :draft }
    meta { {} }

    trait :draft do
      status { :draft }
    end

    trait :published do
      status { :published }
      published_at { Time.current }
    end

    trait :with_categories do
      after(:create) do |article|
        create_list(:category, 2, categorizable: article.game).each do |cat|
          article.categories << cat
        end
      end
    end
  end
end
