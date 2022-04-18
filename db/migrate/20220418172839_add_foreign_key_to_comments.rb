class AddForeignKeyToComments < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key :comments, :comments
  end
end
