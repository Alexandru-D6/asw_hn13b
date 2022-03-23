module ApplicationHelper
  def active_class(path)
    if request.path == path
      return path
    else 
      return ''
    end 
  end 
end
