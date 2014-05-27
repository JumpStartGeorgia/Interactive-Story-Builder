class Admin::LanguagesController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:admin])
  end

  # GET /languages
  # GET /languages.json
  def index
    @languages = Language.sorted

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @languages }
    end
  end

  # GET /languages/1
  # GET /languages/1.json
  def show
    @language = Language.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @language }
    end
  end

  # GET /languages/new
  # GET /languages/new.json
  def new
    @language = Language.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @language }
    end
  end

  # GET /languages/1/edit
  def edit
    @language = Language.find(params[:id])
  end

  # POST /languages
  # POST /languages.json
  def create
    @language = Language.new(params[:language])

    respond_to do |format|
      if @language.save
        format.html { redirect_to admin_languages_path, notice: t('app.msgs.success_created', :obj => t('activerecord.models.language'))}
        format.json { render json: @language, status: :created, location: @language }
      else
        format.html { render action: "new" }
        format.json { render json: @language.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /languages/1
  # PUT /languages/1.json
  def update
    @language = Language.find(params[:id])

    respond_to do |format|
      if @language.update_attributes(params[:language])
        format.html { redirect_to admin_languages_path, notice: t('app.msgs.success_updated', :obj => t('activerecord.models.language'))}
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @language.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /languages/1
  # DELETE /languages/1.json
  def destroy
    @language = Language.find(params[:id])
    @language.destroy

    respond_to do |format|
      format.html { redirect_to admin_languages_url }
      format.json { head :ok }
    end
  end
end
