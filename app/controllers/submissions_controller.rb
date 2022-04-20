require 'SoftDeleteComments'

class SubmissionsController < ApplicationController
  before_action :set_submission, only: %i[ show edit update destroy ]

  # GET /submissions or /submissions.json
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
  end
  
  def newest
    temp = Submission.all.order(created_at: :desc, title: :asc)
    
    @submissions = Array.new(0)
    temp.each do |temp|
      if temp.author_username != ""
        @submissions.push(temp)  
      end
    end
    
    @shorturl = Array.new(0);
    @submissions.each do |submission|
      if submission.url != ""
        url =submission.url.split('//')
        shortu = url[1].split('/')
        @shorturl.push(shortu[0])
      else 
        @shorturl.push("")
      end
    end
  end
  
  def ask
    subm = Submission.all.order(created_at: :desc, title: :asc)
    @submissions = Array.new(0)
    subm.each do |submission|
      if submission.url == "" && submission.author_username != ""
        @submissions.push(submission)
      end
    end
    @shorturl = Array.new(0);
    @submissions.each do |submission|
      if submission.url != ""
        url =submission.url.split('//')
        shortu = url[1].split('/')
        @shorturl.push(shortu[0])
      else 
        @shorturl.push("")
      end
    end
  end
  

  # GET /submissions/1 or /submissions/1.json
  def show
  end

  # GET /submissions/new
  def new
    if !user_signed_in?
      respond_to do |format|
        format.html { redirect_to user_session_path}
      end
    else
      @submission = Submission.new
    end
  end

  # GET /submissions/1/edit
  def edit
  end
  
  def upvote
    if !user_signed_in?
      respond_to do |format|
        format.html { redirect_to user_session_path}
      end
    else
      @submission = Submission.find(params[:id])
      
      if current_user.LikedSubmissions.detect{|e| e == params[:id]}.nil?
        @submission.UpVotes = @submission.UpVotes + 1
        current_user.LikedSubmissions.push(params[:id])
        current_user.save
        
        respond_to do |format|
          if @submission.save
            format.html { redirect_to params[:url].to_s} #need a way to return to the previous page
          end
        end
      end
    end
  end
  
  def unvote
    if !user_signed_in?
      respond_to do |format|
        format.html { redirect_to user_session_path}
      end
    else
      @submission = Submission.find(params[:id])
      
      if !current_user.LikedSubmissions.detect{|e| e == params[:id]}.nil?
        @submission.UpVotes = @submission.UpVotes - 1
        current_user.LikedSubmissions.extract!{|e| e == params[:id]}
        current_user.save
  
        respond_to do |format|
          if @submission.save
            format.html { redirect_to params[:url].to_s} #need a way to return to the previous page
          end
        end
      end
    end
  end

  # POST /submissions or /submissions.json
  def create
    if Submission.find_by(url: submission_params[:url]).present? && submission_params[:url] != ""
      idurl = "/item?id="+Submission.find_by(url: submission_params[:url]).id.to_s
        respond_to do |format|
          format.html { redirect_to idurl, notice: "This URL allready exists" }
        end
    else 
      comment = Comment.new()
      if submission_params[:url] != "" && submission_params[:text] != ""
        comment.comment = submission_params[:text]
        comment.author = submission_params[:author_username]
        submission_params[:text] = ""
      end
      @submission = Submission.new(submission_params)
      logger.debug "\n\n\n#################\n" + submission_params.to_s
      
      respond_to do |format|
        if @submission.save
          if comment.author.present? && comment.author == submission_params[:author_username]
            comment.id_submission = @submission.id
            comment.save
          end
          format.html { redirect_to news_path}
        else
          format.html { render new_submission_path, status: :unprocessable_entity }
          format.json { render json: @submission.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /submissions/1 or /submissions/1.json
  def update
    respond_to do |format|
      if @submission.update(submission_params)
        format.html { redirect_to "/submissions/"+@submission.id.to_s+"/edit", notice: "Submission was successfully updated." }
        format.json { render :show, status: :ok, location: @submission }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @submission.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def upvoted
    if !params[:id].nil?
      @user_name = params[:id].to_s
      user = User.find_by(name: params[:id])
      
      if !user.nil? && !user.LikedSubmissions.nil?
        temp = Submission.where(id: user.LikedSubmissions)
        temp.order(created_at: :desc, title: :asc)
        
        @submission = Array.new(0)
        temp.each do |temp|
          if temp.author_username != ""
            @submission.push(temp)  
          end
        end
      end
      
      if !@submission.nil?
        @shorturl = Array.new(0);
        @submission.each do |submission|
          if submission.url != ""
            url =submission.url.split('//')
            shortu = url[1].split('/')
            @shorturl.push(shortu[0])
          else 
            @shorturl.push("")
          end
        end
      end
    end
  end
  
  def submitted
    if !params[:id].nil?
      @user_name = params[:id].to_s
      
      @submission = Submission.where(author_username: @user_name)
      @submission.order(created_at: :desc, title: :asc)
      
      if !@submission.nil?
        @shorturl = Array.new(0);
        @submission.each do |submission|
          if submission.url != ""
            url =submission.url.split('//')
            shortu = url[1].split('/')
            @shorturl.push(shortu[0])
          else 
            @shorturl.push("")
          end
        end
      end
    end
  end
  
  def item
    @submission = Submission.find_by(id: params[:id])
    
    @shorturl = Array.new(0);
    if @submission.url != ""
      url =@submission.url.split('//')
      shortu = url[1].split('/')
      @shorturl.push(shortu[0])
    else 
      @shorturl.push("")
    end
  end

  # DELETE /submissions/1 or /submissions/1.json
  def destroy
    @submission.destroy

    respond_to do |format|
      format.html { redirect_to submissions_url, notice: "Submission was successfully destroyed." }
      format.json { head :no_content }
    end
  end
  
  def soft_delete
    @submission = Submission.find(params[:id])
    if @submission.author_username == current_user.name
      @submission.title = "[deleted]"
      @submission.url = ""
      @submission.text = ""
      @submission.UpVotes = 0
      @submission.author_username = ""
      
      @submission.comments.each do |comment| ##<- delete all of them
        SoftDeleteComments.softDC(comment.id)
        ##comment.soft_delete ##this is a method inside comments_controller that does exactly the same as Submission.soft_delete
        ##@submission.comments.delete(comment) ##this removes the comment from has_many list of submisssion
      end
      
      respond_to do |format|
        if @submission.save
            format.html { redirect_to submissions_url, notice: "Submission was successfully destroyed." }
            format.json { head :no_content }
        else
          format.html { redirect_to submissions_url, notice: "There was some error ¯\_(ツ)_/¯." }
          format.json { head :no_content }
        end
      end
    end
  end
  
  def past
    data = Time.new()- (3600*24)
    if params[:day].present?
      arrayday = params[:day].split('-')
      data = Time.new(arrayday[0].to_i,arrayday[1].to_i,arrayday[2].to_i,23,59,59)
    end
    
    @shorturl = Array.new(0);
    @submissions = Array.new(0)
      subm = Submission.all.order(created_at: :desc, title: :asc)
      subm.each do |submission|
        
        if data>=submission.created_at && submission.author_username != ""
          @submissions.push(submission)
          if submission.url != "" 
            url =submission.url.split('//')
            shortu = url[1].split('/')
            @shorturl.push(shortu[0])
          else 
            @shorturl.push("")
          end
        end
      end
      url = "past?day="
      dataD = data - (3600*24)
      dataM = data - (3600*24*30)
      dataY = data - (3600*24*365)
      dataF = data + (3600*24)
      @date = data.strftime("%F")
      @dataToday = url+data.strftime("%F")
      @dataN = data.strftime("%B %d, %Y (%Z)")
      @dataD = url+dataD.strftime("%F")
      @dataM = url+dataM.strftime("%F")
      @dataY = url+dataY.strftime("%F")
      @dataF = url+dataF.strftime("%F")
      
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_submission
      @submission = Submission.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def submission_params
      params.require(:submission).permit(:title, :url, :text, :UpVotes, :author_username)
    end
end
