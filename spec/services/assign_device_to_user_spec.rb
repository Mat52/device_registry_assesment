# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssignDeviceToUser do
  let(:user) { create(:user) }
  let(:serial_number) { '123456' }

  def assign_device(new_owner_id)
    described_class.new(
      requesting_user: user,
      serial_number: serial_number,
      new_device_owner_id: new_owner_id
    ).call
  end

  context 'when user registers a device to another user' do
    let(:new_device_owner_id) { create(:user).id }

    it 'raises an Unauthorized error' do
      expect { assign_device(new_device_owner_id) }.to raise_error(RegistrationError::Unauthorized)
    end
  end

  context 'when user registers a device for themselves' do
    let(:new_device_owner_id) { user.id }

    it 'creates a new device for the user' do
      assign_device(new_device_owner_id)
      expect(user.devices.reload.pluck(:serial_number)).to include(serial_number)
    end

    context 'when the device was previously assigned to and returned by the same user' do
      before do
        assign_device(new_device_owner_id)
        ReturnDeviceFromUser.new(
          user: user,
          serial_number: serial_number,
          from_user: user.id
        ).call
      end

      it 'raises an AlreadyUsedOnUser error' do
        expect { assign_device(new_device_owner_id) }.to raise_error(AssigningError::AlreadyUsedOnUser)
      end
    end

    context 'when the device is currently assigned to another user' do
      let!(:other_user) { create(:user) }

      before do
        described_class.new(
          requesting_user: other_user,
          serial_number: serial_number,
          new_device_owner_id: other_user.id
        ).call
      end

      it 'raises an AlreadyUsedOnOtherUser error' do
        expect { assign_device(new_device_owner_id) }.to raise_error(AssigningError::AlreadyUsedOnOtherUser)
      end
    end
  end
end
