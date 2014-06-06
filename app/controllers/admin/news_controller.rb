class Admin::NewsController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:admin])
  end
  before_filter :asset_filter

  # GET /news
  # GET /news.json
  def index
    @news = News.order('id desc')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @news }
    end
  end

  # GET /news/1
  # GET /news/1.json
  def show
    @news = News.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @news }
    end
  end

  # GET /news/new
  # GET /news/new.json
  def new
    @news = News.new
    # create the translation object for however many locales there are
    # so the form will properly create all of the nested form fields
    I18n.available_locales.each do |locale|
			@news.news_translations.build(:locale => locale.to_s)
		end

    gon.news_form = true
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @news }
    end
  end

  # GET /news/1/edit
  def edit
    @news = News.find(params[:id])
    gon.news_form = true
		gon.published_date = @news.published_at.strftime('%m/%d/%Y') if !@news.published_at.nil?
  end

  # POST /news
  # POST /news.json
  def create
    @news = News.new(params[:news])

    add_missing_translation_content(@news.news_translations)
    
    # add published fields to translations so can create permalink
    @news.news_translations.each do |trans|
      trans.is_published = @news.is_published
      trans.published_at = @news.published_at
    end

    respond_to do |format|
      if @news.save
        format.html { redirect_to admin_news_path(@news), notice: t('app.msgs.success_created', :obj => t('activerecord.models.news')) }
        format.json { render json: @news, status: :created, location: @news }
      else
        gon.news_form = true
    		gon.published_date = @news.published_at.strftime('%m/%d/%Y') if !@news.published_at.nil?
        format.html { render action: "new" }
        format.json { render json: @news.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /news/1
  # PUT /news/1.json
  def update
    @news = News.find(params[:id])

    @news.assign_attributes(params[:news])

    add_missing_translation_content(@news.news_translations)

    # add published fields to translations so can create permalink
    @news.news_translations.each do |trans|
      trans.is_published = @news.is_published
      trans.published_at = @news.published_at
    end


    respond_to do |format|
      if @news.save
        format.html { redirect_to admin_news_path(@news), notice: t('app.msgs.success_updated', :obj => t('activerecord.models.news')) }
        format.json { head :ok }
      else
        gon.news_form = true
    		gon.published_date = @news.published_at.strftime('%m/%d/%Y') if !@news.published_at.nil?
        format.html { render action: "edit" }
        format.json { render json: @news.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /news/1
  # DELETE /news/1.json
  def destroy
    @news = News.find(params[:id])
    @news.destroy

    respond_to do |format|
      format.html { redirect_to admin_news_index_url }
      format.json { head :ok }
    end
  end
  
  private
  
  def asset_filter
    @css.push("jquery-ui-1.7.3.custom")
    @js.push("news", "jquery.ui.datepicker")
  end 
  
  
end
