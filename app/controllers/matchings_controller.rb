class MatchingsController < ApplicationController

  layout "default"

  before_filter :set_selected_menu

  # page that show match time
  def index
    if is_logged_in
      redirect_to(:action => 'schedule')
    end

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

  end

  # page that let player edit match time
  def schedule

    if !is_logged_in
      redirect_to(:controller => 'players' , :action => 'login')
    end


    #player variable
    @the_player = Player.find(session[:player_id])

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

  end

  def submit_datetime
    #if no these input parameter return false
    if !params.has_key?(:datetime) || !params.has_key?(:match_id)
      flash[:notice] = "Insufficient parameters input"
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

    begin
    #eg :2015-10-10 12:00 am
    input_datetime = DateTime.strptime(params[:datetime], '%Y-%m-%d %H:%M %P')
    #in case of invalid datetime format supplied
    rescue
      flash[:notice] = "Invalid date input"
      redirect_to(:action => "schedule")
      return
    end

    player = Player.find(session[:player_id])
    opponent_player = nil

    #check the player is belong to top or bottom
    #then assign match time with respect to player position
    #and find the opponent team 

    if match.top_player_id == session[:player_id]
      match.top_datetime = input_datetime
      opponent_player = Player.where(:id => match.bottom_player_id).first
    elsif match.bottom_player_id == session[:player_id]
      match.bottom_datetime = input_datetime
      opponent_player = Player.where(:id => match.top_player_id).first
    else
      flash[:notice] = "Invalid player for the match"
      redirect_to(:action => "schedule")
      return
    end

    match.save

    #if both datetime is same then the datetime is agreed
    if(match.top_datetime == match.bottom_datetime)
      match.agreed_datetime = match.bottom_datetime
      match.save
      flash[:notice] = "Match time has been confirmed and finalized at " + match.bottom_datetime.strftime("%Y-%m-%d %H:%M %P")
      #if opponent player/team is found
      if opponent_player
        mail_title = "Time confirmed for an upcoming tournament match"
        mail_body = "Hi " + opponent_player.team_name + ", \n\n" + "You and your opponent (" + player.team_name + ") has confirmed the upcoming match time at " + 
                    input_datetime.strftime("%l.%M %P (%A),  %-d %B %Y") + " Pacific Standard Time (UTC -8). \n " +  
                    " \n\n  Please do not reply to this email, this email is sent by a mail bot from Clash Of Pubs."
        #send confirmation to both party
        send_mail_to_opponent(mail_title, mail_body, opponent_player.email)
        send_mail_to_opponent(mail_title, mail_body, player.email)
      end
    else
      #if haven't confirm match time
      flash[:notice] = "Match time has been successfully set, pending for opponent"
      #if opponent player/team is found
      if opponent_player
        mail_title = "Your opponent has set a time for an upcoming tournament match"
        mail_body = "Hi " + opponent_player.team_name + ", \n\n" + "Your opponent (" + player.team_name + ") has set the upcoming match time at " + 
                    input_datetime.strftime("%l.%M %P (%A),  %-d %B %Y") + " Pacific Standard Time (UTC -8). \n\n Please login and select the same time slot " + 
                    "if you agree to play at the proposed time by your opponent, you may select other time slot if the proposed time is not convenient for you." + 
                    "\n\n" + "You can login at http://www.clashofpubs.com ." + " \n\n  Please do not reply to this email, this email is sent by a mail bot from Clash Of Pubs."
        send_mail_to_opponent(mail_title, mail_body, opponent_player.email)
      end

    end
    redirect_to(:action => "schedule")

    @datetime = params[:datetime]
    @match_id = params[:match_id]
    
  end

  private

  def set_selected_menu
    @is_schedule_page = 'class=current_page_item'
  end

  def is_logged_in

    if session[:player_id]
      return true
    else
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
