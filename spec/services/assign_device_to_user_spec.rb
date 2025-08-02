# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssignDeviceToUser, transactional: false do
  let!(:user) { create(:user) }
  let(:serial_number) { SecureRandom.hex(4) }

  def assign_device
    AssignDeviceToUser.new(
      requesting_user: user,
      serial_number: serial_number,
      new_device_owner_id: new_device_owner_id
    ).call
  end

  context 'when users registers a device to other user' do
    let!(:new_device_owner_id) { create(:user).id }

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

    context 'when a user tries to register a device that was already assigned to and returned by the same user' do
      before(:all) do
        DatabaseCleaner.strategy = :truncation
      end

      before(:each) do
        DatabaseCleaner.start
        assign_device
        ReturnDeviceFromUser.new(
          user: user,
          serial_number: serial_number,
          from_user: user.id
        ).call
      end

      after(:each) do
        DatabaseCleaner.clean
      end

      it 'does not allow to register' do
        devices = Device.all.map { |d| [d.id, d.serial_number, d.user_id] }
        assignments = DeviceAssignment.all.map do |a|
          [a.id, a.device_id, a.user_id, a.returned_at, a.created_at, a.updated_at]
        end
        expect do
          result = assign_device
        end.to raise_error(AssigningError::AlreadyUsedOnUser)
      end
    end

    context 'when user tries to register device that is already assigned to other user' do
      let!(:other_user) { create(:user) }

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
