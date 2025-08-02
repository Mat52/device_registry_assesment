class DeviceAssignment < ApplicationRecord
  belongs_to :device
  belongs_to :user
end
