# spec/factories/games.rb
FactoryBot.define do
  factory :game do
    sequence(:title) { |n| "World of Tanks #{n}" }
    sequence(:slug) { |n| "wot-#{n}" }
    is_active { true }
    settings { {} }
  end
end
