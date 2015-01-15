class Admin::UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :asset_filter 
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:user_manager])
  end
  before_filter :asset_filter

  # GET /admin/users
  # GET /admin/users.json
  def index
    @css.push("dataTables/jquery.dataTables.bootstrap.css")
    @js.push("dataTables/jquery.dataTables.js", "dataTables/jquery.dataTables.bootstrap.js", "search.js")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: UsersDatatable.new(view_context, current_user) }
    end
  end

  # GET /admin/users/1
  # GET /admin/users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /admin/users/new
  # GET /admin/users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /admin/users/1/edit
  def edit
    @user = User.find(params[:id])
    if @user.role == User::ROLES[:admin] && current_user.role != User::ROLES[:admin]
      redirect_to admin_users_path
    end
  end

  # POST /admin/users
  # POST /admin/users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to admin_users_path, notice: t('app.msgs.success_created', :obj => t('activerecord.models.user')) }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/users/1
  # PUT /admin/users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      success = if params[:user][:password].present? || params[:user][:password_confirmation].present?
        @user.update_attributes(params[:user])
      else
        @user.update_without_password(params[:user])
      end

      if success
        format.html { redirect_to admin_users_path, notice: t('app.msgs.success_updated', :obj => t('activerecord.models.user')) }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/users/1
  # DELETE /admin/users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to admin_users_url }
      format.json { head :ok }
    end
  end

  private
  def asset_filter
    @css.push("navbar.css") 
  end 


protected

  def asset_filter
    @css.push("navbar.css")
  end 

end
