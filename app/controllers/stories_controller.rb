class StoriesController < ApplicationController
  before_filter :authenticate_user!, :except => [:review]
  before_filter(:except => [:index, :new, :create, :check_permalink, :tag_search, :collaborator_search, :review]) do |controller_instance|  
    controller_instance.send(:can_edit_story?, params[:id])
  end
  before_filter :asset_filter
  before_filter :set_form_gon


  # GET /stories
  # GET /stories.json
  def index    
    @css.push("navbar.css", "filter.css", "grid.css","author.css")
    @js.push("zeroclipboard.min.js","filter.js","stories.js") 
    @stories =  process_filter_querystring(Story.editable_user(current_user.id).paginate(:page => params[:page], :per_page => per_page))           
    @editable = (user_signed_in?)

    respond_to do |format|
      format.html  #index.html.erb
      format.json { render :json => {:d => render_to_string("shared/_grid", :formats => [:html], :layout => false)}}          
    end
  end


  # GET /stories/1
  # GET /stories/1.json
  def show
    redirect_to sections_story_path(params[:id])
  end

  # GET /stories/new
  # GET /stories/new.json
  def new
    @story = Story.new(:user_id => current_user.id, :locale => current_user.default_story_locale)     
    @story.build_asset(:asset_type => Asset::TYPE[:story_thumbnail])    
#    @templates = Template.select_list
    @story_tags = []
    
    respond_to do |format|
        format.html #new.html.er
        format.json { render json: @story }
    end
  end

  # GET /stories/1/edit
  def edit
    @story = Story.find(params[:id])
    if !@story.asset_exists?
      @story.build_asset(:asset_type => Asset::TYPE[:story_thumbnail])
    end 
#    @templates = Template.select_list(@story.template_id)
    @story_tags = @story.tags.token_input_tags
  end

  # POST /stories
  # POST /stories.json
  def create
    @story = Story.new(params[:story])

    respond_to do |format|

      if @story.save
        flash_success_created(Story.model_name.human,@story.title)       
        format.html { redirect_to edit_story_path(@story) }
      #  format.json { render json: @story, status: :created, location: @story }
      else
        if !@story.asset.present? 
          @story.build_asset(:asset_type => Asset::TYPE[:story_thumbnail])
        end      
        @templates = Template.select_list(@story.template_id) 
        @story_tags = @story.tags.token_input_tags

        flash[:error] = I18n.t('app.msgs.error_created', obj:Story.model_name.human, err:@story.errors.full_messages.to_sentence)     
        format.html { render action: "new" }
        #  format.json { render json: @story.errors, status: :unprocessable_entity }
        #  format.js {render action: "flash" , status: :ok }
      end
    end
  end

  # PUT /stories/1
  # PUT /stories/1.json
  def update
    @story = Story.find(params[:id])
  
    respond_to do |format|
      if !@story.published && params[:story][:published]=="1"
        if !@story.about.present? || !@story.asset_exists?
          flash[:error] = I18n.t('app.msgs.error_publish_missing_fields', :obj => @story.title)            
        elsif @story.sections.map{|t| t.content? && t.content.content.present? }.count(true) == 0
          flash[:error] = I18n.t('app.msgs.error_publish_missing_content_section')            
        end                      
        format.html { render action: "edit" }
        format.js {render action: "flash" , status: :ok }
      else
        if @story.update_attributes(params[:story])

          flash_success_updated(Story.model_name.human,@story.title)       
          format.html { redirect_to  edit_story_path(@story),  notice: t('app.msgs.success_updated', :obj => t('activerecord.models.story')) }
          format.js { render action: "flash", status: :created }    
        else
          if !@story.asset.present? 
            @story.build_asset(:asset_type => Asset::TYPE[:story_thumbnail])
          end 
          @templates = Template.select_list(@story.template_id)
          @story_tags = @story.tags.token_input_tags
          
          flash[:error] = I18n.t('app.msgs.error_updated', obj:Story.model_name.human, err:@story.errors.full_messages.to_sentence)            
          format.html { render action: "edit" }
          format.js {render action: "flash" , status: :ok }
        end
      end
    end
  end

  # DELETE /stories/1
  # DELETE /stories/1.json
  def destroy
    @story = Story.find(params[:id])
    
     @story.destroy
     if @story.destroyed?             
          flash[:success] = I18n.t('app.msgs.destroy_story.success')
      else  
          flash[:error] = I18n.t('app.msgs.destroy_story.error', :err => @story.errors.full_messages.to_sentence)
      end
    
   respond_to do |format|     
      format.html { redirect_to stories_url }
      format.json { head :ok }  
    end
  end
 
  def review    
    @css.push("navbar.css", "navbar2.css", "storyteller.css", "modalos.css")
    @js.push("storyteller.js","modalos.js")    

    @story = Story.find_by_reviewer_key(params[:id])
    if @story.present?
      if @story.published?
        redirect_to storyteller_show_path(@story.permalink)     
      else
        respond_to do |format|     
          format.html { render 'storyteller/index', layout: false }
        end
      end
    else
      redirect_to root_path, :notice => t('app.msgs.does_not_exist')
    end  
  end

  def preview
    @css.push("navbar.css", "navbar2.css", "storyteller.css","modalos.css")
    @js.push("storyteller.js","modalos.js")

    if params[:n] == 'n'
      @no_nav = true
    end    
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
        @item = Section.new(story_id: params[:id], has_marker: 0)
      end        
