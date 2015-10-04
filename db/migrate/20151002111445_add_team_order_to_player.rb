class AddTeamOrderToPlayer < ActiveRecord::Migration
  def up
    add_column :players, :team_order, :integer
  end

  def down
    remove_column :players, :team_order
  end
end
