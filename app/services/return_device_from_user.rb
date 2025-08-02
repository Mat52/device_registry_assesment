# frozen_string_literal: true

class ReturnDeviceFromUser
  def initialize(user:, serial_number:, from_user:)
    @user = user
    @serial_number = serial_number
    @from_user = from_user
  end

  def call
    puts "=== ReturnDeviceFromUser START ==="
    puts "User: #{@user.id}, Serial: #{@serial_number}, From user: #{@from_user}"

    unless @user.id == @from_user.to_i
      puts "Unauthorized: user #{@user.id} != from_user #{@from_user}"
      raise AssigningError::Unauthorized
    end

    device = Device.find_by(serial_number: @serial_number, user_id: @from_user)
    if device.nil?
      puts "Device NOT FOUND for serial #{@serial_number} and user_id #{@from_user}"
      raise AssigningError::AlreadyUnassigned
    end

    puts "Found device #{device.id} (serial: #{device.serial_number}, current user_id: #{device.user_id})"

    # 1. Oznaczamy ostatnie przypisanie jako zakończone
    last_assignment = device.device_assignments.order(created_at: :desc).first
    if last_assignment&.user_id == @user.id && last_assignment.returned_at.nil?
      last_assignment.update!(returned_at: Time.current)
      puts "Marked last assignment as returned at #{last_assignment.returned_at}"
    end

    # 2. Zwolnij urządzenie
    device.update!(user_id: nil, previous_user_id: @user.id)

    puts "Device returned. Current device: user_id=#{device.reload.user_id.inspect}, previous_user_id=#{device.previous_user_id.inspect}"
    puts "Assignments history: #{device.device_assignments.pluck(:user_id, :returned_at)}"
    puts "=== ReturnDeviceFromUser END ==="
  end
end
