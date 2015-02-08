class Admin::ThemesController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:site_admin])
  end
  before_filter :asset_filter

  # GET /themes
  # GET /themes.json
  def index
    @themes = Theme.sorted

    @css.push("dataTables/jquery.dataTables.bootstrap.css")
    @js.push("dataTables/jquery.dataTables.js", "dataTables/jquery.dataTables.bootstrap.js", "search.js", "stories.js")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @themes }
    end
  end

  def preview
    @js.push("zeroclipboard.min.js","filter.js")
    @css.push("navbar.css", "filter.css", "grid.css","root.css")    
    @theme = Theme.find_by_id(params[:id])
    @stories = process_filter_querystring(Story.is_published.by_theme(@theme.id).paginate(:page => params[:page], :per_page => per_page))      
    @stories_for_slider = Story.recent_by_type(theme_id: @theme.id) if @theme.present?

    if @theme.present?
      respond_to do |format|
        format.html { render 'root/theme' }
        format.json { render :json => {:d => render_to_string("shared/_grid", :formats => [:html], :layout => false)}}      
      end
    else
      redirect_to root_path, :notice => t('app.msgs.does_not_exist')
    end
  end

  # GET /themes/1
  # GET /themes/1.json
  def show
    @theme = Theme.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @theme }
    end
  end

  # GET /themes/new
  # GET /themes/new.json
  def new
    @theme = Theme.new
    # create the translation object for however many locales there are
    # so the form will properly create all of the nested form fields
    I18n.available_locales.each do |locale|
      @theme.theme_translations.build(:locale => locale.to_s)
    end

    # add the required assets
    @css.push("jquery.ui.datepicker.css")
    @js.push('jquery.ui.datepicker.js', 'themes.js')

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @theme }
    end
  end

  # GET /themes/1/edit
  def edit
    @theme = Theme.find(params[:id])

    # add the required assets
    @css.push("jquery.ui.datepicker.css")
    @js.push('jquery.ui.datepicker.js', 'themes.js')

    # set the date values for the datepicker
    gon.published_at = @theme.published_at.strftime('%m/%d/%Y') if @theme.published_at.present?
  end

  # POST /themes
  # POST /themes.json
  def create
    @theme = Theme.new(params[:theme])

    add_missing_translation_content(@theme.theme_translations)

    respond_to do |format|
      if @theme.save
        format.html { redirect_to admin_themes_path, notice: t('app.msgs.success_created', :obj => t('activerecord.models.theme')) }
        format.json { render json: @theme, status: :created, location: @theme }
      else
        # add the required assets
        @css.push("jquery.ui.datepicker.css")
        @js.push('jquery.ui.datepicker.js', 'themes.js')

        # set the date values for the datepicker
        gon.published_at = @theme.published_at.strftime('%m/%d/%Y') if @theme.published_at.present?

        format.html { render action: "new" }
        format.json { render json: @theme.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /themes/1
  # PUT /themes/1.json
  def update
    @theme = Theme.find(params[:id])

    @theme.assign_attributes(params[:theme])

    add_missing_translation_content(@theme.theme_translations)

    respond_to do |format|
      if @theme.save
        format.html { redirect_to admin_themes_path, notice: t('app.msgs.success_updated', :obj => t('activerecord.models.theme')) }
        format.json { head :no_content }
      else
        # add the required assets
        @css.push("jquery.ui.datepicker.css")
        @js.push('jquery.ui.datepicker.js', 'themes.js')

        # set the date values for the datepicker
        gon.published_at = @theme.published_at.strftime('%m/%d/%Y') if @theme.published_at.present?

        format.html { render action: "edit" }
        format.json { render json: @theme.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /themes/1
  # DELETE /themes/1.json
  def destroy
    @theme = Theme.find(params[:id])
    @theme.destroy

    respond_to do |format|
      format.html { redirect_to admin_themes_url }
      format.json { head :no_content }
    end
  end

protected

  def asset_filter
    @css.push("navbar.css")
  end 

end
