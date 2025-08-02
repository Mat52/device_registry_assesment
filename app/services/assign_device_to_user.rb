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
    device.reload if device
    puts "DEBUG: Found device? #{!!device}, user_id: #{device&.user_id}, previous_user_id: #{device&.previous_user_id}"
  end
end
