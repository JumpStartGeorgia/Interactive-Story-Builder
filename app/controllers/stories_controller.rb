class StoriesController < ApplicationController
  # GET /stories
  # GET /stories.json
  def index
    @usemap = true
    @stories = Story.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @stories }
    end
  end

  # GET /stories/1
  # GET /stories/1.json
  def show
    @story = Story.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @story }
    end
  end

  # GET /stories/new
  # GET /stories/new.json
  def new
    @story = Story.new

    respond_to do |format|
        format.html # new.html.erb
      format.json { render json: @story }
    end
  end

  # GET /stories/1/edit
  def edit
    @story = Story.find(params[:id])
  end

  # POST /stories
  # POST /stories.json
  def create
    @story = Story.new(params[:story])

    respond_to do |format|
      if @story.save
        format.html { redirect_to @story, notice: 'Story was successfully created.' }
        format.json { render json: @story, status: :created, location: @story }
      else
        format.html { render action: "new" }
        format.json { render json: @story.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /stories/1
  # PUT /stories/1.json
  def update
    @story = Story.find(params[:id])

    respond_to do |format|
      if @story.update_attributes(params[:story])
        format.html { redirect_to @story, notice: 'Story was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @story.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stories/1
  # DELETE /stories/1.json
  def destroy
    @story = Story.find(params[:id])
    @story.destroy

    respond_to do |format|
      format.html { redirect_to stories_url }
      format.json { head :ok }
    end
  end
 

  def get_section
    @section = Section.find_by_id(params[:section_id])   
    logger.debug(@section)
    respond_to do |format|       
      format.json { render json: @section.to_json }     
    end    
  end
  def get_content
    if params[:s]!='new'
    
      @content = Content.find_by_id(params[:item_id])
    
   else @content = Content.new(:section_id => params[:id])
   end
    respond_to do |format|
      format.js
    end
    
    #logger.debug(@content)
    #respond_to do |format|       
     # format.json { render json: @content.to_json }     

    
  end
    def get_media


      if params[:s]!='new'
    
    @media = Medium.find_by_id(params[:item_id])   
    
   else @media = Medium.new(:section_id => params[:id])
   end
    respond_to do |format|
      format.js
    end

  end

  def new_section
     @section = Section.new(params[:section])
   
     respond_to do |format|
        if @section.save
          #format.html { redirect_to @section, notice: 'Content was successfully created.' }
          format.json { render json: @section.to_json, status: :created, location: @section }
        else
          format.html { render action: "new" }
          format.json { render json: @section.errors, status: :unprocessable_entity }
        end
      end    
  end
  def new_content
    logger.debug(params)
     @content = Content.new(params[:content])
   
     respond_to do |format|
        if @content.save
          #format.html { redirect_to @section, notice: 'Content was successfully created.' }
          format.json { render json: @content.to_json, status: :created, location: @content }
        else
          format.html { render action: "new" }
          format.json { render json: @content.errors, status: :unprocessable_entity }
        end
      end    
  end
    def new_media
    logger.debug(params)
     @content = Content.new(params[:content])
   
     respond_to do |format|
        if @content.save
          #format.html { redirect_to @section, notice: 'Content was successfully created.' }
          format.json { render json: @content.to_json, status: :created, location: @content }
        else
          format.html { render action: "new" }
          format.json { render json: @content.errors, status: :unprocessable_entity }
        end
      end    
  end
  def save_content

  @story = Story.find(params[:id])


    logger.debug(params)
     @content = Content.find_by_id(params[:content_id])
   
     respond_to do |format|
        if @content.update_attributes(params[:content])
          #format.html { redirect_to @section, notice: 'Content was successfully created.' }
          format.json { render json: @content.to_json, status: :created }
        else
          format.html { render action: "new" }
          format.json { render json: @content.errors, status: :unprocessable_entity }
        end
      end    
  end
 def save_media

    # @media = Medium.find(params[:item_id])


    logger.debug(params)
     # @content = Content.find_by_id(params[:content_id])
   
     # respond_to do |format|
     #    if @content.update_attributes(params[:content])
     #      #format.html { redirect_to @section, notice: 'Content was successfully created.' }
     #      format.json { render json: @content.to_json, status: :created }
     #    else
     #      format.html { render action: "new" }
     #      format.json { render json: @content.errors, status: :unprocessable_entity }
     #    end
     #  end    
  end

  def sections
      @story = Story.fullsection(params[:id])
      #Story.find(params[:id])      
      
      #logger.debug("id = #{params}" );
  end
    def content
      @story = Story.fullsection(params[:id])
      #Story.find(params[:id])

      
      #logger.debug("id = #{params}" );
  end
  def upload_file
    @media = Medium.find_by_id(1);
    @media.image = params[:image]
    @media.save
    render json: nil
  end
end
       #logger.debug("loggerrrrrrrrrrrr #{params}" );