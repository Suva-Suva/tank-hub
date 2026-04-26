class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false, limit: 255
      t.string :password_digest, null: false
      t.integer :role, default: 0, null: false
      t.boolean :active, default: true, null: false
      t.jsonb :metadata, default: {}, null: false

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :role
    add_index :users, [ :active, :created_at ], name: "idx_users_active_created"
  end
end
