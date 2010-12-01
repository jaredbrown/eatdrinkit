# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def truncate_by_word(text, wordcount)
    if text and !text.empty?
      text.split[0..(wordcount-1)].join(" ") + (text.split.size > wordcount ? "..." : "")
    else
      text
    end
  end
  
  # Produces -> Thursday 25 May 2006 - 1:08 PM
  def fancy_date(date)
    h date.strftime("%A, %B %d, %Y")
  end
  
  def current_user?(id)
    !session[:current_user].nil? and session[:current_user].id.to_s == id
  end
end