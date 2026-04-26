require "rails_helper"

RSpec.describe "Api::V1::Articles (публичные)", type: :request do
  let(:game) { create(:game) }

  describe "GET /api/v1/articles" do
    it "возвращает только опубликованные статьи" do
      published = create(:article, :published, game: game)
      draft = create(:article, :draft, game: game)

      get api_v1_articles_path, as: :json

      expect(response).to have_http_status(:ok)
      ids = response.parsed_body["data"].map { |a| a["id"] }
      expect(ids).to include(published.id)
      expect(ids).not_to include(draft.id)
    end

    it "не возвращает статьи с датой публикации в будущем" do
      future = create(:article, :published, game: game, published_at: 1.day.from_now)

      get api_v1_articles_path, as: :json

      ids = response.parsed_body["data"].map { |a| a["id"] }
      expect(ids).not_to include(future.id)
    end

    it "фильтрует по game_slug" do
      other_game = create(:game)
      in_game = create(:article, :published, game: game)
      in_other = create(:article, :published, game: other_game)

      get api_v1_articles_path, params: {game_slug: game.slug}

      ids = response.parsed_body["data"].map { |a| a["id"] }
      expect(ids).to include(in_game.id)
      expect(ids).not_to include(in_other.id)
    end

    it "возвращает мета-информацию пагинации" do
      get api_v1_articles_path, as: :json

      meta = response.parsed_body["meta"]
      expect(meta).to include("current_page", "total_pages", "total_count")
      expect(meta["current_page"]).to eq(1)
    end

    it "сортирует по дате публикации (новые первые)" do
      old_article = create(:article, :published, game: game, published_at: 2.days.ago)
      new_article = create(:article, :published, game: game, published_at: 1.day.ago)

      get api_v1_articles_path, as: :json

      ids = response.parsed_body["data"].map { |a| a["id"] }
      expect(ids.index(new_article.id)).to be < ids.index(old_article.id)
    end
  end

  describe "GET /api/v1/articles/:slug" do
    it "возвращает опубликованную статью" do
      article = create(:article, :published, game: game)

      get api_v1_article_path(article.slug), as: :json

      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json["slug"]).to eq(article.slug)
      expect(json["title"]).to eq(article.title)
    end

    it "возвращает 404 для черновика" do
      article = create(:article, :draft, game: game)

      get api_v1_article_path(article.slug), as: :json

      expect(response).to have_http_status(:not_found)
    end

    it "возвращает 404 для несуществующего slug" do
      get api_v1_article_path("nonexistent-slug"), as: :json
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /api/v1/articles/:slug/related" do
    it "возвращает опубликованные статьи той же игры (без текущей)" do
      article = create(:article, :published, game: game)
      related = create(:article, :published, game: game)
      other_game_article = create(:article, :published, game: create(:game))

      get related_api_v1_article_path(article.slug), as: :json

      expect(response).to have_http_status(:ok)
      ids = response.parsed_body.map { |a| a["id"] }
      expect(ids).to include(related.id)
      expect(ids).not_to include(article.id)
      expect(ids).not_to include(other_game_article.id)
    end

    it "возвращает не более 3 статей" do
      article = create(:article, :published, game: game)
      create_list(:article, 5, :published, game: game)

      get related_api_v1_article_path(article.slug), as: :json

      expect(response.parsed_body.length).to be <= 3
    end

    it "возвращает 404 для несуществующего slug" do
      get related_api_v1_article_path("nonexistent"), as: :json
      expect(response).to have_http_status(:not_found)
    end
  end
end
