# app/controllers/api/v1/admin/articles_controller.rb
module Api
  module V1
    module Admin
      class ArticlesController < BaseController
        include Api::V1::Authenticable

        # Авторы и модераторы могут изменять свои статьи. Админ - все.
        before_action { require_role("admin", "moderator", "member") }
        before_action :set_article, only: %i[show update destroy publish unpublish]

        def index
          scope = Article.includes(:author, :game).order(created_at: :desc)

          # Неадмины видят только свои статьи
          scope = scope.where(author: current_user) unless current_user.role_admin?

          # Фильтры
          scope = scope.where(status: params[:status]) if params[:status].present?
          scope = scope.where(game_id: params[:game_id]) if params[:game_id].present?

          render_paginated(scope, blueprint: ArticleBlueprint, view: :admin)
        end

        def show
          render json: ArticleBlueprint.render(@article, view: :admin)
        end

        def create
          @article = Article.new(article_params.merge(author: current_user))
          if @article.save
            render json: ArticleBlueprint.render(@article, view: :admin), status: :created
          else
            render json: {errors: @article.errors}, status: :unprocessable_content
          end
        end

        def update
          if @article.update(article_params)
            render json: ArticleBlueprint.render(@article, view: :admin)
          else
            render json: {errors: @article.errors}, status: :unprocessable_content
          end
        end

        def destroy
          @article.destroy
          head :no_content
        end

        def publish
          if @article.update(status: :published, published_at: Time.current)
            render json: ArticleBlueprint.render(@article, view: :admin)
          else
            render json: {errors: @article.errors}, status: :unprocessable_content
          end
        end

        def unpublish
          if @article.update(status: :draft)
            render json: ArticleBlueprint.render(@article, view: :admin)
          else
            render json: {errors: @article.errors}, status: :unprocessable_content
          end
        end

        private

        def set_article
          # Админ видит любые, авторы/модераторы → только свои
          @article = current_user.role_admin? ? Article.find(params[:id]) : current_user.articles.find(params[:id])
        end

        def article_params
          params.require(:article).permit(
            :title, :slug, :body, :status, :game_id, :published_at,
            category_ids: [], meta: {}
          )
        end
      end
    end
  end
end
