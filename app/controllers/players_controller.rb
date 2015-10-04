class PlayersController < ApplicationController

  layout "default"

  before_filter :set_selected_menu

  def new
    #check if already logged in
    if session[:player_id]
      redirect_to(:controller => 'static', :action => 'index')
    end

    #get others team's order
    used_team_orders = Player.pluck(:team_order)

    #if no available team redirect to error page
    #i.e: there is 32 used_team_orders
    if used_team_orders.count >= 32
      redirect_to(:action => 'full')
      return
    end

    @player = Player.new
  end

  def create
    @player = Player.new(player_params)

    #preserve capital letter in display name
    @player.display_name = @player.name

    #downcase the player name to prevent case sensitive conflict, eg: 'Yale' and 'yale'
    @player.name.downcase!

    #get others team's order to prevent duplicate
    # and generate a random team order for current player
    used_team_orders = Player.pluck(:team_order)

    #if no available team redirect to error page
    #i.e: there is 32 used_team_orders
    if used_team_orders.count >= 32
      redirect_to(:action => 'full')
      return
    end

    #generate array of [1,2,3,4,...,32]
    all_team_orders = [*1..32]

    #eg : [1,2,3,...,32] - [5,14,25] = [1,2,3,4,6,...,13,15,..,24,26,..,32]
    available_team_orders = all_team_orders - used_team_orders

    available_team_orders.shuffle!

    @player.team_order = available_team_orders.first

    if @player.save

      #put the player into first level of match
      #if odd then put on top, else put on bottom

      if @player.team_order.odd?
        firstmatch = Matching.find((@player.team_order + 1)/ 2)
        firstmatch.top_player = @player.id
        firstmatch.save
      else
        firstmatch = Matching.find((@player.team_order) / 2)
        firstmatch.bottom_player = @player.id
        firstmatch.save
      end

      send_register_email
      flash[:notice] = "Player account successfully created, you can now login." 
      redirect_to(:action => 'login')
    else
      render('new')
    end
  end

  def login
    #check if already logged in
    if session[:player_id]
      redirect_to(:controller => 'static', :action => 'index')
    end
    
  end

  def attempt_login
    if params[:name].present? && params[:password].present?
      found_player = Player.where(:name => params[:name].downcase).first
      if found_player
        #returns user object if authenticated, else return false
        authorized_player = found_player.authenticate(params[:password])
      end
    end

    if authorized_player
      # mark user as logged in
      session[:player_id] = authorized_player.id
      session[:name] = authorized_player.name
      session[:display_name] = authorized_player.display_name
      # !change this
      flash[:notice] = "Successfully logged in."
      redirect_to(:controller => 'static', :action => 'index')
    else
      flash[:notice] = "Invalid name/password combination."
      redirect_to(:action => 'login')
    end

  end

  def logout
    # mark user as logged out
    session[:player_id] = nil
    session[:name] = nil
    session[:display_name] = nil

    reset_session
    flash[:notice] = "Logged out"
    redirect_to(:action => "login")
  end

  def full
    
  end

  private

  def player_params
    params.require(:player).permit(:name, :email, :password, :steam_id, :team_name, :mmr)
  end

  def send_register_email
    RestClient.post "https://api:key-4acf342ece92e2a9f1240f06df432c0f"\
    "@api.mailgun.net/v3/sandbox89c5c212672b432786bd76744dc11c81.mailgun.org/messages",
    :from => "Clash Of Pubs Mailbot <mailbot@clashofpubs.com>",
    :to => "#{params[:player][:name]} <#{params[:player][:email]}>",
    :subject => "Hello #{params[:player][:name]}",
    :text => "Hi #{params[:player][:name]} , Thank you for your participation in Clash of Pubs! Your registration details are shown below : " + 
    "\n\n Player Name : #{params[:player][:name]} \n" + " Steam_ID : #{params[:player][:steam_id]} \n" + " Team Name : #{params[:player][:team_name]} \n" + 
    " MMR : #{params[:player][:mmr]} \n" + " Password : #{params[:player][:password]} \n\n " + 
    " Please keep this email as your password will be encrypted in our server and might not be retrieved in case you forgot it in the future. \n\n" +
    " Please do not reply to this email, this email is sent by a mail bot from Clash Of Pubs."
  end

  def set_selected_menu
    @is_register_page = 'class=current_page_item'
  end
end
