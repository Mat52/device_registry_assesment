# frozen_string_literal: true

class AssignDeviceToUser
  def initialize(requesting_user:, serial_number:, new_device_owner_id:)
    @requesting_user = requesting_user
    @serial_number = serial_number
    @new_device_owner_id =new_device_owner_id
  end

  def call
    raise RegistrationError::Unauthorized unless @requesting_user.id == @new_device_owner_id
    device = Device.find_by(serial_number: @serial_number)
    if device.nil?
      device = @requesting_user.devices.create!(serial_number: @serial_number)
      device.device_assignments.create!(user: @requesting_user)
      return :success
    else
       if device.user_id == @requesting_user.id
          raise AssigningError::AlreadyUsedBySameUser
       elsif device.user_id != @requesting_user.id
          raise AssigningError::AlreadyUsedOnOtherUser
       end
       device.update!(user_id: @requesting_user.id)
       device.device_assignments.create!(user: @requesting_user)
       :success
    end
  end
end
