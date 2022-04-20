require 'SoftDeleteComments'

class CommentsController < ApplicationController
  before_action :set_comment, only: %i[ show edit update destroy ]

  # GET /comments or /comments.json
  def index
    com = Comment.all.order(created_at: :desc, comment: :asc)
    @comments= Array.new(0)
    @titles_submissions = Array.new(0)
    com.each do |comment|
      if comment.author != ""
        @comments.push(comment)
        submission = Submission.find(comment.id_submission)
        @titles_submissions.push(submission.title)
      end
    end
  end
  
  def threads
    temp = Comment.where(author: params[:id]).order(created_at: :desc, comment: :asc)
    
    @comments = Array.new(0)
    temp.each do |com|
      if com.author != ""
        @comments.push(com)
      end
    end
    
    @titles_submissions = Array.new(0)
    @comments.each do |comment|
        submission = Submission.find(comment.id_submission)
        @titles_submissions.push(submission.title)
    end
  end

  # GET /comments/1 or /comments/1.json
  def show
  end

  # GET /comments/new
  def new
    @comment = Comment.new
  end

  # GET /comments/1/edit
  def edit
  end
  
  def upvote
    if !user_signed_in?
      respond_to do |format|
        format.html { redirect_to user_session_path}
      end
    else
      @comment = Comment.find(params[:id])
      
      if current_user.LikedComments.detect{|e| e == params[:id]}.nil?
        @comment.UpVotes = @comment.UpVotes + 1
        current_user.LikedComments.push(params[:id])
        current_user.save
        
        respond_to do |format|
          if @comment.save
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
      @comment = Comment.find(params[:id])
      
      if !current_user.LikedComments.detect{|e| e == params[:id]}.nil?
        @comment.UpVotes = @comment.UpVotes - 1
        current_user.LikedComments.extract!{|e| e == params[:id]}
        current_user.save
  
        respond_to do |format|
          if @comment.save
            format.html { redirect_to params[:url].to_s} #need a way to return to the previous page
          end
        end
      end
    end
  end
  
  def reply
    @return_URL = params[:url]
    @comments = Comment.where(id: params[:id])
    @title_submission = ""
    @comments.each do |comment|
      submission = Submission.find(comment.id_submission)
      @title_submission = submission.title
    end
  end
  
  def comments
    
    @comments = Comment.all.order(created_at: :desc, comment: :asc)
    @titles_submissions = Array.new(0)
    @comments.each do |comment|
      submission = Submission.find(comment.id_submission)
      @titles_submissions.push(submission.title)
    end
  end
  
  def delete
    @comment = Comment.find(params[:id])
    submission = Submission.find(@comment.id_submission)
    @title_submission = submission.title
  end
  
  
  def deleted_comment
    @comment = Comment.find(params[:id])
    @comment.comment ="[deleted]"
    @comment.author = ""
    if @comment.save
        redirect_to "/reply?id="+@comment.id.to_s
    end
  end
  
 def upvoted
    if !params[:id].nil?
      @user_name = params[:id].to_s
      user = User.find_by(name: params[:id])
      
      if !user.nil? && !user.LikedComments.nil?
        temp = Comment.where(id: user.LikedComments)
        temp.order(created_at: :desc, title: :asc)
        
        @comment = Array.new(0)
        temp.each do |temp|
          if temp.author != ""
            temp.title_submission = Submission.find(temp.id_submission).title
            @comment.push(temp)  
          end
        end
      end
    end
 end
  
  
  # POST /comments or /comments.json
  def create
    @comment = Comment.new(comment_params)
    @comment.author = current_user.name
      
    if comment_params[:id_comment_father].nil?
      submission = Submission.find(@comment.id_submission)
      
      if submission.comments.nil? 
        submission.comments = Array.new(1)  
      end
      
      submission.comments.push(@comment)
      submission.save
    else
      comment_father = Comment.find(comment_params[:id_comment_father])
      
      if comment_father.comments.nil? 
        comment_father.comments = Array.new(1)  
      end
      
      comment_father.comments.push(@comment)
      comment_father.save
    end
    
    
    respond_to do |format|
      if @comment.save
        format.html { redirect_to "/item?id="+comment_params[:id_submission].to_s, notice: "Comment was successfully created." }
        format.json { render :show, status: :created, location: @comment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comments/1 or /comments/1.json
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        url = "/comments/"+@comment.id.to_s+"/edit"
        format.html { redirect_to url, notice: "Comment was successfully updated." }
        format.json { render :show, status: :ok, location: @comment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1 or /comments/1.json
  def destroy
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to comments_url, notice: "Comment was successfully destroyed." }
      format.json { head :no_content }
    end
  end
  
  def soft_delete
    comment = Comment.find(params[:id])
    id = comment.id
    if comment.author != ""
      comment.comment = "[deleted]"
      comment.author = ""
      comment.id_sons = []
      comment.UpVotes = 0
      
      comment.title_submission = ""
      comment.num_sons = 0
      
      if !comment.comments.nill?
        comment.comments.each do |comment_son| ##<- delete all of them
          SoftDeleteComments.softDC(comment_son.id)
          #comment_son.soft_delete ##this is a method inside comments_controller that does exactly the same as Submission.soft_delete
          #@comment.comments.delete(comment_son) ##this removes the comment from has_many list of submisssion
        end
      end
      
      respond_to do |format|
        if comment.save
            format.html { redirect_to "/reply?id="+id.to_s, notice: "Submission was successfully destroyed." }
            format.json { head :no_content }
        else
          format.html { redirect_to "/news", notice: "There was some error ¯\_(ツ)_/¯." }
          format.json { head :no_content }
        end
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
      submission = Submission.find(@comment.id_submission)
      @title_submission = submission.title
    end

    # Only allow a list of trusted parameters through.
    def comment_params
      params.require(:comment).permit(:author, :comment, :UpVotes, :id_submission, :id_comment_father)
    end
end
