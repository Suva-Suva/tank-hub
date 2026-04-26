# app/models/user.rb
class User < ApplicationRecord
  has_secure_password

  enum :role, { member: 0, moderator: 1, admin: 2 }, prefix: true, validate: true

  has_many :articles, foreign_key: :author_id, dependent: :nullify
  has_many :bookmarks, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :rated_articles, through: :ratings, source: :article

  validates :email,
    presence: true,
    uniqueness: true,
    format: { with: URI::MailTo::EMAIL_REGEXP, message: "Некорректный формат" }

  validates :role, inclusion: { in: roles.keys }

  before_save :downcase_email

  scope :active, -> { where(active: true) }
  scope :with_role, ->(role_name) { where(role: role_name) }

  # Метод для сериализации
  def as_api_json
    {
      id: id,
      email: email,
      role: role,
      created_at: created_at.iso8601
    }
  end

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
