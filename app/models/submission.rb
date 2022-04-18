class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value != ""
      unless value =~ /\A(https?:\/\/)+([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w\.-]*)*\/?\Z/i
        record.errors.add attribute, ("Insert a valid URL")
      end
    end
  end
end

class Submission < ApplicationRecord
  has_many :comments
  
  validates :title, length: {maximum: 40}, presence: {message: "Title can't be blank."}
  validates :url, presence: false, url: true
end
