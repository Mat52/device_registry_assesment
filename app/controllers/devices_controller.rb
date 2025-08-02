# frozen_string_literal: true

class DevicesController < ApplicationController
  before_action :authenticate_user!, only: %i[assign unassign]
  def assign
    begin
      AssignDeviceToUser.new(
        requesting_user: @current_user,
        serial_number: params[:serial_number],
        new_device_owner_id: params[:new_device_owner_id]
      ).call
      head :ok
    rescue RegistrationError::Unauthorized
      render json: { error: 'Unauthorized' }, status: :unprocessable_entity
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
