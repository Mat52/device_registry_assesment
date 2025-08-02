# frozen_string_literal: true

class ReturnDeviceFromUser
  def initialize(user:, serial_number:, from_user:)
    @user = user
    @serial_number = serial_number
    @from_user = from_user
  end

  def call
    device = Device.find_by(serial_number: @serial_number)
    raise AssigningError::AlreadyUnassigned if device.nil?
    raise AssigningError::AlreadyUnassigned if device.user_id != @from_user.to_i
    raise AssigningError::Unauthorized if @user.id != @from_user.to_i
    active_assignment = device.device_assignments.find_by(user_id: @user.id, returned_at: nil)
    raise AssigningError::AlreadyUnassigned if active_assignment.nil?
    active_assignment.update!(returned_at: Time.current)
    device.update!(user_id: nil)
  end
end
