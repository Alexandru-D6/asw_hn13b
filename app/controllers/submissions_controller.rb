class SubmissionsController < ApplicationController
  before_action :set_submission, only: %i[ show edit update destroy ]

  # GET /submissions or /submissions.json
  def index
    if params[:newest]
       @submissions = Submission.all.order(created_at: :desc, title: :asc)
    else
      @submissions = Submission.all.order(UpVotes: :desc, title: :asc)
    end
  end
  
  def ask
    subm = Submission.all.order(created_at: :desc, title: :asc)
    @submissions = Array.new()
    subm.each do |submission|
      if submission.url == ""
        @submissions.push(submission)
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
            format.html { redirect_to news_path} #need a way to return to the previous page
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
            format.html { redirect_to news_path} #need a way to return to the previous page
          end
        end
      end
    end
  end

  # POST /submissions or /submissions.json
  def create
    if Submission.find_by(url: submission_params[:url]).present? && submission_params[:url] != ""
        respond_to do |format|
          format.html { redirect_to "/past", notice: "This URL allready exists" }
        end
    else 
      @submission = Submission.new(submission_params)
      logger.debug "\n\n\n#################\n" + submission_params.to_s
      
      respond_to do |format|
        if @submission.save
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
        format.html { redirect_to submission_url(@submission), notice: "Submission was successfully updated." }
        format.json { render :show, status: :ok, location: @submission }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @submission.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def item
    @submission = Submission.where(id: params[:id])
    p @submission

  end

  # DELETE /submissions/1 or /submissions/1.json
  def destroy
    @submission.destroy

    respond_to do |format|
      format.html { redirect_to submissions_url, notice: "Submission was successfully destroyed." }
      format.json { head :no_content }
    end
  end
  
  def past
    data = Time.new()
    if params[:day].present?
      arrayday = params[:day].split('-')
      data = Time.new(arrayday[0].to_i,arrayday[1].to_i,arrayday[2].to_i)
    end
    @submissions = Array.new()
      subm = Submission.all.order(created_at: :desc, title: :asc)
      subm.each do |submission|
        if data.year > submission.created_at.year
          @submissions.push(submission)
        else
          if data.year == submission.created_at.year &&  data.month > submission.created_at.month
            @submissions.push(submission)
          else
            if data.year == submission.created_at.year &&  data.month == submission.created_at.month && data.day > submission.created_at.day
              @submissions.push(submission)
            end
          end
        end
      end
      url = "past?day="
      dataD = data - (3600*24)
      dataM = data - (3600*24*30)
      dataY = data - (3600*24*365)
      dataF = data + (3600*24)
      @date = data.strftime("%F")
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