#      @section_list = []
#      Section::TYPE.each{|k,v| @section_list << ["#{I18n.t("section_types.#{k}.name")} - #{I18n.t("section_types.#{k}.description")}", v]} 
#      @section_list.sort_by!{|x| x[0]}
      if @item.present? && !@item.asset_exists?
          @item.build_asset(:asset_type => Asset::TYPE[:section_audio])
      end   
      respond_to do |format|
        if @item.present?
          format.js { render :action => "get_section" }
        else
          @get_data_error = I18n.t('app.msgs.error_get_data')
          format.js
        end
      end

    elsif type == 'content'

      if params[:command]!='n'
        @item = Content.find_by_id(params[:item_id])
      else 
        @item = Content.new(:section_id => params[:section_id], :content => '')
      end
      respond_to do |format|
        if @item.present?
          format.js  {render :action => "get_content" }
        else
          @get_data_error = I18n.t('app.msgs.error_get_data')
          format.js
        end
      end

    elsif type == 'media'
        if params[:command]!='n'    
          @item = Medium.find_by_id(params[:item_id])   
        else 
          @item = Medium.new(:section_id => params[:section_id], media_type: Medium::TYPE[:image])
        end

        if @item.present? &&  !@item.image_exists? 
          @item.build_image(:asset_type => Asset::TYPE[:media_image])
        end   
        if @item.present? && !@item.video_exists?
          @item.build_video(:asset_type => Asset::TYPE[:media_video])
        end      

        respond_to do |format|
           if @item.present?
            format.js {render :action => "get_media" }
          else
            @get_data_error = I18n.t('app.msgs.error_get_data')
            format.js
          end
        end
    elsif type == 'slideshow'

        if params[:command]!='n'    
          @item = Slideshow.find_by_id(params[:item_id])           
        else 
          @item = Slideshow.new(:section_id => params[:section_id])
        end
      
       if @item.present? && @item.assets.blank?
          @item.assets.build(:asset_type => Asset::TYPE[:slideshow_image])
        end      

     
        respond_to do |format|
          if @item.present?
              format.js {render :action => "get_slideshow" }
          else
            @get_data_error = I18n.t('app.msgs.error_get_data')
            format.js          
          end
      end
    elsif type == 'embed_media'

        if params[:command]!='n'    
          @item = EmbedMedium.find_by_id(params[:item_id])   
        else 
          @item = EmbedMedium.new(:section_id => params[:section_id])
        end
        respond_to do |format|
          if @item.present?
              format.js {render :action => "get_embed_media" }
          else
            @get_data_error = I18n.t('app.msgs.error_get_data')
            format.js          
          end
        end
    end
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
  
   def new_slideshow
    @item = Slideshow.new(params[:slideshow])    
    respond_to do |format|
        if @item.save       
          flash_success_created(Slideshow.model_name.human,@item.title)                     
          format.js { render action: "change_sub_tree", status: :created }                    
        else                    
          flash[:error] = u I18n.t('app.msgs.error_created', obj:Slideshow.model_name.human, err:@item.errors.full_messages.to_sentence)                       
          format.js {render action: "flash" , status: :ok }
        end
      end    
  end

  def new_embed_media
    @item = EmbedMedium.new(params[:embed_medium])       
    respond_to do |format|
        if @item.save       
          flash_success_created(EmbedMedium.model_name.human,@item.title)                     
          format.js { render action: "change_sub_tree", status: :created }                    
        else                    
          flash[:error] = u I18n.t('app.msgs.error_created', obj:EmbedMedium.model_name.human, err:@item.errors.full_messages.to_sentence)                       
          format.js {render action: "flash" , status: :ok }
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
  def save_slideshow
    @item = Slideshow.find_by_id(params[:slideshow][:id])
    respond_to do |format|
        if @item.update_attributes(params[:slideshow].except(:id))          
          flash_success_updated(Slideshow.model_name.human,@item.title)           
          format.js {render action: "build_tree", status: :created }          
        else        
          flash[:error] = u I18n.t('app.msgs.error_updated', obj:Slideshow.model_name.human, err:@item.errors.full_messages.to_sentence)                                        
          format.js {render action: "flash", status: :ok }
        end
      end    
  end
  def save_embed_media
    @item = EmbedMedium.find_by_id(params[:embed_medium][:id])
    respond_to do |format|
        if @item.update_attributes(params[:embed_medium])          
          flash_success_updated(EmbedMedium.model_name.human,@item.title)           
          format.js {render action: "build_tree", status: :created }          
        else        
          flash[:error] = u I18n.t('app.msgs.error_updated', obj:EmbedMedium.model_name.human, err:@item.errors.full_messages.to_sentence)                                        
          format.js {render action: "flash", status: :ok }
        end
      end    
  end
  
  
  def destroy_tree_item  
    item = nil    
    type = params[:type]
    if type == 's'
      item = Section.find_by_id(params[:section_id])               
    elsif type == 'content'
      item =  Content.find_by_id(params[:item_id])      
    elsif type == 'media'
      item = Medium.find_by_id(params[:item_id])
    elsif type == 'slideshow'
      item = Slideshow.find_by_id(params[:item_id])                 
    end

    item.destroy if item.present?
    
    respond_to do |format|
      if !item.present?
          flash[:error] = I18n.t('app.msgs.destroy_item.error_not_found')
          format.json { render json: nil , status: :created } 
      elsif item.destroyed?   
          flash[:success] = I18n.t('app.msgs.destroy_item.success')
          format.json { render json: nil , status: :created } 
      else  
          flash[:error] = I18n.t('app.msgs.destroy_item.error', :err => @item.errors.full_messages.to_sentence)
          format.json {render json: nil, status: :ok }  
      end
    end
  end
  def up      
    item = nil
    if params[:i] == '-1'
      item = Section.where(story_id: params[:id]).find_by_id(params[:s])
    else
      item = Medium.where(section_id: params[:s]).find_by_id(params[:i])
    end
    if item.present?
      item.move_higher 
      render json: nil , status: :created    
    else
      render json: nil , status: :unprocessable_entity
    end
  end
  def up_slideshow    
    item = Asset.find_by_id(params[:asset_id])
    if item.present?
      item.move_higher 
      render json: nil , status: :created    
    else
      render json: nil , status: :unprocessable_entity
    end
  end
  def down_slideshow    
    item = Asset.find_by_id(params[:asset_id])
    if item.present?
      item.move_lower 
      render json: nil , status: :created    
    else
      render json: nil , status: :unprocessable_entity
    end
  end
  def down  
    item = nil
    if params[:i] == '-1'
      item = Section.where(story_id: params[:id]).find_by_id(params[:s])
    else
      item = Medium.where(section_id: params[:s]).find_by_id(params[:i])
    end            
    if item.present?
      item.move_lower 
      render json: nil , status: :created    
    else
      render json: nil , status: :unprocessable_entity
    end
  end

  def sections
      @story = Story.fullsection(params[:id])   

      @js.push("modalos.js")
      @css.push("modalos.css")

      # if there are no sections, show the content form by default
      gon.has_no_sections = @story.sections.blank?
      respond_to do |format|
        format.html { render :layout=>"storybuilder" }
      end
  end

  def publish

    @item = Story.find_by_id(params[:id])
    publishing = !@item.published
    pub_title = ''
    error = false
    respond_to do |format|    
      
      if publishing
        if !(@item.about.present? && @item.asset_exists?)                 
                  view_context.log(@item.sections.map{|t| t.content? && t.content.content.present? }.count(true) )
           format.json {render json: { e:true, msg: (t('app.msgs.error_publish_missing_fields', :obj => @item.title) +  
                " <a href='" +  edit_story_path(@item) + "'>" + t('app.msgs.error_publish_missing_fields_link') + "</a>")} }  
           error = true       
        elsif @item.sections.map{|t| t.content.present? && t.content.content.present? }.count(true) == 0          
           format.json {render json: { e:true, msg: t('app.msgs.error_publish_missing_content_section')} }          
           error = true
        end            
      end


      if !error 
        if @item.update_attributes(published: publishing)     
          flash[:success] =u I18n.t("app.msgs.success_#{publishing ? '' :'un'}publish", obj:"#{Story.model_name.human} \"#{@item.title}\"")                   
          pub_title = @item.published ? I18n.t("app.buttons.unpublish")  : I18n.t("app.buttons.publish")                    
          format.json {render json: { title: pub_title }, status: :ok }
        else          
          format.json {render json: { e:true, msg: t("app.msgs.error#{publishing ? '' : 'un'}publish", obj:"#{Story.model_name.human} \"#{@item.title}\"")}}     
        end      
      end
      format.html { redirect_to stories_url }
  end
