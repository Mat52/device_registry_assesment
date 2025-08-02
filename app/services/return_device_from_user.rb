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
    Device.find_by(serial_number: @serial_number) || raise(AssigningError::AlreadyUnassigned)
  end

  def authorize_user!(device)
    raise AssigningError::AlreadyUnassigned unless device.user_id == @from_user
    raise AssigningError::Unauthorized unless @user.id == @from_user
  end

  def find_active_assignment!(device)
    device.device_assignments.find_by(user_id: @user.id, returned_at: nil) ||
      raise(AssigningError::AlreadyUnassigned)
  end
end
