class Comment < ApplicationRecord
  serialize :id_sons
  
  has_many :comments
end
