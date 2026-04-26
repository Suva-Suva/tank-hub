# app/models/game.rb
class Game < ApplicationRecord
  has_many :articles, dependent: :restrict_with_error
  has_many :tank_tech_specs, dependent: :restrict_with_error
  has_many :categories, as: :categorizable, dependent: :destroy

  validates :title,
    presence: true,
    uniqueness: { case_sensitive: false },
    length: { maximum: 100 }

  validates :slug,
    presence: true,
    uniqueness: true,
    format: {
      with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/,
      message: "Только латиница, цифры и дефис"
    }

  before_validation :generate_slug, if: :slug_blank?

  scope :active, -> { where(is_active: true) }
  scope :ordered, -> { order(title: :asc) }

  private

  def slug_blank? = slug.blank?

  def generate_slug
    self.slug = title.parameterize if slug.blank?
  end
end
