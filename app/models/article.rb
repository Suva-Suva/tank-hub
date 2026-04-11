# app/models/article.rb
class Article < ApplicationRecord
  include PgSearch::Model

  belongs_to :game
  belongs_to :author, class_name: "User", optional: true
  has_many :article_categories, dependent: :destroy
  has_many :categories, through: :article_categories
  has_many :ratings, dependent: :destroy
  has_many :bookmarks, dependent: :destroy

  enum :status, {draft: 0, published: 1, archived: 2}, prefix: true, validate: true

  validates :title, presence: true, length: {maximum: 255}
  validates :slug,
    presence: true,
    uniqueness: {scope: :game_id},
    format: {with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/}

  validates :body, presence: true, if: -> { status == "published" }
  validates :published_at, presence: true, if: -> { status == "published" }

  before_validation :generate_slug, if: :slug_blank?
  before_save :set_published_at, if: :will_save_change_to_status?

  pg_search_scope :search_fulltext,
    against: %i[title body],
    using: {
      tsearch: {
        prefix: true,
        dictionary: "russian",
        tsvector_column: "search_vector"
      }
    }

  scope :published, -> { where(status: :published).where("published_at <= ?", Time.current) }
  scope :recent, ->(count = 5) { published.order(published_at: :desc).limit(count) }
  scope :by_game, ->(game) { where(game: game) }

  def as_api_json(include_author: false)
    result = {
      id: id,
      title: title,
      slug: slug,
      status: status,
      published_at: published_at&.iso8601,
      game_id: game_id
    }
    result[:author] = author.as_api_json if include_author && author
    result
  end

  private

  def slug_blank? = slug.blank?

  def generate_slug
    self.slug = title.parameterize if slug.blank? && title.present?
  end

  def set_published_at
    self.published_at = Time.current if status == "published" && published_at.nil?
  end
end
