class AddColumnsToComments < ActiveRecord::Migration[6.1]
  def change
    add_column :comments, :id_sons, :text, array: true
    add_column :comments, :id_submission, :integer, null: false, default: 0
    add_column :comments, :title_submission, :text, null: false, default: ""
    add_column :comments, :id_comment_father, :integer, null: false, default: 0
    add_column :comments, :num_sons, :integer, null: false, default: 0
    remove_column :comments, :root_comment, :boolean
    remove_column :comments, :id_reference, :integer
  end
end
