class AddForeignKeyToSubmission < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key :comments, :submissions
  end
end
