class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|

      t.string :name, :limit => 64, null: false
      t.string :steam_id, :limit => 64, null: false
      t.string :email, :limit => 64, null: false
      t.string :team_name, :limit => 64, null: false
      t.integer :mmr, null: false
      t.string :password_digest, null: false


      t.timestamps null: false
    end
  end
end
