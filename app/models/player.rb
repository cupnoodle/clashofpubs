class Player < ActiveRecord::Base

  #bcrypt encryption for player password
  has_secure_password

  USERNAME_REGEX = /\A[a-zA-Z0-9]+[a-zA-z0-9\-_]+/
  EMAIL_REGEX = /\A[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}\Z/i

  validates :email, :presence => true, :length => { :maximum => 64}, :format => EMAIL_REGEX, :uniqueness => true
  validates :name, :presence => true, :length => { :maximum => 64 }, :format => USERNAME_REGEX, :uniqueness => true
  validates :password, :presence => true, length: { minimum: 6 }, on: :create

  validates :mmr, numericality: { only_integer: true }

  validates :team_name, :presence => true, :length => { :maximum => 64 }, :uniqueness => true
  validates :steam_id, :presence => true, :length => { :maximum => 64 }, :uniqueness => true
end
