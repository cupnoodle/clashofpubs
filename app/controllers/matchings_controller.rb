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
