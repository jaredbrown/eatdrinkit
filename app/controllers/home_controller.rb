class HomeController < ApplicationController
  before_filter :login_required
  layout 'default'
  
  # GET /home
  # GET /home.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => '' }
    end
  end
end