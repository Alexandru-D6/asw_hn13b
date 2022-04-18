class AddCommentToComments < ActiveRecord::Migration[6.1]
  def change
    add_reference :comments, :comment
  end
end
