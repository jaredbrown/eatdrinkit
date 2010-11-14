class DealsController < ApplicationController
  layout 'default'
  
  # GET /deals
  def index
    @deals = Deal.find_all_by_venue_id(params[:venue_id])
    
    respond_to do |format|
      format.html # index.html.erb
    end
  end
end