# frozen_string_literal: true

class ReturnDeviceFromUser
  def initialize(requesting_user:, serial_number:, from_user:)
    @requesting_user = requesting_user
    @serial_number = serial_number
    @from_user = from_user
  end

  def call
    unless @requesting_user.id == @from_user.to_i
      raise ReturningError::Unauthorized
    end
    device = Device.find_by(serial_number: @serial_number, user_id: @from_user)
    if device.nil?
      raise UnassigningError::AlreadyUnassigned
    end
    device.update!(user_id: nil, previous_user_id: @requesting_user.id)
  end
end
