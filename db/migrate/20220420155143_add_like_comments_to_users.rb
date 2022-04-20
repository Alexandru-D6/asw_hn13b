class AddLikeCommentsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :LikedComments, :text, array: true
  end
end
