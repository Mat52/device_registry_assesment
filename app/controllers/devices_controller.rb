# frozen_string_literal: true

class DevicesController < ApplicationController
  before_action :authenticate_user!, only: %i[assign unassign]

  rescue_from RegistrationError::Unauthorized, with: :render_unauthorized
  rescue_from AssigningError, with: :render_assignment_error

  def assign
    AssignDeviceToUser.new(
      requesting_user: @current_user,
      serial_number: assign_params[:device][:serial_number],
      new_device_owner_id: assign_params[:new_owner_id].to_i
    ).call

    head :ok
  end

  def unassign
    ReturnDeviceFromUser.new(
      user: @current_user,
      serial_number: unassign_params[:device][:serial_number],
      from_user: unassign_params[:from_user_id]
    ).call

    head :ok
  end

  private

  def assign_params
    params.permit(:new_owner_id, device: [:serial_number])
  end

  def unassign_params
    params.permit(:from_user_id, device: [:serial_number])
  end

  def render_unauthorized
    render json: { error: 'Unauthorized' }, status: :unprocessable_entity
  end

  def render_assignment_error(error)
    render json: { error: error.class.name.demodulize }, status: :unprocessable_entity
  end
end
