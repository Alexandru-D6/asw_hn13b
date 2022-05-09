class RemoveColumnsToComments < ActiveRecord::Migration[6.1]
  def change
    remove_column :comments, :id_sons, :text
    remove_column :comments, :num_sons, :integer
    remove_column :comments, :title_submission, :text
    remove_column :users, :username, :string
  end
end
