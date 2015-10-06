class CreateMatchings < ActiveRecord::Migration
  def change
    create_table :matchings do |t|
      t.integer :top_player_id
      t.integer :bottom_player_id

      t.datetime :top_datetime
      t.datetime :bottom_datetime
      t.datetime :agreed_datetime

      t.timestamps null: false
    end
  end
end
