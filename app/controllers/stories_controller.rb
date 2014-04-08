class StoriesController < ApplicationController
  before_filter :authenticate_user!
  # GET /stories
  # GET /stories.json
  def index
    #@usemap = true
    #@stories = Story.includes(:users).where("stories.user_id = :id or users.id = :id",:id => current_user.id) 
    @stories = Story.where("stories.user_id = :id or stories.id in ( select story_id from stories_users t where t.user_id = :id )",:id => current_user.id) 
    respond_to do |format|
      format.html  #index.html.erb
      format.json { render json: @stories }
    end
  end


  # GET /stories/1
  # GET /stories/1.json
  def show

    @story = Story.find_by_id(params[:id])

    respond_to do |format|
      format.html  #show.html.erb
      format.json { render json: @story }
    end
  end

  # GET /stories/new
  # GET /stories/new.json
  def new
    @story = Story.new(:user_id => current_user.id)
    @users = User.where("id not in (?)", [@story.user_id, current_user.id])
    logger.debug(@users.inspect)
    respond_to do |format|
        format.html #new.html.erb
      format.json { render json: @story }
    end
  end

  # GET /stories/1/edit
  def edit
    @story = Story.find_by_id(params[:id])
    @users = User.where("id not in (?)", [@story.user_id, current_user.id])
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
    @story = Story.find_by_id(params[:id])

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
    @story = Story.find_by_id(params[:id])
    if(@story.sections.length == 0)
      @story.destroy
     if @story.destroyed?             
          flash[:success] = "Item was removed from the tree."          
      else  
          flash[:error] = "Removing data failed [" +  @story.errors.full_messages.to_sentence + "]"                      
      end
    else
      flash[:error] = "Before removing story, delete all sections"
    end

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
        @item = Section.new(story_id: params[:id], type_id: Section::TYPE[:content], has_marker: 1)
      end  
           
      respond_to do |format|
        format.js { render :action => "get_section" }
      end

    elsif type == 'c'

      if params[:command]!='n'
        @item = Content.find_by_id(params[:item_id])
      else 
        @item = Content.new(:section_id => params[:section_id], :content => '')
      end
      respond_to do |format|
        format.js  {render :action => "get_content" }
      end

    elsif type == 'm'

        if params[:command]!='n'    
          @item = Medium.find_by_id(params[:item_id])   
        else 
          @item = Medium.new(:section_id => params[:section_id], media_type: 1)
        end
        respond_to do |format|
          format.js {render :action => "get_media" }
        end

    end
  end

  def flash_success_created( obj, title)
      flash[:success] =u I18n.t('app.msgs.success_created', obj:"#{obj} \"#{title}\"")
  end
  def flash_success_updated( obj, title)
      flash[:success] =u I18n.t('app.msgs.success_updated', obj:"#{obj} \"#{title}\"")
  end

  def new_section
     @item = Section.new(params[:section])        
     respond_to do |format|
        if @item.save         
          flash_success_created(Section.model_name.human,@item.title)                     
          format.js { render action: "change_tree", status: :created  }
        else          
          flash[:error] = u I18n.t('app.msgs.error_created', obj:Section.model_name.human, err:@item.errors.full_messages.to_sentence)                  
          format.js {render json: nil, status: :ok }
        end
      end    
  end

 def new_media
    @item = Medium.new(params[:medium])       
    respond_to do |format|
        if @item.save       
          flash_success_created(Medium.model_name.human,@item.title)                     
          format.js { render action: "change_sub_tree", status: :created }                    
        else                    
          flash[:error] = u I18n.t('app.msgs.error_created', obj:Medium.model_name.human, err:@item.errors.full_messages.to_sentence)                       
          format.js {render action: "flash" , status: :ok }
        end
      end    
  end



    def new_content    
     @item = Content.new(params[:content])   
     @flash = flash
     respond_to do |format|
        if @item.save
          flash_success_created(Content.model_name.human,@item.title)                     
          format.js { render action: "change_sub_tree", status: :created  }
        else
          flash[:error] = u I18n.t('app.msgs.error_created', obj:Content.model_name.human, err:@item.errors.full_messages.to_sentence)                  
          format.js {render json: nil, status: :ok }              
        end
      end    
  end
  

  def save_section      
    logger.debug('asdf')
    @item = Section.find_by_id(params[:section][:id])  
     respond_to do |format|
          if @item.update_attributes(params[:section])
          flash_success_updated(Section.model_name.human,@item.title)       
          format.js {render action: "build_tree", status: :created }                  
        else
          flash[:error] = u I18n.t('app.msgs.error_updated', obj:Sectoin.model_name.human, err:@item.errors.full_messages.to_sentence)                            
          format.js {render json: nil, status: :ok }
        end
      end    
  end
  def save_content      
     @item = Content.find_by_id(params[:content][:id])  
     respond_to do |format|
        if @item.update_attributes(params[:content])          
          flash_success_updated(Content.model_name.human,@item.title)           
          format.js {render action: "build_tree", status: :created }                  
        else
          flash[:error] = u I18n.t('app.msgs.error_updated', obj:Content.model_name.human, err:@item.errors.full_messages.to_sentence)                                      
          format.js {render json: nil, status: :ok }
        end
      end    
  end
 def save_media
    @item = Medium.find_by_id(params[:medium][:id])
    respond_to do |format|
        if @item.update_attributes(params[:medium])          
          flash_success_updated(Medium.model_name.human,@item.title)           
          format.js {render action: "build_tree", status: :created }          
        else        
          flash[:error] = u I18n.t('app.msgs.error_updated', obj:Medium.model_name.human, err:@item.errors.full_messages.to_sentence)                                        
          format.js {render action: "flash", status: :ok }
        end
      end    
  end
    
  def destroy_tree_item  
    item = nil    
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
          flash[:success] = "Item was removed from the tree."
          format.json { render json: nil , status: :created } 
      else  
          flash[:error] = "Removing data failed [" +  @item.errors.full_messages.to_sentence + "]"            
          format.json {render json: nil, status: :ok }  
      end
    end
  end
  def up      
    if params[:i] == '-1'
      Section.where(story_id: params[:id]).find_by_id(params[:s]).move_higher            
    else
      Medium.where(section_id: params[:s]).find_by_id(params[:i]).move_higher            
    end
    render json: nil , status: :created    
  end
  def down  
     if params[:i] == '-1'
      Section.where(story_id: params[:id]).find_by_id(params[:s]).move_lower            
    else
      Medium.where(section_id: params[:s]).find_by_id(params[:i]).move_lower            
    end            
    render json: nil , status: :created    
  end

  def sections
      @story = Story.fullsection(params[:id])   
  end

  def publish
    @item = Story.find_by_id(params[:id])
    publishing = true;
    if @item.published 
      publishing = false     
    end
    respond_to do |format|     
      if @item.update_attributes(published: publishing)     
        flash[:success] =u I18n.t("app.msgs.success_#{publishing ? '' :'un'}publish", obj:"#{Story.model_name.human} \"#{@item.title}\"")                   
      else
        flash[:error] = u I18n.t("app.msgs.error#{publishing ? '' : 'un'}publish", obj:"#{Story.model_name.human} \"#{@item.title}\"")                                                       
      end
      format.js {render json: nil, status: :ok }
      format.html { redirect_to stories_url }
    end
  end
  def clone

    begin


    @item = Story.find_by_id(params[:id])
    dup = @item.amoeba_dup
    dup.title = "#{dup.title}(Clone)"
    dup.save

    @item.sections.each_with_index do |s,s_i|
      if s.type_id == Section::TYPE[:media]
        s.media.each_with_index do |m,m_i|          
          dupTemp = dup.sections[s_i].media[m_i]          
          dupTemp.image =  m.image #dup.sections[s_i].media[m_i].image =         
          if m.media_type == Medium::TYPE[:video]            
            dupTemp.video =  m.video
          end
         dupTemp.save
        end          
      end        
    end
        
    flash[:success] =I18n.t("app.msgs.success_clone", obj:"#{Story.model_name.human} \"#{@item.title}\"", to: "#{dup.title}")    

    rescue => e
      flash[:error] =I18n.t("app.msgs.error_clone", obj:"#{Story.model_name.human} \"#{dup.title}\"")                      
    end
   
    respond_to do |format| 
      format.js {render json: nil, status: :ok }
      format.html { redirect_to stories_url }
   end
  end
  #logger.debug("---------------------------------------------------#{params}")
end       