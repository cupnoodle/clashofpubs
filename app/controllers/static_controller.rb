class StaticController < ApplicationController

  layout "default"

  #home page
  def index
  end

  #team page
  def teams
  end

  #schedule page
  def schedule
  end

  #register page
  def register
    @player = Player.new
  end

  #about page
  def about
  end
end
