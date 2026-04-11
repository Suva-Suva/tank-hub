# app/models/rating.rb
class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :article
  validates :score, inclusion: { in: 1..5 }
end