class CreateRatings < ActiveRecord::Migration[8.1]
  def change
    create_table :ratings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :article, null: false, foreign_key: true
      t.integer :score, null: false, default: 0

      t.timestamps
    end

    add_index :ratings, [ :user_id, :article_id ], unique: true
  end
end
