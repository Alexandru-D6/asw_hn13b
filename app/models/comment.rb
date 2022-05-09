class Comment < ApplicationRecord
  #serialize :id_sons
  
  has_many :comments
  
  validates :comment, length: { minimum: 5, maximum: 256}, presence: {message: "Comment can't be blank."}
end
