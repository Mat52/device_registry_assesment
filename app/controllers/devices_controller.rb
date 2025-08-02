# frozen_string_literal: true

class DevicesController < ApplicationController
  before_action :authenticate_user!, only: %i[assign unassign]
  def assign
    customized_params = params.permit(:new_owner_id, device: [:serial_number])
    serial_number = customized_params[:device][:serial_number]
    new_device_owner_id = customized_params[:new_owner_id].to_i
    begin
      AssignDeviceToUser.new(
        requesting_user: @current_user,
        serial_number: serial_number,
        new_device_owner_id: new_device_owner_id
      ).call
      head :ok
    rescue RegistrationError::Unauthorized
      render json: { error: 'Unauthorized' }, status: :unprocessable_entity
    rescue AssigningError => e
      render json: { error: e.class.name.demodulize }, status: :unprocessable_entity
    end
  end

  def unassign
    # TODO: implement the unassign action
  end

  private

  def device_params
    params.permit(:new_device_owner_id, :serial_number)
  end
end
