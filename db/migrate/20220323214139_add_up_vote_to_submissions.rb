class AddUpVoteToSubmissions < ActiveRecord::Migration[6.1]
  def change
    add_column :submissions, :UpVotes, :integer, default: 0;
  end
end
