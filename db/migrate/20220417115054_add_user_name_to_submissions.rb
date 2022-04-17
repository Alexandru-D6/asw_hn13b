class AddUserNameToSubmissions < ActiveRecord::Migration[6.1]
  def change
    add_column :submissions, :author_username, :string, default: "", null: false
    remove_column :submissions, :user_id, :integer
  end
end
