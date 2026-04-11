class CreateTankTechSpecs < ActiveRecord::Migration[8.1]
  def change
    enable_extension 'pg_trgm' unless extension_enabled?('pg_trgm')

    create_table :tank_tech_specs do |t|
      t.references :game, null: false, foreign_key: true
      t.string :name, null: false, limit: 100
      t.integer :tank_class, null: false
      t.integer :tier, null: false
      t.integer :hp, null: false
      t.integer :damage, null: false
      t.decimal :speed, precision: 5, scale: 2, null: false
      t.jsonb :armor, default: {}, null: false
      t.jsonb :additional_specs, default: {}, null: false

      t.timestamps
    end

    add_index :tank_tech_specs, [:game_id, :name], unique: true, name: 'idx_tanks_game_name_unique'
    add_index :tank_tech_specs, [:tier, :tank_class], name: 'idx_tanks_tier_class'
    add_index :tank_tech_specs, :name, using: :gin, opclass: :gin_trgm_ops, name: 'idx_tanks_name_trgm'
  end
end