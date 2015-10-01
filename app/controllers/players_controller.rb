class PlayersController < ApplicationController

  layout "default"

  def new
    @player = Player.new
  end

  def create
    @player = Player.new(player_params)

    #downcase the player name to prevent case sensitive conflict, eg: 'Yale' and 'yale'
    @player.name.downcase!
    if @player.save
      send_register_email
      flash[:notice] = "Player account successfully created, you can now login." 
      redirect_to(:action => 'login')
    else
      render('new')
    end
  end

  def login
  end

  def attempt_login
    if params[:name].present? && params[:password].present?
      found_player = Player.where(:name => params[:name]).first
      if found_player
        #returns user object if authenticated, else return false
        authorized_player = found_player.authenticate(params[:password])
      end
    end

    if authorized_player
      # mark user as logged in
      session[:player_id] = authorized_player.id
      session[:name] = authorized_player.name
      # !change this
      flash[:notice] = "Successfully logged in."
      redirect_to(:controller => 'static', :action => 'index')
    else
      flash[:notice] = "Invalid name/password combination."
      redirect_to(:action => 'login')
    end

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
end
