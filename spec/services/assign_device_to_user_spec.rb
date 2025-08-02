# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssignDeviceToUser do
  subject(:assign_device) do
    described_class.new(
      requesting_user: user,
      serial_number: serial_number,
      new_device_owner_id: new_device_owner_id
    ).call
  end

  let!(:user) { create(:user) }  # ważne: let! żeby rekord powstał od razu
  let(:serial_number) { SecureRandom.hex(4) }

  context 'when users registers a device to other user' do
    let!(:new_device_owner_id) { create(:user).id } # też let!

    it 'raises an error' do
      expect { assign_device }.to raise_error(RegistrationError::Unauthorized)
    end
  end

  context 'when user registers a device on self' do
    let(:new_device_owner_id) { user.id }

    it 'creates a new device' do
      assign_device
      expect(user.devices.reload.pluck(:serial_number)).to include(serial_number)
    end

    context 'when a user tries to register a device that was already assigned to and returned by the same user',
            clean_with_truncation: true do
      before do
        assign_device
        ReturnDeviceFromUser.new(
          user: user,
          serial_number: serial_number,
          from_user: user.id
        ).call
      end

      it 'does not allow to register' do
        puts "Devices: #{Device.all.pluck(:id, :serial_number, :user_id)}"
        puts "Assignments: #{DeviceAssignment.all.pluck(:id, :device_id, :user_id)}"
        expect { assign_device }.to raise_error(AssigningError::AlreadyUsedOnUser)
      end
    end

    context 'when user tries to register device that is already assigned to other user' do
      let!(:other_user) { create(:user) }  # let! tutaj też

      before do
        AssignDeviceToUser.new(
          requesting_user: other_user,
          serial_number: serial_number,
          new_device_owner_id: other_user.id
        ).call
      end

      it 'does not allow to register' do
        expect { assign_device }.to raise_error(AssigningError::AlreadyUsedOnOtherUser)
      end
    end
  end
end