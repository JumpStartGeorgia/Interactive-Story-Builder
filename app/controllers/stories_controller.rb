class StoriesController < ApplicationController
  before_filter :authenticate_user!

  before_filter(:except => [:index, :new, :create]) do |controller_instance|

    controller_instance.send(:can_edit_story?, params[:id])
  end
  
  # GET /stories
  # GET /stories.json
  def index
    #@usemap = true

    @stories = Story.editable_user(current_user.id) 
    respond_to do |format|
      format.html  #index.html.erb
      format.json { render json: @stories }
    end
  end


  # GET /stories/1
  # GET /stories/1.json
  def show
    redirect_to sections_story_path(params[:id])
    # @story = Story.find_by_id(params[:id])

    # respond_to do |format|
    #   format.html  #show.html.erb
    #   format.json { render json: @story }
    # end
  end

  # GET /stories/new
  # GET /stories/new.json
  def new
    @story = Story.new(:user_id => current_user.id)     
    @story.build_asset(:asset_type => Asset::TYPE[:story_thumbnail])    
    @users = User.where("id not in (?)", [@story.user_id, current_user.id])
    @templates = Template.select_list
    logger.debug(@users.inspect)
    respond_to do |format|
        format.html #new.html.er
b      format.json { render json: @story }
    end
  end

  # GET /stories/1/edit
  def edit
    @story = Story.find_by_id(params[:id])
    if !@story.asset_exists?
      @story.build_asset(:asset_type => Asset::TYPE[:story_thumbnail])
    end 
    @users = User.where("id not in (?)", [@story.user_id, current_user.id])
    @templates = Template.select_list
  end

  # POST /stories
  # POST /stories.json
  def create
    @story = Story.new(params[:story])

    respond_to do |format|

      if @story.save
        flash_success_created(Story.model_name.human,@story.title)       
        format.html { redirect_to sections_story_path(@story), notice: t('app.msgs.success_created', :obj => t('activerecord.models.story')) }
       # format.html { redirect_to sections_story_path(@story), notice: 'Story was successfully created.' }
        format.json { render json: @story, status: :created, location: @story }
        format.js { render action: "flash", status: :created }    
      else
        @users = User.where("id not in (?)", [@story.user_id, current_user.id]) 
        if !@story.asset.present? 
          @story.build_asset(:asset_type => Asset::TYPE[:story_thumbnail])
        end      
        @templates = Template.select_list     
        flash[:error] = u I18n.t('app.msgs.error_create', obj:Story.model_name.human, err:@story.errors.full_messages.to_sentence)     

        format.html { render action: "new" }
        format.json { render json: @story.errors, status: :unprocessable_entity }
        format.js {render action: "flash" , status: :ok }
      end
    end
  end

  # PUT /stories/1
  # PUT /stories/1.json
  def update
    @story = Story.find_by_id(params[:id])

    respond_to do |format|
      if @story.update_attributes(params[:story])
        flash_success_updated(Story.model_name.human,@story.title)       
        format.html { redirect_to  sections_story_path(@story),  notice: t('app.msgs.success_updated', :obj => t('activerecord.models.story')) }
        format.js { render action: "flash", status: :created }    
      else
        @users = User.where("id not in (?)", [@story.user_id, current_user.id])
        if !@story.asset.present? 
          @story.build_asset(:asset_type => Asset::TYPE[:story_thumbnail])
        end 
        @templates = Template.select_list

        flash[:error] = u I18n.t('app.msgs.error_updated', obj:Story.model_name.human, err:@story.errors.full_messages.to_sentence)            
        format.html { render action: "edit" }
        format.js {render action: "flash" , status: :ok }
      end
    end
  end

  # DELETE /stories/1
  # DELETE /stories/1.json
  def destroy
    @story = Story.find_by_id(params[:id])
    
     @story.destroy
     if @story.destroyed?             
          flash[:success] = "Item was removed from the tree."          
      else  
          flash[:error] = "Removing data failed [" +  @story.errors.full_messages.to_sentence + "]"                      
      end
    
   respond_to do |format|     
      format.html { redirect_to stories_url }
      format.json { head :ok }  
    end
  end
 
  def reviewer_key
  	@story = Story.find_by_id(params[:id])    
  	
  	if @story.present?
      respond_to do |format|     
        format.html {render layout: 'reviewer'}
      end
    else
      redirect_to root_path, :notice => t('app.msgs.does_not_exist')
    end
  end

  def preview
  	@story = Story.fullsection(params[:id])    
    respond_to do |format|     
      format.html { render 'storyteller/index', layout: false }
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
      @section_list = []
      Section::TYPE.each{|k,v| @section_list << ["#{I18n.t("section_types.#{k}.name")} - #{I18n.t("section_types.#{k}.description")}", v]} 
      @section_list.sort_by!{|x| x[0]}
      if !@item.asset_exists?
          @item.build_asset(:asset_type => Asset::TYPE[:section_audio])
      end   
      respond_to do |format|
        format.js { render :action => "get_section" }
      end

    elsif type == 'content'

      if params[:command]!='n'
        @item = Content.find_by_id(params[:item_id])
      else 
        @item = Content.new(:section_id => params[:section_id], :content => '')
      end
      respond_to do |format|
        format.js  {render :action => "get_content" }
      end

    elsif type == 'media'

        if params[:command]!='n'    
          @item = Medium.find_by_id(params[:item_id])   
        else 
          @item = Medium.new(:section_id => params[:section_id], media_type: 1)
        end

        if !@item.image_exists? 
          @item.build_image(:asset_type => Asset::TYPE[:media_image])
        end   
        if !@item.video_exists?
          @item.build_video(:asset_type => Asset::TYPE[:media_video])
        end      

        respond_to do |format|
          format.js {render :action => "get_media" }
        end


    elsif type == 'slideshow'

        if params[:command]!='n'    
          @item = Slideshow.find_by_id(params[:item_id])   
        else 
          @item = Slideshow.new(:section_id => params[:section_id])
        end
      
          @item.assets.build(:asset_type => Asset::TYPE[:slideshow_image])
        
     
        respond_to do |format|
          format.js {render :action => "get_slideshow" }
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

    @item = Section.find_by_id(params[:section][:id]) 
     respond_to do |format|
          if @item.update_attributes(params[:section].except(:id))
          flash_success_updated(Section.model_name.human,@item.title)       
          format.js {render action: "build_tree", status: :created }                  
        else
          flash[:error] = u I18n.t('app.msgs.error_updated', obj:Section.model_name.human, err:@item.errors.full_messages.to_sentence)                            
          format.js {render json: nil, status: :ok }
        end

      end    
  end
  def save_content      
     @item = Content.find_by_id(params[:content][:id])  
     respond_to do |format|
        if @item.update_attributes(params[:content].except(:id))          
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
        if @item.update_attributes(params[:medium].except(:id))          
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
    elsif type == Section::TYPE[:content]
      item =  Content.find_by_id(params[:item_id])      
    elsif type == Section::TYPE[:media]   
      item = Medium.find_by_id(params[:item_id])
    elsif type == Section::TYPE[:slideshow]   
      item = Slideshow.find_by_id(params[:item_id])                 
    end

    item.destroy if item.present?
    
    respond_to do |format|
      if item.present? && item.destroyed?   
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
      
      # if there are no sections, show the content form by default
      gon.has_no_sections = @story.sections.blank?
  end

  def publish
    @item = Story.find_by_id(params[:id])
    publishing = true;
    pub_title = ''

    if @item.published 
      publishing = false          
    end
    respond_to do |format|     
      if @item.update_attributes(published: publishing)     
        flash[:success] =u I18n.t("app.msgs.success_#{publishing ? '' :'un'}publish", obj:"#{Story.model_name.human} \"#{@item.title}\"")                   
      else
        flash[:error] = u I18n.t("app.msgs.error#{publishing ? '' : 'un'}publish", obj:"#{Story.model_name.human} \"#{@item.title}\"")                                                                             
      end
      
      if @item.published
        pub_title = I18n.t("app.buttons.unpublish")       
      else
        pub_title = I18n.t("app.buttons.publish")       
      end
      format.json {render json: { title: pub_title }, status: :ok }
      format.html { redirect_to stories_url }
    end
  end


 def export
  begin     
    @story = Story.fullsection(params[:id])  
    rootPath = "#{Rails.root}/tmp";
    filename = StoriesHelper.transliterate(@story.title.downcase);
    filename_ext = SecureRandom.hex(3)  
    path =  "#{rootPath}/#{filename}_#{filename_ext}"  
    mediaPath = "#{path}/media"

    require 'fileutils'

    FileUtils.cp_r "#{Rails.root}/public/media/story", "#{path}"  

    if File.directory?("#{Rails.root}/public/template/#{@story.template.name}/fonts")
        FileUtils.cp_r "#{Rails.root}/public/template/#{@story.template.name}/fonts", "#{path}/assets"
    end

    if File.directory?("#{Rails.root}/public/system/places/images/#{params[:id]}/.")
        FileUtils.cp_r "#{Rails.root}/public/system/places/images/#{params[:id]}/.", "#{mediaPath}/images"
    end
    if File.directory?("#{Rails.root}/public/system/places/video/#{params[:id]}/.")
      FileUtils.cp_r "#{Rails.root}/public/system/places/video/#{params[:id]}/.", "#{mediaPath}/video"  
    end
    if File.directory?("#{Rails.root}/public/system/places/audio/#{params[:id]}/.")
      FileUtils.cp_r "#{Rails.root}/public/system/places/audio/#{params[:id]}/.", "#{mediaPath}/audio"
    end
    @export = true
    File.open("#{path}/index.html", "w"){|f| f << render_to_string('storyteller/index.html.erb', :layout => false) }  
    send_file generate_gzip(path,"#{filename}_#{filename_ext}",filename), :type=>"application/x-gzip", :x_sendfile=>true, :filename=>"#{filename}.tar.gz"

    if File.directory?(path)
      FileUtils.remove_dir(path,true)   
    end
    if File.exists?("#{path}.tar.gz")    
      FileUtils.remove_file("#{path}.tar.gz",true)   
    end
  rescue
     flash[:error] =I18n.t("app.msgs.error_export", obj:"#{Story.model_name.human} \"#{@story.errors.inspect}\"")                           
     redirect_to stories_url
  end   
end
def generate_gzip(tar,name,ff)      
    system("tar -czf #{tar}.tar.gz -C '#{Rails.root}/tmp/#{name}' .")
    return "#{tar}.tar.gz"
end
  def clone
    begin
    @item = Story.find_by_id(params[:id])
    dup = @item.amoeba_dup
    dup.title = "#{dup.title} (Clone)"
    dup.reset_fields_for_clone
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
  def test
   
    
  end

  private

  def can_edit_story?(story_id)
    redirect_to root_path, :notice => t('app.msgs.not_authorized') if !Story.can_edit?(story_id, current_user.id)
  end
end       
