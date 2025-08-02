# frozen_string_literal: true

class AssignDeviceToUser
  def initialize(requesting_user:, serial_number:, new_device_owner_id:)
    @requesting_user = requesting_user
    @serial_number = serial_number
    @new_device_owner_id = new_device_owner_id
  end

  def call
    authorize_user!
    device = find_or_initialize_device
    handle_existing_device(device)
    assign_device_to_user(device)
    :success
  end

  private

  def new_user
    @new_user ||= User.find(@new_device_owner_id)
  end

  def authorize_user!
    raise RegistrationError::Unauthorized unless @requesting_user.id == new_user.id
  end

  def find_or_initialize_device
    Device.uncached { Device.find_by(serial_number: @serial_number) } ||
      new_user.devices.build(serial_number: @serial_number)
  end

  def handle_existing_device(device)
    if device.persisted?
      raise AssigningError::AlreadyUsedOnUser if previously_assigned_to_user?(device)
      active_assignment = active_assignment_for(device)
      raise AssigningError::AlreadyUsedOnOtherUser if assigned_to_other_user?(active_assignment)
      raise AssigningError::AlreadyUsedBySameUser if assigned_to_same_user?(active_assignment)
    else
      device.save!
    end
  end

  def previously_assigned_to_user?(device)
    device.device_assignments
          .where(user_id: new_user.id)
          .where.not(returned_at: nil)
          .exists?
  end

  def active_assignment_for(device)
    device.device_assignments.find_by(returned_at: nil)
  end

  def assigned_to_other_user?(assignment)
    assignment && assignment.user_id != new_user.id
  end

  def assigned_to_same_user?(assignment)
    assignment && assignment.user_id == new_user.id
  end

  def assign_device_to_user(device)
    device.update!(user_id: new_user.id)
    device.device_assignments.create!(user: new_user, returned_at: nil)
  end
end
