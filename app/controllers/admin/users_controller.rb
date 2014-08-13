class Admin::UsersController < AdminController
  before_action :authenticate_admin_user!
  
  def index
    @users = User.all
  end
end
