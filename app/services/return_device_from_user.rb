# frozen_string_literal: true

class ReturnDeviceFromUser
  def initialize(user:, serial_number:, from_user:)
    @user = user
    @serial_number = serial_number
    @from_user = from_user
  end

  def call
    raise AssigningError::Unauthorized unless @user.id == @from_user.to_i

    device = Device.find_by(serial_number: @serial_number, user_id: @from_user)
    raise AssigningError::AlreadyUnassigned if device.nil?

    active_assignment = device.device_assignments.where(user_id: @user.id, returned_at: nil).last
    raise AssigningError::AlreadyUnassigned if active_assignment.nil?

    active_assignment.update!(returned_at: Time.current)
    device.update!(user_id: nil)
  end
end
