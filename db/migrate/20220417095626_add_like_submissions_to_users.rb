class AddLikeSubmissionsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :LikedSubmissions, :text, array: true
  end
end
