class Comment < ApplicationRecord
  serialize :id_sons

  after_initialize do |comment|
    comment.id_sons= [] if comment.id_sons == nil
  end
end