# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReturnDeviceFromUser do
  let(:user) { create(:user) }
  let(:serial_number) { '123456' }
  let(:from_user) { user.id }

  def return_device(current_user: user, from_user_id: from_user)
    described_class.new(
      user: current_user,
      serial_number: serial_number,
      from_user: from_user_id
    ).call
  end

  before do
    AssignDeviceToUser.new(
      requesting_user: user,
      serial_number: serial_number,
      new_device_owner_id: user.id
    ).call
  end

  context 'when the user returns their own active device' do
    it 'marks the assignment as returned and clears the device owner' do
      return_device

      device = Device.find_by(serial_number: serial_number)
      assignment = device.device_assignments.last

      expect(device.user_id).to be_nil
      expect(assignment.returned_at).not_to be_nil
    end
  end

  context 'when the user tries to return a device they never owned' do
    let(:other_user) { create(:user) }
    let(:from_user) { other_user.id }

    it 'raises an AlreadyUnassigned error' do
      expect { return_device }.to raise_error(AssigningError::AlreadyUnassigned)
    end
  end

  context 'when the user tries to return an already returned device' do
    before { return_device }

    it 'raises an AlreadyUnassigned error' do
      expect { return_device }.to raise_error(AssigningError::AlreadyUnassigned)
    end
  end

  context 'when another user tries to return the device' do
    let(:other_user) { create(:user) }

    it 'raises an Unauthorized error' do
      expect { return_device(current_user: other_user) }.to raise_error(AssigningError::Unauthorized)
    end
  end
end
