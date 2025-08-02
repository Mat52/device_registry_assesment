# frozen_string_literal: true

class ReturnDeviceFromUser
  def initialize(user:, serial_number:, from_user:)
    @user = user
    @serial_number = serial_number
    @from_user = from_user
  end

  def call
    unless @user.id == @from_user.to_i
      raise AssigningError::Unauthorized
    end
    device = Device.find_by(serial_number: @serial_number, user_id: @from_user)
    if device.nil?
      raise AssigningError::AlreadyUnassigned
    end
    device.update!(user_id: nil, previous_user_id: @user.id)
  end
end
