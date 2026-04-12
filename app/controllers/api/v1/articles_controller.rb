# app/controllers/api/v1/articles_controller.rb
module Api
  module V1
    class ArticlesController < BaseController

      def index
        scope = Article.published.includes(:author, :game)
        scope = scope.by_game(Game.find_by!(slug: params[:game_slug])) if params[:game_slug]
        scope = scope.search_fulltext(params[:q]) if params[:q].present?
        scope = scope.order(published_at: :desc)

        render_paginated(scope, blueprint: ArticleBlueprint, view: :default)
      end

      def show
        article = Article.published
          .includes(:author, :game)
          .find_by!(slug: params[:slug], game: game_scope)

        render json: ArticleBlueprint.render(article, view: :detailed)
      end

      def related
        article = Article.published.find_by!(slug: params[:slug])
        related = Article.published
          .where.not(id: article.id)
          .where(game: article.game)
          .limit(3)
        render json: ArticleBlueprint.render(related, view: :default)
      end

      private

      def game_scope
        @game_scope ||= Game.find_by(slug: params[:game_slug])
      end
    end
  end
end
