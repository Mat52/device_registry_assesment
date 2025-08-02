# frozen_string_literal: true

class ReturnDeviceFromUser
  def initialize(user:, serial_number:, from_user:)
    @user = user
    @serial_number = serial_number
    @from_user = from_user.to_i
  end

  def call
    device = find_device!
    authorize_user!(device)
    active_assignment = find_active_assignment!(device)

    ActiveRecord::Base.transaction do
      active_assignment.update!(returned_at: Time.current)
      device.update!(user_id: nil)
    end

    :success
  end

  private

  def find_device!
    Device.find_by(serial_number: @serial_number) ||
      raise(AssigningError::DeviceNotFound, "Device with serial #{@serial_number} does not exist")
  end

  def authorize_user!(device)
    if device.user_id != @from_user
      raise AssigningError::AlreadyUnassigned,
            "Device #{@serial_number} is not currently assigned to user #{@from_user}"
    end

    if @user.id != @from_user
      raise AssigningError::Unauthorized,
            "User #{@user.id} is not allowed to return device #{@serial_number} for user #{@from_user}"
    end
  end

  def find_active_assignment!(device)
    device.device_assignments.find_by(user_id: @user.id, returned_at: nil) ||
      raise(AssigningError::AlreadyUnassigned,
            "No active assignment found for user #{@user.id} on device #{@serial_number}")
  end
end
