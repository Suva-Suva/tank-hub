class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false, limit: 100
      t.string :slug, null: false, limit: 100
      t.references :categorizable, polymorphic: true, null: true, index: false
      t.references :parent, foreign_key: { to_table: :categories }, null: true
      t.integer :lft, null: false
      t.integer :rgt, null: false
      t.integer :depth, default: 0, null: false
      t.jsonb :meta, default: {}, null: false

      t.timestamps
    end

    # Уникальный индекс для полиморфной связи + slug
    add_index :categories, [:categorizable_type, :categorizable_id, :slug],
      unique: true, name: 'idx_cat_slug_unique'
    
    # Индекс для nested set-диапазонов
    add_index :categories, [:lft, :rgt], name: 'idx_cat_nested_set'
    
  end
end