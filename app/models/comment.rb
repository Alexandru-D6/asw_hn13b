class Comment < ApplicationRecord
  serialize :id_sons
  
  has_many :comments

  after_initialize do |comment|
    comment.id_sons= [].to_yaml if comment.id_sons == nil
  end
end
