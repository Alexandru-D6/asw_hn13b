class AddCommentToSubmissions < ActiveRecord::Migration[6.1]
  def change
    add_reference :comments, :submission
  end
end
