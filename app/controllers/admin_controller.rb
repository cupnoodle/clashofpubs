class AdminController < ApplicationController

  layout 'admin'

  before_filter :is_logged_in, :except => [:login, :attempt_login, :logout]

  def index

    @is_index_page = 'class=current_page_item'

  end


  def schedule

    @is_schedule_page = 'class=current_page_item'

    #player variable
    #@the_player = Player.find(session[:player_id])

    #first round
    @first_round_matches = Matching.where(:id => 1..16).order('id ASC')

    #second round
    @second_round_matches = Matching.where(:id => 17..24).order('id ASC')

    #third_round
    @third_round_matches = Matching.where(:id => 25..28).order('id ASC')

    #fourth round
    @fourth_round_matches = Matching.where(:id => 29..30).order('id ASC')

    #fifth round
    @fifth_round_matches = Matching.where(:id => 31)

    #winner
    @winner = Matching.where(:id => 32).first

    #option for match select
    @match_select_array = Array.new
    (1..31).each do |i|
      @match_select_array << [i.to_s, i]
    end

    #option for team select
    @team_select_array = Player.order(:team_name).pluck(:team_name, :id)
    #insert blank option to the first index
    @team_select_array.insert(0, ["" , ""])

  end

  def update_match

    #if no these input parameter return false
    if !params.has_key?(:match_id) || !params.has_key?(:match_top_player_id) || !params.has_key?(:match_bottom_player_id)
      flash[:notice] = "Insufficient parameters input (match id/top player/bottom player)"
      redirect_to(:action => "schedule")
      return
    end

    #find the match based on match id
    match = Matching.where(:id => params[:match_id].to_i).first
    
    #if cant find the match
    if match.nil?
      flash[:notice] = "Invalid match input"
      redirect_to(:action => "schedule")
      return
    end


    if !params[:match_top_player_id].blank?
      top_player = Player.where(:id => params[:match_top_player_id].to_i).first
    else
      top_player = nil
    end

    if !params[:match_bottom_player_id].blank?
      bottom_player = Player.where(:id => params[:match_bottom_player_id].to_i).first
    else
      bottom_player = nil
    end

    #if can't find the players
    #if top_player.nil? || bottom_player.nil?
    #  flash[:notice] = "Invalid player input"
    #  redirect_to(:action => "schedule")
    #  return
    #end

    #if both player is the same player, provided both of them is not nil
    if !top_player.nil? && !bottom_player.nil?
      if top_player.id == bottom_player.id
        flash[:notice] = "Top and bottom player cannot be the same"
        redirect_to(:action => "schedule")
        return
      end
    end

    #update the match with new players and time (if time is not blank)
    if !top_player.nil?
      match.top_player_id = top_player.id
    else
      match.top_player_id = top_player
    end

    if !bottom_player.nil?
      match.bottom_player_id = bottom_player.id
    else
      match.bottom_player_id = bottom_player
    end

    #see if admin got input match time or not
    match_time = ""

    begin
    #eg :2015-10-10 12:00 am
    match_time = DateTime.strptime(params[:datetime], '%Y-%m-%d %H:%M %P')
    #in case of invalid datetime format supplied
    rescue
      match_time = ""
    end
    
    if !match_time.blank?
      match.agreed_datetime = match_time
    end


    #redirect after save
    if match.save
      flash[:notice] = "Round" + match.id.to_s + " information successfully updated"
      redirect_to(:action => "schedule")
      return
    else
      flash[:notice] = "Error updating match information."
      redirect_to(:action => "schedule")
      return
    end

  end

  #show winner
  def winner
    @is_winner_page = 'class=current_page_item'

    winner_match = Matching.where(:id => 32).first
    @winner = nil
    @winner = Player.find(winner_match.top_player_id) unless winner_match.top_player_id.nil?
    #option for team select
    @team_select_array = Player.order(:team_name).pluck(:team_name, :id)
    #insert blank option to the first index
    @team_select_array.insert(0, ["" , ""])
  end

  def update_winner

    #if no these input parameter return false
    if !params.has_key?(:winner_id)
      flash[:notice] = "Insufficient parameters input (winner_id)"
      redirect_to(:action => "winner")
      return
    end

    #blank input means no winner
    #set winner match to nil
    if params[:winner_id].blank?
      winner_match = Matching.where(:id => 32).first
      winner_match.top_player_id = nil
      winner_match.bottom_player_id = nil
      winner_match.save

      flash[:notice] = "Winner updated successfully."
      redirect_to(:action => "winner")
      return
    end

    winner = Player.where(:id => params[:winner_id].to_i).first

    #if winner is not blank

    if winner
      winner_match = Matching.where(:id => 32).first
      winner_match.top_player_id = winner.id
      winner_match.bottom_player_id = winner.id
      winner_match.save

      flash[:notice] = "Winner updated successfully."
      redirect_to(:action => "winner")
      return
    end

    flash[:notice] = "Error updating winner, possibly invalid team selected."
    redirect_to(:action => "winner")
    return

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
      redirect_to(:action => 'login')
      return false
    end

  end
end
