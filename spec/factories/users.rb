# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'SecurePass123!' }
    role { :member }
    active { true }
    metadata { {} }

    trait :admin do
      role { :admin }
    end

    trait :moderator do
      role { :moderator }
    end

    trait :inactive do
      active { false }
    end
  end
end