# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_11_202657) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  create_table "article_categories", force: :cascade do |t|
    t.bigint "article_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id", "category_id"], name: "idx_article_cat_unique", unique: true
    t.index ["article_id"], name: "index_article_categories_on_article_id"
    t.index ["category_id"], name: "index_article_categories_on_category_id"
  end

  create_table "articles", force: :cascade do |t|
    t.bigint "author_id"
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.bigint "game_id", null: false
    t.jsonb "meta", default: {}, null: false
    t.datetime "published_at"
    t.tsvector "search_vector"
    t.string "slug", limit: 255, null: false
    t.integer "status", default: 0, null: false
    t.string "title", limit: 255, null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_articles_on_author_id"
    t.index ["game_id", "slug"], name: "idx_articles_game_slug_unique", unique: true
    t.index ["game_id"], name: "index_articles_on_game_id"
    t.index ["search_vector"], name: "index_articles_on_search_vector", using: :gin
    t.index ["status", "published_at"], name: "idx_articles_status_published"
    t.index ["title"], name: "idx_articles_title_trgm", opclass: :gin_trgm_ops, using: :gin
  end

  create_table "categories", force: :cascade do |t|
    t.bigint "categorizable_id"
    t.string "categorizable_type"
    t.datetime "created_at", null: false
    t.integer "depth", default: 0, null: false
    t.integer "lft", null: false
    t.jsonb "meta", default: {}, null: false
    t.string "name", limit: 100, null: false
    t.bigint "parent_id"
    t.integer "rgt", null: false
    t.string "slug", limit: 100, null: false
    t.datetime "updated_at", null: false
    t.index ["categorizable_type", "categorizable_id", "slug"], name: "idx_cat_slug_unique", unique: true
    t.index ["lft", "rgt"], name: "idx_cat_nested_set"
    t.index ["parent_id"], name: "index_categories_on_parent_id"
  end

  create_table "games", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_active", default: true, null: false
    t.jsonb "settings", default: {}, null: false
    t.string "slug", limit: 100, null: false
    t.string "title", limit: 100, null: false
    t.datetime "updated_at", null: false
    t.index ["is_active", "title"], name: "idx_games_active_title"
    t.index ["slug"], name: "index_games_on_slug", unique: true
  end

  create_table "ratings", force: :cascade do |t|
    t.bigint "article_id", null: false
    t.datetime "created_at", null: false
    t.integer "score", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["article_id"], name: "index_ratings_on_article_id"
    t.index ["user_id", "article_id"], name: "index_ratings_on_user_id_and_article_id", unique: true
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "tank_tech_specs", force: :cascade do |t|
    t.jsonb "additional_specs", default: {}, null: false
    t.jsonb "armor", default: {}, null: false
    t.datetime "created_at", null: false
    t.integer "damage", null: false
    t.bigint "game_id", null: false
    t.integer "hp", null: false
    t.string "name", limit: 100, null: false
    t.decimal "speed", precision: 5, scale: 2, null: false
    t.integer "tank_class", null: false
    t.integer "tier", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "name"], name: "idx_tanks_game_name_unique", unique: true
    t.index ["game_id"], name: "index_tank_tech_specs_on_game_id"
    t.index ["name"], name: "idx_tanks_name_trgm", opclass: :gin_trgm_ops, using: :gin
    t.index ["tier", "tank_class"], name: "idx_tanks_tier_class"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "email", limit: 255, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["active", "created_at"], name: "idx_users_active_created"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "article_categories", "articles"
  add_foreign_key "article_categories", "categories"
  add_foreign_key "articles", "games"
  add_foreign_key "articles", "users", column: "author_id"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "ratings", "articles"
  add_foreign_key "ratings", "users"
  add_foreign_key "tank_tech_specs", "games"
end
