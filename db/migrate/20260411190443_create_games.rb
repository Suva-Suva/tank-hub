class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.string :title, null: false, limit: 100
      t.string :slug, null: false, limit: 100
      t.boolean :is_active, default: true, null: false
      t.jsonb :settings, default: {}, null: false

      t.timestamps
    end

    add_index :games, :slug, unique: true, name: "idx_games_slug_unique"
    add_index :games, :title, unique: true, name: "idx_games_title_unique"
    add_index :games, [ :is_active, :title ], name: "idx_games_active_title"
  end
end
