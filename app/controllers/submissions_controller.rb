require 'SoftDeleteComments'

class SubmissionsController < ApplicationController
  before_action :set_submission, only: %i[ show edit update destroy ]
  skip_before_action :verify_authenticity_token

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
        current_user.LikedSubmissions.push(params[:id].to_s)
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
    if !user_signed_in?
      respond_to do |format|
        format.html { redirect_to user_session_path}
      end
    else
      if Submission.find_by(url: submission_params[:url]).present? && submission_params[:url] != ""
        idurl = "/item?id="+Submission.find_by(url: submission_params[:url]).id.to_s
          respond_to do |format|
            format.html { redirect_to idurl, notice: "This URL allready exists" }
          end
      else 
        comment = Comment.new()
        if submission_params[:url] != "" && submission_params[:text] != ""
          logger.debug "\n\n\n#################\n"
          comment.comment = submission_params[:text]
          comment.author = submission_params[:author_username]
          submission_params[:text] = nil
        end
        @submission = Submission.new(submission_params)
        logger.debug "\n\n\n#################\n" + submission_params.to_s
        
        respond_to do |format|
          if @submission.save
            if comment.author.present? && comment.author == submission_params[:author_username]
              comment.id_submission = @submission.id
              comment.save
              
              @submission.comments.push(comment)
              @submission.text = ""
              @submission.save
            end
            format.html { redirect_to news_path}
          else
            format.html { render new_submission_path, status: :unprocessable_entity }
            format.json { render json: @submission.errors, status: :unprocessable_entity }
          end
        end
      end
    end
  end

  # PATCH/PUT /submissions/1 or /submissions/1.json
  def update
    if !user_signed_in?
      respond_to do |format|
        format.html { redirect_to user_session_path}
      end
    else
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
  end
  
  def upvoted
    if !user_signed_in?
      respond_to do |format|
        format.html { redirect_to user_session_path}
      end
    else
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
    if !user_signed_in?
      respond_to do |format|
        format.html { redirect_to user_session_path}
      end
    else
      @submission.destroy
  
      respond_to do |format|
        format.html { redirect_to submissions_url, notice: "Submission was successfully destroyed." }
        format.json { head :no_content }
      end
    end
  end
  
  def soft_delete
    if !user_signed_in?
      respond_to do |format|
        format.html { redirect_to user_session_path}
      end
    else
      @submission = Submission.find(params[:id])
      if @submission.author_username == current_user.name
        @submission.title = "[deleted]"
        @submission.url = ""
        @submission.text = ""
        @submission.UpVotes = 0
        @submission.author_username = ""
        
        if !@submission.comments.nil?
          @submission.comments.each do |comment| ##<- delete all of them
            SoftDeleteComments.softDC(comment.id)
            ##comment.soft_delete ##this is a method inside comments_controller that does exactly the same as Submission.soft_delete
            ##@submission.comments.delete(comment) ##this removes the comment from has_many list of submisssion
          end
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
  
  ###############
  ##           ##
  ##           ##
  ##    API    ##
  ##           ##
  ##           ##
  ###############
  
  def news_api
    temp = Submission.all.order(UpVotes: :desc, title: :asc)
    
    @submissions = Array.new(0)
    temp.each do |temp|
      if temp.author_username != ""
        @submissions.push(temp)  
      end
    end
    
    @shorturl = Array.new(0)
    temp = Array.new(0)
    @submissions.each do |submission|
      temp.push(submission.as_json.except("updated_at"))
      if submission.url != ""
        url =submission.url.split('//')
        shortu = url[1].split('/')
        @shorturl.push(shortu[0])
      else 
        @shorturl.push("")
      end
    end
    render json: {status: 200, submissions: temp, short_url: @shorturl}, status: 200
  end


  def newest_api
    temp = Submission.all.order(created_at: :desc, title: :asc)
    
    @submissions = Array.new(0)
    temp.each do |temp|
      if temp.author_username != ""
        @submissions.push(temp)  
      end
    end
    
    temp = Array.new(0)
    @shorturl = Array.new(0);
    @submissions.each do |submission|
      temp.push(submission.as_json.except("updated_at"))
      if submission.url != ""
        url =submission.url.split('//')
        shortu = url[1].split('/')
        @shorturl.push(shortu[0])
      else 
        @shorturl.push("")
      end
    end
    
    render json: {submissions: temp, shorturl: @shorturl}, status: 200
  end
  
  
  def ask_api
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
    temp = Array.new(0)
    @submissions.each do |submission|
      temp.push(submission.as_json.except("updated_at"))
    end
    render json: {status: 200, submissions: temp, shorturl: @shorturl}, status: 200
  end
  
  
  def create_api
    if request.headers["x-api-key"].nil?
      render json: {status: 401, error: "Unauthorized", message: "API key not found"}, status: 401
      return
    end
    user = User.find_by(auth_token: request.headers["x-api-key"])
    if user.nil?
      render json: {status: 403, error: "Forbidden", message: "User not found"}, status: 403
      return
    end
    if params[:url].nil? && params[:text].nil?
      render json: {status: 400, error: "Bad Request", message: "Field url and text not found"}, status: 400
      return
    end
    if !params[:url].nil? && params[:url] == "" && !params[:text].nil? && params[:text] == ""
      render json: {status: 400, error: "Bad Request", message: "You need to fill some field"}, status: 400
      return
    end
    if !params[:url].nil? &&  params[:url] == "" && params[:text].nil? 
      render json: {status: 400, error: "Bad Request", message: "You need to introduce the url"}, status: 400
      return
    end
    if !params[:text].nil? && params[:text] == "" && params[:url].nil? 
      render json: {status: 400, error: "Bad Request", message: "You need to introduce the text"}, status: 400
      return
    end
    if !Submission.find_by(url: params[:url]).nil? && params[:url] != ""
      render json: {status: 400, error: "Bad Request", message: "There is a submission with the entered url"}, status: 400
      return
    end
    comment = Comment.new()
    if !params[:url].nil? && params[:url] != "" && params[:text] != ""
      comment.comment = params[:text]
      comment.author = User.find_by(auth_token: request.headers["x-api-key"]).name
      params[:text] = nil
    end
    if (!params[:text].nil? && params[:url].nil?)
      @submission = Submission.new(title: params["title"], url: "", text: params["text"], author_username: User.find_by(auth_token: request.headers["x-api-key"]).name)
    else
      @submission = Submission.new(title: params["title"], url: params["url"], text: "", author_username: User.find_by(auth_token: request.headers["x-api-key"]).name)
    end
    if @submission.save
      if !comment.author.nil? && comment.author == User.find_by(auth_token: request.headers["x-api-key"]).name
        comment.id_submission = @submission.id
        comment.save
        
        @submission.comments.push(comment)
        @submission.text = ""
        @submission.save
      end
      temp = @submission.as_json.except("updated_at")
       render json: {status: 201, message: "Submission with id: " + @submission.id.to_s + " was successfully created.", submission: temp}, status: 201
    else
      render json: {status: 400, error: "Bad Request", message: @submission.errors.first.full_message}, status: 400
    end
  end
  
  def submitted_api
    if params[:name].nil?
      render json:{status: 400, error: "Bad Request", message: "Insuficient parameters, you need to add the name of the user"}, status: 400
    else
      if User.find_by(name: params[:name]).nil?
        render json:{status: 404, error: "Not Found", message: "The user with the id:"+ params[:name]+" not found"}, status: 404
      else
        @user_name = params[:name].to_s
        @submission = Submission.where(author_username: @user_name)
        @submission.order(created_at: :desc, title: :asc)
        temp = Array.new(0)
        if !@submission.nil?
          @shorturl = Array.new(0);
          @submission.each do |submission|
            temp.push(submission.as_json.except("updated_at"))
            if submission.url != ""
              url =submission.url.split('//')
              shortu = url[1].split('/')
              @shorturl.push(shortu[0])
            else 
              @shorturl.push("")
            end
          end
        end
        render json:{status: 200, submissions: temp, short_url: @shorturl}, status: 200
      end
    end
  end
  
  
  def upvoted_api
    if request.headers["x-api-key"].nil?
      render json:{status: 401, error: "Unauthorized", message: "Header api key not found" }, status: 401
    else
      if User.find_by(auth_token: request.headers["x-api-key"]).nil?
         render json:{status: 403, error: "Forbidden", message: "The user with the api key:" + request.headers["x-api-key"] + " not found"}, status: 403
      else
        user = User.find_by(auth_token: request.headers["x-api-key"])
        
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
        
        temp = Array.new(0)
        
        @submission.each do |aaaa|
          temp.push(aaaa.as_json.except("updated_at"))
        end
        render json: {status: 200, submissions: temp, short_url: @short_url}, status: 200
        return
      end
      
      render json: {error: "There isn't any id as paramater"}, status: 401
      return
    end
  end
  
  def getCommentsTree(a)
    temp = [];
    
    a.comments.each do |c|
      temp2 = c
      if temp2.author != ""
        temp.push(temp2.as_json.merge(comments: getCommentsTree(c)).except("submission_id", "comment_id", "updated_at"))
      end
    end
    
    return temp;
  end
  
  def find_submission_api 
    if params[:id].nil?
      render json: {status: 400, error: "Bad request", message: "Insuficient parameters, missing submission ID"}, status: 400
      return
    else 
      submissionID = params[:id]
      @submission = Submission.find_by(id: submissionID)
      if @submission.nil?
        render json: {status: 404, error: "Not found", message: "The submission doesn't exist in the data base"}, status: 404
        return
      
      else 
        @shorturl = Array.new(0);
        if @submission.url != ""
          url =@submission.url.split('//')
          shortu = url[1].split('/')
          @shorturl.push(shortu[0])
        else 
          @shorturl.push("")
        end
        
        temp = Array.new(0)
        
        @submission.comments.each do |comm|
          if (comm.author != "")
            temp.push(comm.as_json.merge({comments: getCommentsTree(comm)}).except("submission_id", "comment_id", "updated_at"))
          end
        end
        
        render json: {staus: 200, submission: @submission.as_json.except("updated_api"), comments: temp}, status: 200
      end 
    end
  end
  
  def update_api
    if request.headers["x-api-key"].nil?
      render json:{status: 401, error: "Unauthorized", message: "Header api key not found" }, status: 401
      return
    end
    if params[:id].nil?
      render json:{status: 400, error: "Bad Request", message: "Insuficient parameters, parameter id not found"}, status: 400
      return
    end
    if User.find_by(auth_token: request.headers["x-api-key"]).nil?
      render json:{status: 403, error: "Forbidden", message: "User with the api key "+ request.headers["x-api-key"] + " not found"}, status: 403
      return
    end
    if Submission.find_by(id: params[:id]).nil?
      render json:{status: 404, error: "Not Found", message: "Submission with the id: "+params[:id]+" not found"}, status: 404
      return
    end
    if  Submission.find_by(id: params[:id]).author_username != User.find_by(auth_token: request.headers["x-api-key"]).name
      render json:{status: 400, error: "Bad Request", message: "You are not the author of the submission " + params[:id]}, status: 400
      return
    end
    if Submission.find_by(id: params[:id]).url == "" && params[:title].nil? && params[:text].nil?
      render json:{status: 400, error: "Bad Request", message: "Insuficient parameters, parameter title and text not found"},status: 400
      return
    end
    if Submission.find_by(id: params[:id]).url != "" && params[:title].nil?
      render json:{status: 400, error: "Bad Request", message: "Insuficient parameters, parameter title not found"}, status: 400
      return
    end
    if Submission.find_by(id: params[:id]).url != "" && !params[:text].nil?
      render json:{status: 400, error: "Bad Request", message: "Parameter text found, tryning to edit a submission of type url"}, status: 400
      return
    end
    @submission = Submission.find_by(id: params[:id])
    titol = @submission.title
    updatetext = @submission.text
    if !params[:title].nil?
      titol = params[:title]
    end
    if !params[:text].nil?
      updatetext = params[:text]
    end
    if @submission.update(title: titol, text: updatetext)
      render json:{status:203, message: "Submission edited", submission: @submission.as_json.except("updated_at")}, status: 203
    else
      render json:{status: 400, error: "Bad Request", message: @submission.errors.first.full_message}, staus: 400
    end
  end
  
  def delete_api
    if request.headers["x-api-key"].nil?
      render json:{status: 401, error: "Unauthorized", message: "Header api key not found" }, status: 401
      return
    end
    if params[:id].nil?
      render json:{status: 400, error: "Bad Request", message: "Insuficient parameters, parameter id not found"}, status: 400
      return
    end
    if User.find_by(auth_token: request.headers["x-api-key"]).nil?
      render json:{status: 403, error: "Forbidden", message: "User with the api key "+ request.headers["x-api-key"] + " not found"}, status: 403
      return
    end
    if Submission.find_by(id: params[:id]).nil?
      render json:{status: 404, error: "Not found", message: "Submission with the id: "+params[:id]+" not found"}, status: 404
      return
    end
    if  Submission.find_by(id: params[:id]).author_username != User.find_by(auth_token: request.headers["x-api-key"]).name
      render json:{status: 403, error: "Forbidden", message: "You are not the author of the submission " + params[:id]}, status: 403
      return
    end
    @submission = Submission.find(params[:id])
    @submission.title = "[deleted]"
    @submission.url = ""
    @submission.text = ""
    @submission.UpVotes = 0
    @submission.author_username = ""
    
    if !@submission.comments.nil?
      @submission.comments.each do |comment| ##<- delete all of them
        SoftDeleteComments.softDC(comment.id)
        ##comment.soft_delete ##this is a method inside comments_controller that does exactly the same as Submission.soft_delete
        ##@submission.comments.delete(comment) ##this removes the comment from has_many list of submisssion
      end
    end
    if @submission.save
        render json:{status: 202, message: "Submission wiht the id:"+ params[:id]+" was successfully deleted"}, staus: 202
    else
      render json:{status: 400, error: "Bad Request", message: @submission.errors.first.full_message}, staus: 400
    end
  end
  
  def upvote_api
    if request.headers["x-api-key"].nil?
      render json:{status: 401, error: "Unauthorized", message: "Insuficient parameters, header api key not found" }, status: 401
      return
    end
    if params[:id].nil?
      render json:{status: 400, error: "Bad Request", message: "Insuficient parameters, parameter id not found"}, status: 400
      return
    end
    if User.find_by(auth_token: request.headers["x-api-key"]).nil?
      render json:{status: 403, error: "Forbidden", message: "User with the api key "+ request.headers["x-api-key"] + " not found"}, status: 403
      return
    end
    if Submission.find_by(id: params[:id]).nil?
      render json:{status: 404, error: "Not found", message: "Submission with the id: "+params[:id]+" not found"}, status: 404
      return
    end
    if  Submission.find_by(id: params[:id]).author_username == User.find_by(auth_token: request.headers["x-api-key"]).name
      render json:{status: 403, error: "Forbidden", message: "You are the author of the submission " + params[:id]+ ", then you can't upvote it"}, status: 403
      return
    end
    if  Submission.find_by(id: params[:id]).author_username == ""
      render json:{status: 400, error: "Bad Request", message: "You can't vote a submission that is deleted"}, status: 400
      return
    end
    user = User.find_by(auth_token: request.headers["x-api-key"])
    @submission = Submission.find(params[:id])
    if user.LikedSubmissions.detect{|e| e == params[:id]}.nil?
      @submission.UpVotes = @submission.UpVotes + 1
      user.LikedSubmissions.push(params[:id].to_s)
      user.save
      if @submission.save
        render json:{status: 203, message: "Submission upvoted", submission: @submission.as_json.except("updated_at")}, staus: 203
      else 
        render json:{status: 400, error: "Bad Request", message: @submission.errors.first.full_message}, staus: 410
      end
    else 
      render json:{status: 400, error: "Bad Request", message: "You have already vote this submission"}, staus: 400
    end
  end
  
  def unvote_api
    if request.headers["x-api-key"].nil?
      render json:{status: 401, error: "Unauthorized", message: "Insuficient parameters, header api key not found" }, status: 401
      return
    end
    if params[:id].nil?
      render json:{status: 400, error: "Bad Request", message: "Insuficient parameters, parameter id not found"}, status: 400
      return
    end
    if User.find_by(auth_token: request.headers["x-api-key"]).nil?
      render json:{status:403, error: "Forbidden", message: "User with the api key "+ request.headers["x-api-key"] + " not found"}, status: 403
      return
    end
    if Submission.find_by(id: params[:id]).nil?
      render json:{status: 404, error: "Not found", message: "Submission with the id: "+params[:id]+" not found"}, status: 404
      return
    end
    if  Submission.find_by(id: params[:id]).author_username == User.find_by(auth_token: request.headers["x-api-key"]).name
      render json:{status: 403, error: "Forbidden" ,message: "You are the author of the submission " + params[:id] + ", then you can't unvote it"}, status: 403
      return
    end
    if  Submission.find_by(id: params[:id]).author_username == ""
      render json:{status: 400, error: "Submission Deleted", message: "You can't unvote a submission that is deleted"}, status: 400
      return
    end
    @submission = Submission.find(params[:id])
    user = User.find_by(auth_token: request.headers["x-api-key"])
    if !user.LikedSubmissions.detect{|e| e == params[:id]}.nil?
      @submission.UpVotes = @submission.UpVotes - 1
      user.LikedSubmissions.extract!{|e| e == params[:id]}
      user.save
      if @submission.save
        render json:{status: 203, message: "Submission unvoted", submission: @submission.as_json.except("updated_at")}, staus: 203
      else
        render json:{status: 400, error: "Bad Request", message: @submission.errors.first.full_message}, staus: 400
      end
    else
      render json:{staus: 400, error: "Bad Request" , message: "You don't have vote this submission"}, staus: 400
    end
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