class AdminController < ApplicationController

  layout 'admin'

  def index

    if !is_logged_in
      redirect_to(:action => 'login')
    end

    @is_index_page = 'class=current_page_item'

  end

  def login
    #doesnt render the admin layout
    render :layout => false
  end

  def attempt_login
    if params[:name].present? && params[:password].present?
      if params[:name] == ENV["SITE_ADMIN_USERNAME"] && params[:password] == ENV["SITE_ADMIN_PASSWORD"]

        #mark admin as logged in and redirect to index
        session[:admin_id] = params[:name]
        flash[:notice] = "Successfully logged in."
        redirect_to(:action => 'index')
        return
      end
    end

    #invalid login
    flash[:notice] = "Invalid name/password combination."
    redirect_to(:action => 'login')
  end

  def logout

    #mark admin as logged out
    session[:admin_id] = nil

    reset_session
    #redirect to login page
    flash[:notice] = "Logged out"
    redirect_to(:action => "login")
  end

  private

  #def set_selected_menu
  #  @is_schedule_page = 'class=current_page_item'
  #end

  def is_logged_in

    if session[:admin_id]
      return true
    else
      return false
    end

  end
end
