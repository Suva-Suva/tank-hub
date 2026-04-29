class RenameContentToBodyInComments < ActiveRecord::Migration[8.0]
  def change
    rename_column :comments, :content, :body
  end
end
