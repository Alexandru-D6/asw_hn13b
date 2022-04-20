module SoftDeleteComments
  def softDC(id)
    @comment = Comment.find(id)
    if @comment.author != ""
      @comment.comment = "[deleted]"
      @comment.author = ""
      @comment.id_sons = []
      @comment.UpVotes = 0
      
      @comment.title_submission = ""
      @comment.num_sons = 0
      
      @comment.comments.each do |comment_son| ##<- delete all of them
        #self.softDC(id: comment_son.id)
        #comment_son.soft_delete ##this is a method inside comments_controller that does exactly the same as Submission.soft_delete
        #@comment.comments.delete(comment_son) ##this removes the comment from has_many list of submisssion
      end
      
      if @comment.save
        respond_to do |format|
          format.html { redirect_to submissions_url, notice: "Submission was successfully destroyed." }
          format.json { head :no_content }
        end
      else
        format.html { redirect_to submissions_url, notice: "There was some error ¯\_(ツ)_/¯." }
        format.json { head :no_content }
      end
    end
  end
  
end