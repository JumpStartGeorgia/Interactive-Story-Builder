class AdminController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:user_manager])
  end

  def index
    @css.push("navbar.css")   
  end

end
