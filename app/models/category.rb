# app/models/category.rb
class Category < ApplicationRecord
  belongs_to :categorizable, polymorphic: true, optional: true
  belongs_to :parent, class_name: "Category", optional: true
  has_many :children, class_name: "Category", foreign_key: :parent_id, dependent: :destroy

  has_many :article_categories, dependent: :destroy
  has_many :articles, through: :article_categories

  validates :name,
    presence: true,
    uniqueness: {
      scope: %i[categorizable_type categorizable_id],
      case_sensitive: false
    }

  validates :slug,
    presence: true,
    uniqueness: {scope: %i[categorizable_type categorizable_id]},
    format: {with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/}

  validates :depth, numericality: {only_integer: true, greater_than_or_equal_to: 0}

  before_validation :generate_slug, if: :slug_blank?
  before_create :set_nested_set_boundaries

  scope :for_game, ->(game) { where(categorizable: game) }
  scope :root, -> { where(parent_id: nil) }

  # Получение всех потомков (рекурсивно)
  def descendants
    Category.where("lft > ? AND rgt < ?", lft, rgt)
  end

  def as_api_json
    {
      id: id,
      name: name,
      slug: slug,
      depth: depth,
      parent_id: parent_id
    }
  end

  private

  def slug_blank? = slug.blank?

  def generate_slug
    self.slug = name.parameterize if slug.blank?
  end

  def set_nested_set_boundaries
    if parent_id.nil?
      # Корневая категория
      max_rgt = Category.where(parent_id: nil).maximum(:rgt) || 0
      self.lft = max_rgt + 1
      self.rgt = max_rgt + 2
      self.depth = 0
    else
      # Вложенная категория
      parent.reload # гарантируем актуальность данных
      self.lft = parent.rgt
      self.rgt = parent.rgt + 1
      self.depth = parent.depth + 1

      # Сдвигаем правые границы у "правых" соседей
      Category.where("lft >= ?", parent.rgt).update_all(
        "lft = lft + 2, rgt = rgt + 2"
      )
    end
  end
end
