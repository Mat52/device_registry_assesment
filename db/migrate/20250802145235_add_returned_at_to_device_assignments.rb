class AddReturnedAtToDeviceAssignments < ActiveRecord::Migration[7.0]
  def change
    add_column :device_assignments, :returned_at, :datetime
    add_index :device_assignments, :returned_at
  end
end
