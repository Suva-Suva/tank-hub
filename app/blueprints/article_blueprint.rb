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
end