end


  def export
    begin   
      @css.clear()
      @js.clear()
      @story = Story.fullsection(params[:id])  
      rootPath = "#{Rails.root}/tmp/stories";
      filename = StoriesHelper.transliterate(@story.title.downcase);      
      filename_ext = SecureRandom.hex(3)  
      path =  "#{rootPath}/#{filename}_#{filename_ext}"  
      mediaPath = "#{path}/media"
      #%x[rake story:tmp_stories_clear]
      require 'fileutils'      
      FileUtils.cp_r "#{Rails.root}/public/media/story", "#{path}"  
      
      story_id = params[:id]
      template_id = @story.template_id

      if File.directory?("#{Rails.root}/public/template/#{template_id}/assets")
          FileUtils.cp_r "#{Rails.root}/public/template/#{template_id}/assets/", "#{path}/"
      end
      if File.directory?("#{Rails.root}/public/template/#{template_id}/js")
          FileUtils.cp_r "#{Rails.root}/public/template/#{template_id}/js/", "#{path}/"
      end
      if File.directory?("#{Rails.root}/public/template/#{template_id}/css")
          FileUtils.cp_r "#{Rails.root}/public/template/#{template_id}/css/", "#{path}/"
      end
      if File.directory?("#{Rails.root}/public/system/places/images/#{story_id}/.")
          FileUtils.cp_r "#{Rails.root}/public/system/places/images/#{story_id}/.", "#{mediaPath}/images"
      end
      if File.directory?("#{Rails.root}/public/system/places/video/#{story_id}/.")
        FileUtils.cp_r "#{Rails.root}/public/system/places/video/#{story_id}/.", "#{mediaPath}/video"  
      end
      if File.directory?("#{Rails.root}/public/system/places/audio/#{story_id}/.")
        FileUtils.cp_r "#{Rails.root}/public/system/places/audio/#{story_id}/.", "#{mediaPath}/audio"
      end
      if File.directory?("#{Rails.root}/public/system/places/slideshow/#{story_id}/.")
        FileUtils.cp_r "#{Rails.root}/public/system/places/slideshow/#{story_id}/.", "#{mediaPath}/slideshow"
      end
      @export = true

      File.open("#{path}/index.html", "w"){|f| f << render_to_string('storyteller/index', :layout => false) }  
      send_file generate_gzip(path,"#{filename}_#{filename_ext}",filename), :type=>"application/x-gzip", :filename=>"#{filename}.tar.gz"
      
      # if File.directory?(path)
      #   FileUtils.remove_dir(path,true)   
      # end

      # if File.exists?("#{path}.tar.gz")    
      #   FileUtils.remove_file("#{path}.tar.gz",true)   
      # end
    rescue
       flash[:error] =I18n.t("app.msgs.error_export")                           
       redirect_to stories_url
    end   
  end
 
  def clone
    begin
  Story.transaction do
    @item = Story.find_by_id(params[:id])
    dup = @item.amoeba_dup
    dup.title = "#{dup.title} (Clone)"
    dup.reset_fields_for_clone
    dup.save

     @item.sections.each_with_index do |s,s_i|
        if s.asset.present?
          dup.sections[s_i].asset = Asset.new(asset_type: Asset::TYPE[:section_audio], item_id: dup.sections[s_i].id, asset:s.asset.asset)
        end
      
        if s.type_id == Section::TYPE[:media]
          s.media.each_with_index do |m,m_i|
             dup.sections[s_i].media[m_i].image = Asset.new(asset_type: Asset::TYPE[:media_image], item_id: dup.sections[s_i].media[m_i].id, asset: m.image.asset)          
            if m.media_type == Medium::TYPE[:video]      
              dup.sections[s_i].media[m_i].video = Asset.new(asset_type: Asset::TYPE[:media_video], item_id: dup.sections[s_i].media[m_i].id, asset: m.video.asset)                        
            end
          end
        elsif s.type_id == Section::TYPE[:slideshow]
            s.slideshow.assets.each_with_index do |m,m_i|  
              dup.sections[s_i].slideshow.assets<< Asset.new(asset_type: Asset::TYPE[:slideshow_image], item_id: dup.sections[s_i].slideshow.id, asset: m.asset, caption: m.caption, source: m.source)                  
            end
        end               
       end
       dup.save
        flash[:success] =I18n.t("app.msgs.success_clone", obj:"#{Story.model_name.human} \"#{@item.title}\"", to: "#{dup.title}")    
        end
    rescue => e
      flash[:error] =I18n.t("app.msgs.error_clone", obj:"#{Story.model_name.human} \"#{@item.title}\"")                      
    end
   
    respond_to do |format| 
      format.js {render json: nil, status: :ok }
      format.html { redirect_to stories_url }
   end
  end


  # check if this permalink is not already in use
  # - if id is passed in, the story record is loaded and the permalink is created in that record
  #   so it will not cause a duplicate error
  # params passed in are text and id
  def check_permalink
    output = {:permalink => nil, :is_duplicate => false}
    if params[:text].present?
      story = Story.select('permalink, permalink_staging').where(:id => params[:id]).limit(1).first
      # if the story could not be found, use an empty story
      if story.blank?
        story = Story.new(:permalink_staging => params[:text]) 
        story.generate_permalink
        output = {:permalink => story.permalink, :is_duplicate => story.is_duplicate_permalink?}
      # if the permalink is the same, do nothing
      elsif story.permalink_staging.downcase == params[:text].strip.downcase
        output[:permalink] = story.permalink
      # permalink is different, so create a new one
      else
        story.permalink_staging = params[:text]
        story.generate_permalink!
        output = {:permalink => story.permalink, :is_duplicate => story.is_duplicate_permalink?}
      end
    end
          
    respond_to do |format|     
      format.json { render json: output } 
    end
  end 


  # search for existing tags
  def tag_search
    tags = Story.all_tag_counts.by_tag_name(params[:q]).token_input_tags

    respond_to do |format|
      format.json { render json: tags }
    end
  end
  
  def collaborators
    @story = Story.find_by_id(params[:id])

    if @story.present?
      user_with_errors = []
      sending_invitations = false
      msgs = []
      
      if params[:collaborator_ids].present? && request.post?
        sending_invitations = true  

        # split out the ids
        c_ids = params[:collaborator_ids].split(',')
        
        # pull out the user ids for existing users (numbers)
        user_ids = c_ids.select{|x| x =~ /^[0-9]+$/ }
        
        # pull out the email addresses for new users (not numbers)
        emails = c_ids.select{|x| x !~ /^[0-9]+$/ }.map{|x| x.gsub("'", '')}
        
        # send invitation for each existing user
        if user_ids.present?
          user_ids.each do |user_id|
            Rails.logger.debug "_______________user id = #{user_id}"
            user = User.find_by_id(user_id)
            if user.present?
              msg = create_invitation(@story, user.id, user.email, params[:message])
              Rails.logger.debug "-------------- msg = #{msg}"
              if msg.blank?
    		        # remove id from list
    		        c_ids.delete(user_id)
    		      else
    		        # record the user with the error so that it can be re-displayed in the list
      		      user_with_errors << {id: user.id, name: user.nickname, img_url: user.avatar_url(:'50x50') }
      		      msgs << "'#{user.nickname}' - #{msg.join(', ')}"
              end
            end  
          end
        end
                   
        # send invitation for new users
        if emails.present?
          emails.each do |email|          
            Rails.logger.debug "_____________email = #{email}"
            msg = create_invitation(@story, nil, email, params[:message])
            Rails.logger.debug "-------------- msg = #{msg}"
            if msg.blank?
  		        # remove email from list
  		        c_ids.delete(email)
  		      else
  		        # record the user with the error so that it can be re-displayed in the list
    		      user_with_errors << {id: email, name: email }
    		      msgs << "'#{email}' - #{msg.join(', ')}"
  		      end
          end
        end
      end 

      # if not all ids were processed for invitations
      # record them so they can be shown in the list again
      params[:collaborator_error_ids] = user_with_errors
      
      if sending_invitations && user_with_errors.present?
        if user_with_errors.length == c_ids.length
          flash[:error] = t('app.msgs.collaborators.error_invitations_all', :msg => msgs.join('; '))
        else
          flash[:error] = t('app.msgs.collaborators.error_invitations_some', :msg => msgs.join('; '))
        end
      elsif sending_invitations
        flash[:success] = t('app.msgs.collaborators.success_invitations')
        params[:message] = ''
      end

      # get the invitations on file
      # - have this at the bottom here so any new invitations that were saved will be pulled
      @invitations = Invitation.pending_by_story(@story.id)

      set_settings_gon

      respond_to do |format|
        format.html
      end
    else
      redirect_to stories_path, :notice => t('app.msgs.does_not_exist')
    end
  end
  
  def collaborator_search
    output = nil
    story = Story.find_by_id(params[:id])
    if story.present?
      users = story.user_collaboration_search(params[:q])
      # format for token input js library [{id,name}, ...]    
      output = users.map{|x| {id: x.id, name: x.nickname, img_url: x.avatar_url(:'50x50') } }
    end  
    
    respond_to do |format|
      format.json { render json: output.to_json }
    end
  end
  
  # remove a collaborator from a story
  # - must be story owner to remove
  def remove_collaborator
    story = Story.find_by_id(params[:id])
		msg = ''
		has_errors = false
  
    if story.user_id == current_user.id
      user = User.find_by_id(params[:user_id])
      if user.present?
        story.users.delete(user)
        msg = I18n.t('app.msgs.collaborators.success_remove', :name => user.nickname)
      else
        msg = I18n.t('app.msgs.collaborators.user_not_found')
    		has_errors = true
      end
    else
      msg = I18n.t('app.msgs.collaborators.no_permission')
  		has_errors = true
    end
  
    respond_to do |format|
      format.json { render json: {msg: msg, success: !has_errors} }
    end
  end
  
  # remove an invitation from a story
  # - must be story owner to remove
  def remove_invitation
    story = Story.find_by_id(params[:id])
		msg = ''
		has_errors = false
  
    if story.user_id == current_user.id
      if params[:user_id].present?
        Invitation.delete_invitation(params[:id], params[:user_id])
        msg = I18n.t('app.msgs.collaborators.success_remove', :name => params[:user_id])
      else
        msg = I18n.t('app.msgs.collaborators.user_not_found')
    		has_errors = true
      end
    else
      msg = I18n.t('app.msgs.collaborators.no_permission')
  		has_errors = true
    end
  
    respond_to do |format|
      format.json { render json: {msg: msg, success: !has_errors} }
    end
  end
  
  
