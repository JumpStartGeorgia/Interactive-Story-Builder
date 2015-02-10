class Admin::AuthorsController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:coordinator])
  end
  before_filter :asset_filter

  # GET /authors
  # GET /authors.json
  def index
    @authors = Author.sorted

    @css.push("dataTables/jquery.dataTables.bootstrap.css")
    @js.push("dataTables/jquery.dataTables.js", "dataTables/jquery.dataTables.bootstrap.js", "search.js", "stories.js")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @authors }
    end
  end

  # GET /authors/1
  # GET /authors/1.json
  def show
    @author = Author.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @author }
    end
  end

  # GET /authors/new
  # GET /authors/new.json
  def new
    @author = Author.new
    # create the translation object for however many locales there are
    # so the form will properly create all of the nested form fields
    I18n.available_locales.each do |locale|
      @author.author_translations.build(:locale => locale.to_s)
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @author }
    end
  end

  # GET /authors/1/edit
  def edit
    @author = Author.find(params[:id])
  end

  # POST /authors
  # POST /authors.json
  def create
    @author = Author.new(params[:author])

    add_missing_translation_content(@author.author_translations)

    respond_to do |format|
      if @author.save
        format.html { redirect_to admin_authors_path, notice: t('app.msgs.success_created', :obj => t('activerecord.models.author')) }
        format.json { render json: @author, status: :created, location: @author }
      else
        format.html { render action: "new" }
        format.json { render json: @author.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /authors/1
  # PUT /authors/1.json
  def update
    @author = Author.find(params[:id])

    @author.assign_attributes(params[:author])

    add_missing_translation_content(@author.author_translations)

    respond_to do |format|
      if @author.save
        format.html { redirect_to admin_authors_path, notice: t('app.msgs.success_updated', :obj => t('activerecord.models.author')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @author.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /authors/1
  # DELETE /authors/1.json
  def destroy
    @author = Author.find(params[:id])
    @author.destroy

    respond_to do |format|
      format.html { redirect_to admin_authors_url }
      format.json { head :no_content }
    end
  end

protected

  def asset_filter
    @css.push("navbar.css", "authors.css")   
  end 
end
