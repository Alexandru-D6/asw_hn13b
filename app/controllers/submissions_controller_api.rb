require 'SoftDeleteComments'

class SubmissionsController < ApplicationController
  before_action :set_submission, only: %i[ show edit update destroy ]
  
  def index
    temp = Submission.all.order(UpVotes: :desc, title: :asc)
    
    @submissions = Array.new(0)
    temp.each do |temp|
      if temp.author_username != ""
        @submissions.push(temp)  
      end
    end
    
    @shorturl = Array.new(0)
    @submissions.each do |submission|
      if submission.url != ""
        url =submission.url.split('//')
        shortu = url[1].split('/')
        @shorturl.push(shortu[0])
      else 
        @shorturl.push("")
      end
    end
    
    respond_to do |format|
      format.json {render json: @submissions, status: :ok}
    end
  end
end