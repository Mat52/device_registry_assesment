# frozen_string_literal: true

class AssignDeviceToUser
  def initialize(requesting_user:, serial_number:, new_device_owner_id:)
    @requesting_user = requesting_user
    @serial_number = serial_number
    @new_device_owner_id = new_device_owner_id
  end

  def call
    new_user = User.find(@new_device_owner_id)
    raise RegistrationError::Unauthorized unless @requesting_user.id == new_user.id
    device = Device.uncached { Device.find_by(serial_number: @serial_number) }
    if device
      already_used = device.device_assignments
                           .where(user_id: new_user.id)
                           .where.not(returned_at: nil)
                           .exists?
      raise AssigningError::AlreadyUsedOnUser if already_used
    end
    if device.nil?
      device = new_user.devices.create!(serial_number: @serial_number)
      device.device_assignments.create!(user: new_user, returned_at: nil)
      return :success
    end
    active_assignment = device.device_assignments.find_by(returned_at: nil)
    if active_assignment && active_assignment.user_id != new_user.id
      raise AssigningError::AlreadyUsedOnOtherUser
    end

    if active_assignment && active_assignment.user_id == new_user.id
      raise AssigningError::AlreadyUsedBySameUser
    end
    device.update!(user_id: new_user.id)
    device.device_assignments.create!(user: new_user, returned_at: nil)
    :success
  end
end
