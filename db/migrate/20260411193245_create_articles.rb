class CreateArticles < ActiveRecord::Migration[8.1]
  def change
    # Включаем расширения для полнотекстового поиска
    enable_extension "pg_trgm" unless extension_enabled?("pg_trgm")

    create_table :articles do |t|
      t.references :game, null: false, foreign_key: true
      t.references :author, foreign_key: {to_table: :users}, null: true
      t.string :title, null: false, limit: 255
      t.string :slug, null: false, limit: 255
      t.text :body, null: false
      t.integer :status, default: 0, null: false
      t.datetime :published_at, precision: 6
      t.jsonb :meta, default: {}, null: false
      t.tsvector :search_vector

      t.timestamps
    end

    add_index :articles, [:game_id, :slug], unique: true, name: "idx_articles_game_slug_unique"
    add_index :articles, [:status, :published_at], name: "idx_articles_status_published"
    add_index :articles, :search_vector, using: :gin
    add_index :articles, :title, using: :gin, opclass: :gin_trgm_ops, name: "idx_articles_title_trgm"

    # Триггер для авто-обновления tsvector (PostgreSQL)
    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          CREATE TRIGGER articles_search_vector_update
          BEFORE INSERT OR UPDATE ON articles
          FOR EACH ROW EXECUTE FUNCTION
          tsvector_update_trigger(
            search_vector, 'pg_catalog.russian', title, body
          );
        SQL
      end

      dir.down do
        execute <<~SQL.squish
          DROP TRIGGER IF EXISTS articles_search_vector_update ON articles;
        SQL
      end
    end
  end
end
