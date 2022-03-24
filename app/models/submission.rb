class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([^@\s]+\.)+((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      record.errors.add attribute, ("Insert a valid URL")
    end
  end
end

class Submission < ApplicationRecord
  validates :title, length: {maximum: 40}, presence: {message: "Title can't be blank."}
  validates :url, presence: false, url: true
end
