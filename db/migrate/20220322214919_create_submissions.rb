class CreateSubmissions < ActiveRecord::Migration[6.1]
  def change
    create_table :submissions do |t|
      t.string :title
      t.string :url
      t.string :text
      t.integer :UpVotes

      t.timestamps
    end
  end
end
