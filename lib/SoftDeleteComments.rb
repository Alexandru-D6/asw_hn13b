module SoftDeleteComments
  def SoftDeleteComments.softDC(id)
    comment = Comment.find(id)
    if comment.author != ""
      comment.comment = "[deleted]"
      comment.author = ""
      comment.id_sons = []
      comment.UpVotes = 0
      
      comment.title_submission = ""
      comment.num_sons = 0
      
      if comment.comments.nil?
        comment.comments.each do |comment_son| ##<- delete all of them
          SoftDeleteComments.softDC(comment_son.id)
          #comment_son.soft_delete ##this is a method inside comments_controller that does exactly the same as Submission.soft_delete
          #@comment.comments.delete(comment_son) ##this removes the comment from has_many list of submisssion
        end
      end
    end
  end
  
end