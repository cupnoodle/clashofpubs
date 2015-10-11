class StaticController < ApplicationController

  layout "default"

  #home page
  def index
    @is_index_page = 'class=current_page_item'
  end

  #team page
  def teams
    @is_team_page = 'class=current_page_item'

    @teams_hash_array = Player.order(:created_at => :desc).pluck_to_hash(:team_name, :mmr)
  end

  #schedule page
  def schedule
    @is_schedule_page = 'class=current_page_item'
  end

  #register page
  def register
    @player = Player.new
  end

  #about page
  def about
    @is_about_page = 'class=current_page_item'
  end
end
