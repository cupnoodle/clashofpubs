class AddDisplayNameToPlayer < ActiveRecord::Migration
  def up
    add_column :players, :display_name, :string, :limit => 64
  end

  def down
    remove_column :players, :display_name
  end
end
