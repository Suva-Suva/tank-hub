# app/blueprints/article_blueprint.rb
class ArticleBlueprint < BaseBlueprint
  identifier :id
  fields :title, :slug, :status, :published_at

  field :author_name do |article, _options|
    article.author&.email&.split("@")&.first
  end

  view :detailed do
    field :body
    association :game, blueprint: GameBlueprint
  end

  view :admin do
    field :body
    field :status
    field :meta
    field :game_id
    field :author_id
    field :category_ids do |article, _| article.category_ids end
    association :game, blueprint: GameBlueprint
    association :author, blueprint: AuthorBlueprint
  end

end
