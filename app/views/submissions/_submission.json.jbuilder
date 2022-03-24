json.extract! submission, :id, :title, :url, :text, :UpVotes, :created_at, :updated_at, :user_id
json.url submission_url(submission, format: :json)
