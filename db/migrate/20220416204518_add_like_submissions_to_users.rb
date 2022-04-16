class AddLikeSubmissionsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :likedSubmissions, :string, array: true, default: '{}'
  end
end
