class Admin::StoryTypesController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:site_admin])
  end
  before_filter :asset_filter

  # GET /story_types
  # GET /story_types.json
  def index
    @story_types = StoryType.sorted

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @story_types }
    end
  end

  # GET /story_types/1
  # GET /story_types/1.json
  def show
    @story_type = StoryType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @story_type }
    end
  end

  # GET /story_types/new
  # GET /story_types/new.json
  def new
    @story_type = StoryType.new
    # create the translation object for however many locales there are
    # so the form will properly create all of the nested form fields
    I18n.available_locales.each do |locale|
      @story_type.story_type_translations.build(:locale => locale.to_s)
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @story_type }
    end
  end

  # GET /story_types/1/edit
  def edit
    @story_type = StoryType.find(params[:id])
  end

  # POST /story_types
  # POST /story_types.json
  def create
    @story_type = StoryType.new(params[:story_type])

    add_missing_translation_content(@story_type.story_type_translations)

    respond_to do |format|
      if @story_type.save
        format.html { redirect_to admin_story_types_path, notice: t('app.msgs.success_created', :obj => t('activerecord.models.story_type')) }
        format.json { render json: @story_type, status: :created, location: @story_type }
      else
        format.html { render action: "new" }
        format.json { render json: @story_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /story_types/1
  # PUT /story_types/1.json
  def update
    @story_type = StoryType.find(params[:id])

    @story_type.assign_attributes(params[:story_type])

    add_missing_translation_content(@story_type.story_type_translations)

    respond_to do |format|
      if @story_type.save
        format.html { redirect_to admin_story_types_path, notice: t('app.msgs.success_updated', :obj => t('activerecord.models.story_type')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @story_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /story_types/1
  # DELETE /story_types/1.json
  def destroy
    @story_type = StoryType.find(params[:id])
    @story_type.destroy

    respond_to do |format|
      format.html { redirect_to admin_story_types_url }
      format.json { head :no_content }
    end
  end

protected

  def asset_filter
    @css.push("navbar.css")
  end 

end
