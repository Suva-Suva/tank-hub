require "rails_helper"

RSpec.describe "Api::V1::Admin::Articles", type: :request do
  let(:member) { create(:user) }
  let(:moderator) { create(:user, :moderator) }
  let(:admin) { create(:user, :admin) }
  let(:game) { create(:game) }

  # --- INDEX ---

  describe "GET /api/v1/admin/articles" do
    it "требует аутентификацию" do
      get api_v1_admin_articles_path, as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    context "как обычный пользователь (member)" do
      it "видит только свои статьи" do
        own = create(:article, game: game, author: member)
        other = create(:article, game: game, author: create(:user))

        get api_v1_admin_articles_path, headers: auth_headers_for(member), as: :json

        expect(response).to have_http_status(:ok)
        ids = response.parsed_body["data"].map { |a| a["id"] }
        expect(ids).to include(own.id)
        expect(ids).not_to include(other.id)
      end

      it "может фильтровать по статусу" do
        draft = create(:article, :draft, game: game, author: member)
        published = create(:article, :published, game: game, author: member)

        get api_v1_admin_articles_path, params: {status: "draft"}, headers: auth_headers_for(member)

        ids = response.parsed_body["data"].map { |a| a["id"] }
        expect(ids).to include(draft.id)
        expect(ids).not_to include(published.id)
      end
    end

    context "как модератор" do
      it "видит только свои статьи, а не чужие" do
        own = create(:article, game: game, author: moderator)
        admin_article = create(:article, game: game, author: admin)

        get api_v1_admin_articles_path, headers: auth_headers_for(moderator), as: :json

        ids = response.parsed_body["data"].map { |a| a["id"] }
        expect(ids).to include(own.id)
        expect(ids).not_to include(admin_article.id)
      end
    end

    context "как администратор" do
      it "видит все статьи всех авторов" do
        article1 = create(:article, game: game, author: member)
        article2 = create(:article, game: game, author: moderator)

        get api_v1_admin_articles_path, headers: auth_headers_for(admin), as: :json

        ids = response.parsed_body["data"].map { |a| a["id"] }
        expect(ids).to include(article1.id, article2.id)
      end

      it "может фильтровать по game_id" do
        other_game = create(:game)
        in_game = create(:article, game: game, author: member)
        in_other = create(:article, game: other_game, author: member)

        get api_v1_admin_articles_path, params: {game_id: game.id}, headers: auth_headers_for(admin)

        ids = response.parsed_body["data"].map { |a| a["id"] }
        expect(ids).to include(in_game.id)
        expect(ids).not_to include(in_other.id)
      end
    end
  end

  # --- CREATE ---

  describe "POST /api/v1/admin/articles" do
    let(:article_params) do
      {article: {title: "New Article Guide", body: "Some article content", game_id: game.id}}
    end

    it "требует аутентификацию" do
      post api_v1_admin_articles_path, params: article_params, as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    context "как обычный пользователь (member)" do
      it "создаёт черновик с текущим пользователем как автором" do
        post api_v1_admin_articles_path, params: article_params, headers: auth_headers_for(member), as: :json

        expect(response).to have_http_status(:created)
        article = Article.last
        expect(article.author).to eq(member)
        expect(article.title).to eq("New Article Guide")
        expect(article.status).to eq("draft")
      end
    end

    context "как модератор" do
      it "создаёт статью" do
        post api_v1_admin_articles_path, params: article_params, headers: auth_headers_for(moderator), as: :json

        expect(response).to have_http_status(:created)
        expect(Article.last.author).to eq(moderator)
      end
    end

    context "как администратор" do
      it "создаёт статью" do
        post api_v1_admin_articles_path, params: article_params, headers: auth_headers_for(admin), as: :json
        expect(response).to have_http_status(:created)
      end

      it "возвращает ошибки при пустом заголовке" do
        post api_v1_admin_articles_path,
          params: {article: {title: "", body: "content", game_id: game.id}},
          headers: auth_headers_for(admin),
          as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body).to have_key("errors")
      end

      it "возвращает ошибку при отсутствии game_id" do
        post api_v1_admin_articles_path,
          params: {article: {title: "Title", body: "content"}},
          headers: auth_headers_for(admin),
          as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  # --- SHOW ---

  describe "GET /api/v1/admin/articles/:id" do
    let!(:article) { create(:article, game: game, author: member) }

    it "требует аутентификацию" do
      get api_v1_admin_article_path(article), as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    context "как обычный пользователь — своя статья" do
      it "возвращает статью" do
        get api_v1_admin_article_path(article), headers: auth_headers_for(member), as: :json

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["id"]).to eq(article.id)
      end
    end

    context "как обычный пользователь — чужая статья" do
      let!(:other_article) { create(:article, game: game, author: create(:user)) }

      it "возвращает 404" do
        get api_v1_admin_article_path(other_article), headers: auth_headers_for(member), as: :json
        expect(response).to have_http_status(:not_found)
      end
    end

    context "как администратор" do
      it "видит любую статью" do
        get api_v1_admin_article_path(article), headers: auth_headers_for(admin), as: :json
        expect(response).to have_http_status(:ok)
      end
    end
  end

  # --- UPDATE ---

  describe "PATCH /api/v1/admin/articles/:id" do
    let!(:article) { create(:article, game: game, author: member) }

    it "требует аутентификацию" do
      patch api_v1_admin_article_path(article), params: {article: {title: "X"}}, as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    context "как обычный пользователь — своя статья" do
      it "обновляет заголовок" do
        patch api_v1_admin_article_path(article),
          params: {article: {title: "Обновлённый заголовок"}},
          headers: auth_headers_for(member),
          as: :json

        expect(response).to have_http_status(:ok)
        expect(article.reload.title).to eq("Обновлённый заголовок")
      end
    end

    context "как обычный пользователь — чужая статья" do
      let!(:other_article) { create(:article, game: game, author: create(:user)) }

      it "возвращает 404" do
        patch api_v1_admin_article_path(other_article),
          params: {article: {title: "Взлом"}},
          headers: auth_headers_for(member),
          as: :json

        expect(response).to have_http_status(:not_found)
        expect(other_article.reload.title).not_to eq("Взлом")
      end
    end

    context "как модератор — своя статья" do
      let!(:mod_article) { create(:article, game: game, author: moderator) }

      it "обновляет статью" do
        patch api_v1_admin_article_path(mod_article),
          params: {article: {title: "Статья модератора v2"}},
          headers: auth_headers_for(moderator),
          as: :json

        expect(response).to have_http_status(:ok)
        expect(mod_article.reload.title).to eq("Статья модератора v2")
      end
    end

    context "как администратор" do
      it "может обновить любую статью" do
        patch api_v1_admin_article_path(article),
          params: {article: {title: "Изменено администратором"}},
          headers: auth_headers_for(admin),
          as: :json

        expect(response).to have_http_status(:ok)
        expect(article.reload.title).to eq("Изменено администратором")
      end
    end
  end

  # --- DELETE ---

  describe "DELETE /api/v1/admin/articles/:id" do
    it "требует аутентификацию" do
      article = create(:article, game: game, author: member)
      delete api_v1_admin_article_path(article), as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    context "как обычный пользователь — своя статья" do
      it "удаляет статью" do
        article = create(:article, game: game, author: member)
        delete api_v1_admin_article_path(article), headers: auth_headers_for(member), as: :json

        expect(response).to have_http_status(:no_content)
        expect(Article.find_by(id: article.id)).to be_nil
      end
    end

    context "как обычный пользователь — чужая статья" do
      it "возвращает 404 и не удаляет" do
        other_article = create(:article, game: game, author: create(:user))
        delete api_v1_admin_article_path(other_article), headers: auth_headers_for(member), as: :json

        expect(response).to have_http_status(:not_found)
        expect(Article.find_by(id: other_article.id)).to be_present
      end
    end

    context "как администратор" do
      it "может удалить любую статью" do
        article = create(:article, game: game, author: member)
        delete api_v1_admin_article_path(article), headers: auth_headers_for(admin), as: :json

        expect(response).to have_http_status(:no_content)
        expect(Article.find_by(id: article.id)).to be_nil
      end
    end
  end

  # --- PUBLISH ---

  describe "POST /api/v1/admin/articles/:id/publish" do
    let!(:draft_article) { create(:article, :draft, game: game, author: member) }

    it "требует аутентификацию" do
      post publish_api_v1_admin_article_path(draft_article), as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    context "как обычный пользователь — своя статья" do
      it "публикует статью и устанавливает published_at" do
        post publish_api_v1_admin_article_path(draft_article),
          headers: auth_headers_for(member),
          as: :json

        expect(response).to have_http_status(:ok)
        draft_article.reload
        expect(draft_article.status).to eq("published")
        expect(draft_article.published_at).to be_present
      end
    end

    context "как модератор — своя статья" do
      let!(:mod_draft) { create(:article, :draft, game: game, author: moderator) }

      it "публикует статью" do
        post publish_api_v1_admin_article_path(mod_draft),
          headers: auth_headers_for(moderator),
          as: :json

        expect(response).to have_http_status(:ok)
        expect(mod_draft.reload.status).to eq("published")
      end
    end

    context "как администратор" do
      it "публикует любую статью" do
        post publish_api_v1_admin_article_path(draft_article),
          headers: auth_headers_for(admin),
          as: :json

        expect(response).to have_http_status(:ok)
        expect(draft_article.reload.status).to eq("published")
      end
    end
  end

  # --- UNPUBLISH ---

  describe "POST /api/v1/admin/articles/:id/unpublish" do
    let!(:pub_article) { create(:article, :published, game: game, author: member) }

    context "как обычный пользователь — своя статья" do
      it "переводит статью в черновик" do
        post unpublish_api_v1_admin_article_path(pub_article),
          headers: auth_headers_for(member),
          as: :json

        expect(response).to have_http_status(:ok)
        expect(pub_article.reload.status).to eq("draft")
      end
    end

    context "как администратор" do
      it "снимает с публикации любую статью" do
        post unpublish_api_v1_admin_article_path(pub_article),
          headers: auth_headers_for(admin),
          as: :json

        expect(response).to have_http_status(:ok)
        expect(pub_article.reload.status).to eq("draft")
      end
    end
  end

  # --- Без роли (неаутентифицированный запрос) ---

  describe "попытка доступа без токена" do
    it "возвращает 401 на все защищённые эндпоинты" do
      article = create(:article, game: game, author: member)

      aggregate_failures do
        get api_v1_admin_articles_path, as: :json
        expect(response).to have_http_status(:unauthorized)

        post api_v1_admin_articles_path, params: {article: {title: "x"}}, as: :json
        expect(response).to have_http_status(:unauthorized)

        patch api_v1_admin_article_path(article), params: {article: {title: "x"}}, as: :json
        expect(response).to have_http_status(:unauthorized)

        delete api_v1_admin_article_path(article), as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
