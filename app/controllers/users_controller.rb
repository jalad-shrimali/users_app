# app/controllers/users_controller.rb
class UsersController < ApplicationController
  protect_from_forgery with: :null_session

  def index
    @users = User.all
    render json: @users
  end

  def create
    @user = User.new(user_params)
    if @user.save
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def filter
    campaign_names = params[:campaign_names]&.split(',') || []
    if campaign_names.empty?
      render json: { error: 'No campaign names provided' }, status: :bad_request
      return
    end

    @users = User.all.select do |user|
      user_campaigns = parse_campaigns_list(user.campaigns_list)
      user_campaigns.any? { |campaign| campaign_names.include?(campaign['campaign_name']) }
    end

    render json: @users
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, campaigns_list: [:campaign_name, :campaign_id])
  end

  def parse_campaigns_list(campaigns_list)
    if campaigns_list.is_a?(String)
      JSON.parse(campaigns_list) rescue []
    elsif campaigns_list.is_a?(Array)
      campaigns_list
    else
      []
    end
  end
end
