class ReviewsController < ApplicationController
  #before_filter :login_required
  layout 'default'
  
  # GET /reviews/1
  def show    
    @review = Review.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
    end
  end
end