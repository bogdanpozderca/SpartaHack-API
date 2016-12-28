module Authenticable
  include ActionController::HttpAuthentication::Token::ControllerMethods

  # def log_headers
  #   http_envs = {}.tap do |envs|
  #     request.headers.each do |key, value|
  #       envs[key] = value if key.downcase.starts_with?('http')
  #     end
  #   end
  #
  #   Rails.logger.debug "Received #{request.method.inspect} to #{request.url.inspect} from #{request.remote_ip.inspect}. Processing with headers #{http_envs.inspect} and params #{params.inspect} "
  # end

  # Devise methods overwrites
  def current_user
    @current_user ||= User.find_by(auth_token: request.headers['X-WWW-USER-TOKEN'])
  end

  def authenticate_with_token!
    render json: { errors: ["Not authenticated"] }, status: :unauthorized unless user_signed_in?
  end

  def user_signed_in?
    current_user.present?
  end

  def authenticate_password_token!
    render json: { errors: { password: ["token missing or invalid"] } }, status: :unauthorized unless password_token?
  end

  def password_token?
    User.exists?(reset_password_token: request.headers['X-WWW-RESET-PASSWORD-TOKEN'])
  end

  def restrict_access
    authenticate_or_request_with_http_token do |token|
      if ApiKey.exists? access_token: token
        ApiKey.find_by_access_token(token).increment!(:count)
        true
      end
    end
  end

end
