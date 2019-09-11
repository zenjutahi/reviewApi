class Api::V1::SessionsController < Devise::SessionsController
  before_action :sign_in_params, only: :create
  before_action :load_user, only: :create
  before_action :valid_token, only: :destory
  skip_before_action :verify_signed_out_user, only: :destory
  
  # sign in
  def create
    if @user.valid_password?(sign_in_params[:password])
      sign_in "user", @user
      json_response "Signed In Succesfully", true, {user: @user}, :ok
    else
      json_response "Unauthorized", false, {}, :unauthorized
    end
  end
  
  # log out
  def destory
    sign_out @user
    @user.generate_new_authentication_token
    json_response "Log out Succesfully", true, {}, :ok
  end
  
  private
  def sign_in_params
    params.require(:sign_in).permit(:email, :password)
  end
  
  def load_user
    @user = User.find_for_database_authentication(email: sign_in_params[:email])
    if @user
      return @user
    else
      json_response "User doesn't exist", false, {}, :failure
    end
  end
  
  def valid_token
    binding.pry
    @user = User.find_by authentication_token: request.headers["AUTH-TOKEN"]
    if @user
      return @user
    else
      json_response "Invalid Token", false, {}, :failure
    end
  end
end