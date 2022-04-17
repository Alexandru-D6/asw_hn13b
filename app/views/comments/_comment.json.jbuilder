json.extract! comment, :id, :author, :comment, :root_comment, :id_reference, :UpVotes, :created_at, :updated_at
json.url comment_url(comment, format: :json)
