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

  def team
    @is_team_page = 'class=current_page_item'

    #option for team select (for delete purpose)
    @team_select_array = Player.order(:team_name).pluck(:team_name, :id)

    #contain full team information
    @team_full_array = Player.order(:team_name).pluck_to_hash(:name, :team_name, :steam_id, :email, :mmr, :id)

    #insert blank option to the first index
    #@team_select_array.insert(0, ["" , ""])

  end

  def delete_team
    #if no these input parameter return false
    if !params.has_key?(:team_id)
      flash[:notice] = "Insufficient parameters input (team_id)"
      redirect_to(:action => "team")
      return
    end

    delete_team = Player.where(:id => params[:team_id].to_i).first

    #if team not found
    if !delete_team
      flash[:notice] = "Can't find the specified team"
      redirect_to(:action => "team")
      return
    end

    #delete team and set related match time to null
    team_name = delete_team.team_name
    related_top_matches = Matching.where(:top_player_id => delete_team.id)
    related_bottom_matches = Matching.where(:bottom_player_id => delete_team.id)

    if !related_top_matches.blank?
      related_top_matches.each do |top_match|
        top_match.top_datetime = nil
        top_match.agreed_datetime = nil
        top_match.save
      end
    end

    if !related_bottom_matches.blank?
      related_bottom_matches.each do |bottom_match|
        bottom_match.bottom_datetime = nil
        bottom_match.agreed_datetime = nil
        bottom_match.save
      end
    end

    #send email to the team to notify that the team has been deleted
    mail_title = "Your team has been removed from the tournament"
    mail_body = "Hi " + delete_team.team_name + ", \n\n" + 
                "We are sorry to inform you that your team has been removed from the tournament because we have found that you violated the tournament rules. \n\n " +
                "Please contact the administrator if you have any question regarding this decision. " + 
                " \n\n  Please do not reply to this email, this email is sent by a mail bot from Clash Of Pubs."

    send_mail_to_opponent(mail_title, mail_body, delete_team.email)

    delete_team.destroy

    flash[:notice] = "Team " + team_name + " has been deleted"
    redirect_to(:action => "team")

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

  def send_mail_to_opponent (title, content, opponent_email)
    # First, instantiate the Mailgun Client with your API key
    mg_client = Mailgun::Client.new ENV["MAILGUN_API_KEY"]
    
    # Define your message parameters
    message_params = {:from    => ENV["MAILGUN_SENDER"],
                      :to      => opponent_email,
                      :subject => title,
                      :text    => content}
    
    # Send your message through the client
    mg_client.send_message ENV["MAILGUN_DOMAIN"], message_params
  end

end
