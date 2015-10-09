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
    #eg :2015-10-10 12:00 am

    #if cant find the match
    if match.nil?
      flash[:notice] = "Invalid match input"
      redirect_to(:action => "schedule")
      return
    end

    begin
    input_datetime = DateTime.strptime(params[:datetime], '%Y-%m-%d %H:%M %P')
    #in case of invalid datetime format supplied
    rescue
      flash[:notice] = "Invalid date input"
      redirect_to(:action => "schedule")
      return
    end

    player = Player.find(session[:player_id])

    #check the player is belong to top or bottom
    #then assign match time with respect to player position
    if match.top_player_id == session[:player_id]
      match.top_datetime = input_datetime
    elsif match.bottom_player_id == session[:player_id]
      match.bottom_datetime = input_datetime
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
    else
      flash[:notice] = "Match time has been successfully set, pending for opponent"
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

end
