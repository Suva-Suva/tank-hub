# app/models/tank_tech_spec.rb
class TankTechSpec < ApplicationRecord
  belongs_to :game

  enum :tank_class, {
    light: 0, medium: 1, heavy: 2, td: 3, spg: 4
  }, prefix: true, suffix: true, validate: true

  validates :name,
    presence: true,
    uniqueness: {scope: :game_id},
    length: {maximum: 100}

  validates :tier, inclusion: {in: 1..11, message: "Должен быть от 1 до 11"}
  validates :hp, :damage, numericality: {greater_than_or_equal_to: 0, only_integer: true}
  validates :speed, numericality: {greater_than_or_equal_to: 0}

  # Валидация структуры брони (JSONB)
  validate :armor_structure_valid, if: -> { armor.present? }

  scope :by_game, ->(game) { where(game: game) }
  scope :by_tier, ->(tier) { where(tier: tier) }
  scope :by_class, ->(klass) { where(tank_class: klass) }
  scope :searchable, ->(query) { where("name ILIKE ?", "%#{query}%") }

  # Виртуальные атрибуты для сравнения
  def damage_per_minute(dpm_factor = 1.0)
    (damage.to_f * dpm_factor).round(1)
  end

  def as_api_json
    {
      id: id,
      name: name,
      class: tank_class,
      tier: tier,
      specs: {
        hp: hp,
        damage: damage,
        speed: speed,
        armor: armor
      }
    }
  end

  private

  def armor_structure_valid
    unless armor.is_a?(Hash) && %w[front side rear].all? { |key| armor[key].is_a?(Integer) && armor[key] >= 0 }
      errors.add(:armor, "Должен содержать front, side, rear как неотрицательные целые числа")
    end
  end
end
