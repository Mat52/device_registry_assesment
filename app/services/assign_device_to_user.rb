# frozen_string_literal: true

class AssignDeviceToUser
  def initialize(requesting_user:, serial_number:, new_device_owner_id:)
    @requesting_user = requesting_user
    @serial_number = serial_number
    @new_device_owner_id = new_device_owner_id
  end

  def call
    puts "=== AssignDeviceToUser START ==="
    puts "Requesting user: #{@requesting_user.id}"
    puts "Serial number: #{@serial_number}"
    puts "New device owner: #{@new_device_owner_id}"

    # 0. Sprawdzenie uprawnień
    raise RegistrationError::Unauthorized unless @requesting_user.id == @new_device_owner_id

    device = Device.find_by(serial_number: @serial_number)&.reload
    puts "Device found? #{device.present?}"

    # 1. Brak urządzenia -> tworzymy nowe
    if device.nil?
      puts "No device found, creating new..."
      device = @requesting_user.devices.create!(serial_number: @serial_number)
      device.device_assignments.create!(user: @requesting_user)
      puts "Device created and assigned."
      puts "=== AssignDeviceToUser END (success - new device) ==="
      return :success
    end

    puts "Device current user_id: #{device.user_id.inspect}"
    puts "Previous assignments: #{device.device_assignments.pluck(:user_id).inspect}"

    # 2. Urządzenie aktualnie przypisane do innego użytkownika
    if device.user_id.present? && device.user_id != @requesting_user.id
      puts "Device currently used by other user -> raising AlreadyUsedOnOtherUser"
      raise AssigningError::AlreadyUsedOnOtherUser
    end

    # 3. Urządzenie aktualnie przypisane do tego samego usera
    if device.user_id == @requesting_user.id
      puts "Device already used by same user -> raising AlreadyUsedBySameUser"
      raise AssigningError::AlreadyUsedBySameUser
    end

    # 4. Urządzenie jest wolne, sprawdzamy historię w DeviceAssignments
    if device.user_id.nil? && device.device_assignments.reload.where(user_id: @requesting_user.id).exists?
        puts "Device was already assigned to this user in the past -> raising AlreadyUsedOnUser"
        raise AssigningError::AlreadyUsedOnUser
    end

    # 5. Urządzenie zwrócone i nigdy nieużywane przez tego usera -> przypisujemy
    puts "Assigning device to user #{@requesting_user.id}..."
    device.update!(user_id: @requesting_user.id)
    device.device_assignments.create!(user: @requesting_user)
    puts "Assignment successful."
    puts "=== AssignDeviceToUser END (success - reused device) ==="
    :success
  end
end
