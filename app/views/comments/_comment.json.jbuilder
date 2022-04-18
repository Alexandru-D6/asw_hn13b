json.extract! comment, :id, :author, :comment, :UpVotes, :created_at, :updated_at, :id_submission, :id_comment_father
json.url comment_url(comment, format: :json)
