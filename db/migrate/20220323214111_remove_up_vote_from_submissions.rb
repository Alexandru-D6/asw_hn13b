class RemoveUpVoteFromSubmissions < ActiveRecord::Migration[6.1]
  def change
    remove_column :submissions, :UpVotes, :integer
  end
end
