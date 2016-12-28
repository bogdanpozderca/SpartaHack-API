class Api::V1::UsersController < ApplicationController
  before_action :geo_ip
  before_action :find_user_by_id, only: [:show]
  before_action :restrict_access, only: [:show, :create, :request_password_token]
  before_action :authenticate_with_token!, only: [:index, :update, :destroy, :change_password]
  before_action :authenticate_password_token!, only: [:reset_password]
  load_and_authorize_resource find_by: :id
  respond_to :json

  def index
    @users = User.all

    render json: @users
  end


  def show
    render json: User.find(params[:id]), include: [:application, :rsvp], status: 200
  end

  def create
    user = User.new(user_params)
    if user.save
      render json: user, status: 201, location: [:api, user]
    else
      render json: { errors: user.errors }, status: 422
    end
  end

  def update
    user = current_user

    if user.update(user_params)
      render json: user, status: 200, location: [:api, user]
    else
      render json: { errors: user.errors }, status: 422
    end
  end

  def request_password_token
    unless user_params[:email].present?
      render json: { errors: { email: ["is required"] } }, status: 422 and return
    end

    if User.exists?(:email => user_params[:email])
      user = User.where(:email => user_params[:email]).first
    else
      render json: { errors: { :email => ['not found']} }, status: 422 and return
    end
    user.reset_password_token = User.generate_password_token
    if user.save
      render json: user, status: 201, location: [:api, user]
    else
      render json: { errors: user.errors }, status: 422
    end
  end

  def change_password
    unless password_params[:current_password].present?
      render json: { errors: { current_password: ["is required"] } }, status: 422 and return
    end

    user = current_user
    if user.update_with_password(password_params)
      render json: user, status: 200, location: [:api, user]
    else
      render json: { errors: user.errors }, status: 422
    end
  end

  def reset_password
    if password_token?
      user = User.where(reset_password_token: request.headers['X-WWW-RESET-PASSWORD-TOKEN']).first
    end

    if password_params[:password].blank? or password_params[:password_confirmation].blank?
      render json: { errors: { all: ["fields are required"] } }, status: 422 and return
    end

    user.password = password_params[:password]
    user.password_confirmation = password_params[:password_confirmation]
    user.reset_password_token = nil
    if user.save
      render json: user, status: 200, location: [:api, user]
    else
      render json: { errors: { passwords: ["do not match"] } }, status: 422
    end
  end

  def destroy
    app = Application.find_by(:user_id => current_user.id)
    unless app.blank?
      app.destroy
    end

    rsvp = Rsvp.find_by(:user_id => current_user.id)
    unless rsvp.blank?
      rsvp.destroy
    end
    current_user.destroy
    head 204
  end

  private

  def user_params
    params.permit(:email, :password, :password_confirmation,
    :first_name, :last_name, roles: []).merge(:roles => current_user.present? ? current_user.roles : ['hacker'] )
  end

  def password_params
    params.permit(:current_password, :password, :password_confirmation)
  end

  # render before CanCan Exception
  def find_user_by_id
    if !User.exists? id: params[:id]
      render json: { errors: { user: ["does not exist"] } }, status: 422
    end
  end
end
