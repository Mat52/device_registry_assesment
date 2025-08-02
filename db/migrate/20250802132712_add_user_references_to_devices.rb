class AddUserReferencesToDevices < ActiveRecord::Migration[7.1]
  def change
    add_column :devices, :previous_user_id, :integer
  end
end
