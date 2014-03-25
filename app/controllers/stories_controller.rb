class StoriesController < ApplicationController
  # GET /stories
  # GET /stories.json
  def index
    #@usemap = true
    @stories = Story.all

    respond_to do |format|
      format.html  #index.html.erb
      format.json { render json: @stories }
    end
  end

  # GET /stories/1
  # GET /stories/1.json
  def show

    @story = Story.find(params[:id])

    respond_to do |format|
      format.html  #show.html.erb
      format.json { render json: @story }
    end
  end

  # GET /stories/new
  # GET /stories/new.json
  def new
    @story = Story.new

    respond_to do |format|
        format.html #new.html.erb
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
        format.html { redirect_to sections_story_path(@story), notice: 'Story was successfully created.' }
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
        format.html { redirect_to  sections_story_path(@story),  notice: 'Story was successfully updated.' }
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
 




  def get_data
    type = params[:type]

    if type == 's'

      if params[:command]!='n'
        @item = Section.find_by_id(params[:section_id])    
      else 
        @item = Section.new()
      end  
           
      respond_to do |format|
        format.js { render :action => "get_section" }
      end

    elsif type == 'c'

      if params[:command]!='n'
        @item = Content.find_by_id(params[:item_id])
      else 
        @item = Content.new()#:section_id => params[:id]
      end
      respond_to do |format|
        format.js  {render :action => "get_content" }
      end

    elsif type == 'm'

        if params[:command]!='n'    
          @item = Medium.find_by_id(params[:item_id])   
        else @item = Medium.new(:section_id => params[:id])
        end
        respond_to do |format|
          format.js {render :action => "get_media" }
        end

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
  

  def save_section      
    @item = Section.find_by_id(params[:section][:id])  
     respond_to do |format|
          if @item.update_attributes(params[:section])
          flash[:success] = "Section was successfully updated."
          format.js {render action: "build_tree", status: :created }                  
        else
          flash[:error] = "Section wasn't updated, please try again later"            
          format.js {render json: nil, status: :unprocessable_entity }      
        end
      end    
  end
  def save_content      
     @item = Content.find_by_id(params[:content][:id])  
     respond_to do |format|
        if @item.update_attributes(params[:content])
          flash[:success] = "Content was successfully updated."
          format.js {render action: "build_tree", status: :created }                  
        else
          flash[:error] = "Content wasn't updated, please try again later"            
          format.js {render json: nil, status: :unprocessable_entity }      
        end
      end    
  end
 def save_media
    @item = Medium.find_by_id(params[:medium][:id])
    respond_to do |format|
        if @item.update_attributes(params[:medium])          
          flash[:success] = "Media was successfully updated."
          format.js {render action: "build_tree", status: :created }          
        else          
          flash[:error] = "Media wasn't updated, please try again later"            
          format.js {render json: nil, status: :unprocessable_entity }
        end
      end    
  end

    # DELETE /stories/1
  # DELETE /stories/1.json
  def destroy_data    
    item = nil
    logger.debug(params)
    type = params[:type]
    if type == 's'
      item = Section.find_by_id(params[:section_id])               
    elsif type == 'c'
      item =  Content.find_by_id(params[:item_id])      
    elsif type == 'm'      
      item = Medium.find_by_id(params[:item_id])           
    end

    item.destroy

   respond_to do |format|
      if item.destroyed?   
         format.json { render json: item.to_json, status: :created }
      else  format.json { render json: item.errors, status: :unprocessable_entity }
      end
    end
  end


  def sections
      @story = Story.fullsection(params[:id])
      #Story.find(params[:id])      
      
      #logger.debug("id = #{params}" );
  end
   
end
       #logger.debug("loggerrrrrrrrrrrr #{params}" );