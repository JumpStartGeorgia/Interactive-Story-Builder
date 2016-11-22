class Admin::LogosController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:site_admin])
  end
  before_filter :asset_filter

  # GET /admin/logos
  # GET /admin/logos.json
  def index
    @partners = Logo.partners.sorted
    @sponsors = Logo.sponsors.sorted

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @logos }
    end
  end

  # GET /admin/logos/1
  # GET /admin/logos/1.json
  def show
    @logo = Logo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @logo }
    end
  end

  # GET /admin/logos/new
  # GET /admin/logos/new.json
  def new
    @logo = Logo.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @logo }
    end
  end

  # GET /admin/logos/1/edit
  def edit
    @logo = Logo.find(params[:id])
  end

  # POST /admin/logos
  # POST /admin/logos.json
  def create
    @logo = Logo.new(params[:logo])

    respond_to do |format|
      if @logo.save
        format.html { redirect_to admin_logos_path, notice: t('app.msgs.success_created', :obj => t('activerecord.models.logo')) }
        format.json { render json: @logo, status: :created, location: @logo }
      else
        format.html { render action: "new" }
        format.json { render json: @logo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/logos/1
  # PUT /admin/logos/1.json
  def update
    @logo = Logo.find(params[:id])

    respond_to do |format|
      if @logo.update_attributes(params[:logo])
        format.html { redirect_to admin_logos_path, notice: t('app.msgs.success_created', :obj => t('activerecord.models.logo')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @logo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/logos/1
  # DELETE /admin/logos/1.json
  def destroy
    @logo = Logo.find(params[:id])
    @logo.destroy

    respond_to do |format|
      format.html { redirect_to admin_logos_url }
      format.json { head :no_content }
    end
  end


  def up
    logo = Logo.where(id: params[:id]).first
    if logo.present?
      logo.move_higher
      render json: nil , status: :created
    else
      render json: nil , status: :unprocessable_entity
    end
  end

  def down
    logo = Logo.where(id: params[:id]).first
    if logo.present?
      logo.move_lower
      render json: nil , status: :created
    else
      render json: nil , status: :unprocessable_entity
    end
  end

protected

  def asset_filter
    @css.push("navbar.css", "logos.css") 
    @js.push('logos.js')  
  end 

end
