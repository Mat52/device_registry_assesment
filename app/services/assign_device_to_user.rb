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
    puts @requesting_user.id
    puts @serial_number
    puts @new_device_owner_id


    if device.nil?
      puts "Creating Device"
      device = @requesting_user.devices.create!(serial_number: @serial_number)
      return :success
    else
       if device.user_id == @requesting_user.id
          puts "AssigningError::AlreadyUsedBySameUser"
          raise AssigningError::AlreadyUsedBySameUser
       elsif device.user_id != @requesting_user.id
          puts "AssigningError::AlreadyUsedOnOtherUser"
          raise AssigningError::AlreadyUsedOnOtherUser
       end
    end
  end
end
