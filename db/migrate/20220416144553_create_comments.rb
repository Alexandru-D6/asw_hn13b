class CreateComments < ActiveRecord::Migration[6.1]
  def change
    create_table :comments do |t|
      t.string :author, null: false, default: ""
      t.text :comment, null: false, default: ""
      t.boolean :root_comment, default: true
      t.integer :id_reference, null: false, default: 0
      t.integer :UpVotes, default: 0

      t.timestamps
    end
  end
end
