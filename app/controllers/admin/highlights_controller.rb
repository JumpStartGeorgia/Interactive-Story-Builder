class Admin::HighlightsController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:coordinator])
  end
  before_filter :asset_filter

  # GET /highlights
  # GET /highlights.json
  def index
    @items = Highlight.sorted

    @css.push("dataTables/bootstrap/3/jquery.dataTables.bootstrap.css")
    @js.push("dataTables/jquery.dataTables.js", "dataTables/bootstrap/3/jquery.dataTables.bootstrap.js", "search.js", "stories.js")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @items }
    end
  end

  # GET /highlights/1
  # GET /highlights/1.json
  def show
    @item = Highlight.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @item }
    end
  end

  # GET /highlights/new
  # GET /highlights/new.json
  def new
    @item = Highlight.new
    # create the translation object for however many locales there are
    # so the form will properly create all of the nested form fields
    I18n.available_locales.each do |locale|
      @item.highlight_translations.build(:locale => locale.to_s)
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @item }
    end
  end

  # GET /highlights/1/edit
  def edit
    @item = Highlight.find(params[:id])
  end

  # POST /highlights
  # POST /highlights.json
  def create
    @item = Highlight.new(params[:highlight])

    add_missing_translation_content(@item.highlight_translations)

    respond_to do |format|
      if @item.save
        format.html { redirect_to admin_highlights_path, notice: t('app.msgs.success_created', :obj => t('activerecord.models.highlight')) }
        format.json { render json: @item, status: :created, location: @item }
      else
        format.html { render action: "new" }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /highlights/1
  # PUT /highlights/1.json
  def update
    @item = Highlight.find(params[:id])

    @item.assign_attributes(params[:highlight])

    add_missing_translation_content(@item.highlight_translations)

    respond_to do |format|
      if @item.save
        format.html { redirect_to admin_highlights_path, notice: t('app.msgs.success_updated', :obj => t('activerecord.models.highlight')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /highlights/1
  # DELETE /highlights/1.json
  def destroy
    @item = Highlight.find(params[:id])
    @item.destroy

    respond_to do |format|
      format.html { redirect_to admin_highlights_url }
      format.json { head :no_content }
    end
  end

protected

  def asset_filter
    @css.push("navbar.css", "highlights.css")
  end
end