private

  def can_edit_story?(story_id)
    redirect_to root_path, :notice => t('app.msgs.not_authorized') if !Story.can_edit?(story_id, current_user.id)
  end

  def flash_success_created( obj, title)
#      flash[:success] = u I18n.t('app.msgs.success_created', obj:"#{obj} \"#{title}\"")
      flash[:success] = I18n.t('app.msgs.success_created', obj:"#{obj} \"#{title}\"")
  end
  def flash_success_updated( obj, title)
#      flash[:success] = u I18n.t('app.msgs.success_updated', obj:"#{obj} \"#{title}\"")
      flash[:success] = I18n.t('app.msgs.success_updated', obj:"#{obj} \"#{title}\"")
  end

  def generate_gzip(tar,name,ff)      
      system("tar -czf #{tar}.tar.gz -C '#{Rails.root}/tmp/stories/#{name}' .")
      return "#{tar}.tar.gz"
  end

  def asset_filter
    @css.push("stories.css", "embed.css", "modalos.css", "bootstrap-select.min.css", "token-input-facebook.css","navbar.css", "filter.css", "tipsy.css")
    @js.push("stories.js", "modalos.js", "olly.js", "bootstrap-select.min.js", "jquery.tokeninput.js", "zeroclipboard.min.js", "filter.js", "jquery.tipsy.js")
  end 
  
  def create_invitation(story, user_id=nil, email=nil, msg=nil)
		error_msg = nil

    if story.present? && (user_id.present? || email.present?)
      # see if invitation already exists
      existing_inv = Invitation.where(:story_id => story.id, :to_email => email)
      if existing_inv.present?
        Rails.logger.debug "@@@@@ invitation already exists, ignoring"
        # already sent, so ignore
        return true
      end

      # save the invitation
      inv = Invitation.new
      inv.story_id = story.id
      inv.from_user_id = current_user.id
      inv.to_user_id = user_id
      inv.to_email = email
      inv.message = msg if msg.present?

      if !inv.save
        Rails.logger.debug "========= message error = #{message.errors.full_messages}"
          error_msg = message.errors.full_messages
      end
    end
    
    return error_msg
  end
  
  def set_form_gon
    gon.fail_change_order = I18n.t('app.msgs.fail_change_order')
    gon.nothing_selected = I18n.t('app.msgs.nothing_selected')
    gon.fail_delete = I18n.t('app.msgs.fail_delete')
    gon.confirm_delete = I18n.t('app.msgs.confirm_delete')
    gon.tokeninput_collaborator_hintText = I18n.t('tokeninput.collaborator.hintText')
    gon.tokeninput_collaborator_noResultsText = I18n.t('tokeninput.collaborator.noResultsText')
    gon.tag_search = story_tag_search_path
    gon.tokeninput_tag_hintText = I18n.t('tokeninput.tag.hintText')
    gon.tokeninput_tag_noResultsText = I18n.t('tokeninput.tag.noResultsText')
    gon.tokeninput_searchingText = I18n.t('tokeninput.searchingText')
  end

  
  def set_settings_gon
    gon.collaborator_search = story_collaborator_search_path(params[:id])
  end
end       

