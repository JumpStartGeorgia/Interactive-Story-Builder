class StoriesController < ApplicationController
  before_filter :authenticate_user!, :except => [:review]
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:coordinator])
  end
  before_filter(:except => [:index,:new, :create, :check_permalink, :tag_search, :collaborator_search, :review]) do |controller_instance|  
    controller_instance.send(:can_edit_story?, params[:id])
  end
  before_filter(:except => [:index, :preview, :check_permalink, :tag_search, :collaborator_search, :review]) do |controller_instance|  
    controller_instance.send(:can_edit_story_locale?)
  end
  before_filter(:except => [:index, :preview, :check_permalink, :tag_search, :collaborator_search, :review]) do |controller_instance|  
    controller_instance.send(:can_access_action?)
  end
  before_filter :asset_filter
  before_filter :set_form_gon


  # GET /stories
  # GET /stories.json
  def index    
    @css.push("navbar.css", "filter.css", "grid.css","author.css")
    @js.push("zeroclipboard.min.js","filter.js","stories.js") 
    @stories =  process_filter_querystring(Story.editable_stories(current_user.id).paginate(:page => params[:page], :per_page => per_page))           
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
    @item = Story.new(:user_id => current_user.id, :locale => current_user.default_story_locale)     
    # @item.build_asset(:asset_type => Asset::TYPE[:story_thumbnail])  
    logger.debug("------------------------------------------------#{@item.inspect}"  )
#    @templates = Template.select_list
#    @story_tags = []
    @themes = Theme.sorted
    @authors = Author.sorted
    @new = true
    respond_to do |format|
        format.html #new.html.er
        format.json { render json: @item }
    end
  end

  # GET /stories/1/edit
  def edit
    @item = Story.find(params[:id])
    # if !@item.asset_exists?
    #   @item.build_asset(:asset_type => Asset::TYPE[:story_thumbnail])
    # end 
#    @templates = Template.select_list(@item.template_id)
#    @story_tags = @item.tags.token_input_tags
    @themes = Theme.sorted
    @authors = Author.sorted
  end

  # POST /stories
  # POST /stories.json
  def create
    @item = Story.new(params[:story])

    respond_to do |format|

      if @item.save
        @item.reload      
        @item.with_translation(params[:current_locale])
        @item.current_locale = params[:current_locale]
        flash_success_created(Story.model_name.human,@item.title)       
        format.html { redirect_to sections_story_path(@item) }
      #  format.json { render json: @item, status: :created, location: @item }
      else
        # if !@item.asset.present? 
        #   @item.build_asset(:asset_type => Asset::TYPE[:story_thumbnail])
        # end      
        #@templates = Template.select_list(@item.template_id) 
#        @story_tags = @item.tags.token_input_tags
        @item.current_locale = @item.story_locale
        @themes = Theme.sorted
        @authors = Author.sorted
        @new = true
        flash[:error] = I18n.t('app.msgs.error_created', obj:Story.model_name.human, err:@item.errors.full_messages.to_sentence)     
        format.html { render action: "new" }
        #  format.json { render json: @item.errors, status: :unprocessable_entity }
        #  format.js {render action: "flash" , status: :ok }
      end
    end
  end

  # PUT /stories/1
  # PUT /stories/1.json
  def update
    @item = Story.find(params[:id])
  
    respond_to do |format|
      if !@item.published && params[:story][:published]=="1"
        if !@item.about.present? || !@item.asset_exists?
          flash[:error] = I18n.t('app.msgs.error_publish_missing_fields', :obj => @item.title)            
        elsif @item.sections.map{|t| t.content? && t.content.present? && t.content.text.present? }.count(true) == 0
          flash[:error] = I18n.t('app.msgs.error_publish_missing_content_section')            
        end                      
        format.html { render action: "edit" }
        format.js {render action: "flash" , status: :ok }
      else
        if @item.update_attributes(params[:story])
          @item.reload      
          @item.with_translation(params[:current_locale])
          @item.current_locale = params[:current_locale]
          flash_success_updated(Story.model_name.human,@item.title)       
          format.html { redirect_to  sections_story_path(@item) }
          format.js { render action: "flash", status: :created }    
        else
          # if !@item.asset.present? 
          #   @item.build_asset(:asset_type => Asset::TYPE[:story_thumbnail])
          # end 
          #@templates = Template.select_list(@item.template_id)
#          @story_tags = @item.tags.token_input_tags
          @item.current_locale = @item.story_locale
          @themes = Theme.sorted
          @authors = Author.sorted
logger.debug "$$$$$$$$$$$$44 story update error: #{@item.errors.full_messages.to_sentence}"          
          flash[:error] = I18n.t('app.msgs.error_updated', obj:Story.model_name.human, err:@item.errors.full_messages.to_sentence)            
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
        Rails.logger.debug("--------------------------------------------------- storyteller_show_path")
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
    if @story.present?
      # set story locale 
      # if param exists use that
      # else check if translation exists for current app locale
      if params[:story_language].present?
        @story.current_locale = params[:story_language] 
      else
        @story.use_app_locale_if_translation_exists
      end

logger.debug "$$$$$$$$$$$ story current locale = #{@story.current_locale}; permalink = #{@story.permalink}"
    end

    respond_to do |format|  
      #if(@story.present?)   
        format.html { render 'storyteller/index', layout: false }
      #else 

      #end
    end
  end
# load the item (i.e., Section.find_by_id)
# call: item.with_translation(locale), where locale is the locale to get text for
# In partial, add the following do block before you use any of the fields: 
# Globalize.with_locale(locale) do
#   # form field stuff here
#   # @item.title
# end

  def get_data

    id = params[:id]
    method = params[:method]
    type = params[:type]
    _id = params[:_id]
    sub_id = params[:sub_id]
    @which = params[:which].present? ? params[:which].to_i : 1
    @trans = false
    @from = I18n.locale
    @to = nil
    @story = Story.find_by_id(id) 

    if @story.present?     # if story exists, set some params
      @from = @story.story_locale # set default locale to story locale
      if params.has_key?(:tr) # get the translation locales
        @trans = true
        @from = params.has_key?(:tr_from) ? params[:tr_from] : @story.present? ? @story.story_locale : @from
        @to = params.has_key?(:tr_to) ? params[:tr_to] : @languages.select{|x| x.locale != @story.story_locale}.first.locale
      end
    end
    Rails.logger.debug("-----------------------------------------------#{@which}#{@trans}#{@from}#{@to}#{@story}------------")
    if type == 'story'
      if method=='select'
        @item = @story 
        # if !@item.asset_exists?
        #   @item.build_asset(:asset_type => Asset::TYPE[:story_thumbnail])
        # end    
      elsif method=='create'
        @item = Story.new(:user_id => current_user.id, :story_locale => defualt_locale)     
        # @item.build_asset(:asset_type => Asset::TYPE[:story_thumbnail])    
      end
      @themes = Theme.sorted   
      @authors = Author.sorted
      type = 'form'           
    elsif type == 'section'
      if method=='select'
        @item = Section.find_by_id(_id)    
      else 
        @item = Section.new(story_id: id, has_marker: 0)
      end        
      # if @item.present? && !@item.asset_exists?
      #     @item.build_asset(:asset_type => Asset::TYPE[:section_audio])
      # end   
    elsif type == 'content'
      if method=='select'
        @item = Content.find_by_id(sub_id)
      else 
        @item = Content.new(:section_id => _id)
      end
    elsif type == 'media'
      if method=='select'    
        @item = Medium.find_by_id(sub_id)   
      else 
        @item = Medium.new(:section_id => _id, media_type: Medium::TYPE[:image])
      end

      # if @item.present? &&  !@item.image_exists? 
      #   @item.build_image(:asset_type => Asset::TYPE[:media_image])
      # end   
      # if @item.present? && !@item.video_exists?
      #   @item.build_video(:asset_type => Asset::TYPE[:media_video])
      # end      
    elsif type == 'slideshow'
      if method=='select'    
        @item = Slideshow.find_by_id(sub_id)           
      else 
        @item = Slideshow.new(:section_id => _id)
      end
     # if @item.present? && @item.assets.blank?
     #    @item.assets.build(:asset_type => Asset::TYPE[:slideshow_image])
     #  end          
    elsif type == 'embed_media'
      if method=='select'    
        @item = EmbedMedium.find_by_id(sub_id)   
      else 
        Rails.logger.debug(_id)
        @item = EmbedMedium.new(:section_id => _id)
      end  
    elsif type == 'youtube'
      if method=='select'    
        @item = Youtube.find_by_id(sub_id)   
      else 
        @item = Youtube.new(:section_id => _id)
        # @item.youtube_translations.build(:locale => I18n.locale.to_s)
      end
    end

    respond_to do |format|
      if @item.present? 
        @type = type       
        @item.translations_for([@from,@to]) # get the translations for this item or build it if not exist yet
        @item.current_locale = @from
      else
        @error = I18n.t('app.msgs.error_get_data')
      end
      format.js
    end
  end

  def new_section
    @item = Section.new(params[:section])  
     respond_to do |format|
        if @item.save   
          @item.reload      
          @item.with_translation(params[:current_locale])
          @item.current_locale = params[:current_locale]
          #Rails.logger.debug "######### new_media save error: #{@item.translations.inspect}"
          flash_success_created(Section.model_name.human,@item.title)          
          @select_next = params[:commit_and_next].present? ? true : false             
          format.js { render action: "change_tree", status: :created  }
        else          
          flash[:error] = u I18n.t('app.msgs.error_created', obj:Section.model_name.human, err:@item.errors.full_messages.to_sentence)                  
          format.js {render action: "flash" , status: :ok }
        end
      end    
  end

  def new_item   
    if params[:content].present?
      @item = Content.new(params[:content])   
      @type = 'content'
    elsif params[:medium].present?
      @item = Medium.new(params[:medium])   
      #Rails.logger.debug "######### image valid: #{@item.image.valid?}; image validations: #{@item.image.errors.full_messages.to_sentence}" if @item.image.present?
      #Rails.logger.debug "######### video valid: #{@item.video.valid?}; video validations: #{@item.video.errors.full_messages.to_sentence}" if @item.video.present?
    elsif params[:slideshow].present?
      @item = Slideshow.new(params[:slideshow])    
    elsif params[:embed_medium].present?
      @item = EmbedMedium.new(params[:embed_medium])  
    elsif params[:youtube].present?  
      @item = Youtube.new(params[:youtube])     
    end
    respond_to do |format|
      if @item.save
        @item.reload      
        @item.with_translation(params[:current_locale])
        @item.current_locale = params[:current_locale]
        flash_success_created(@item.class.model_name.human,@item.title)  
        @select_next = params[:commit_and_next].present? ? true : false                     
        format.js { render action: "change_sub_tree", status: :created  }
      else
        logger.debug "@@@@@@@@@@@@@@@ error = #{@item.errors.full_messages.to_sentence}"
        flash[:error] = u I18n.t('app.msgs.error_created', obj:@item.class.model_name.human, err:@item.errors.full_messages.to_sentence)                  
        format.js {render action: "flash" , status: :ok }
      end
    end    
  end


  def save_section       
    @item = Section.find_by_id(params[:section][:id]) 
#logger.debug "+++++++++++++ delete attribute = #{params[:section][:asset_attributes][:delete_asset]}"
    respond_to do |format|
      if @item.present?
        if @item.update_attributes(params[:section].except(:id))
          @item.reload      
          @item.with_translation(params[:current_locale])
          @item.current_locale = params[:current_locale]          
          flash_success_updated(Section.model_name.human,@item.title)
          @select_next = params[:commit_and_next].present? ? true : false     
          format.js {render action: "build_tree", status: :created }                  
        else
          flash[:error] = u I18n.t('app.msgs.error_updated', obj:Section.model_name.human, err:@item.errors.full_messages.to_sentence)                            
          format.js {render action: "flash", status: :ok }
        end
      else
        flash[:error] = u I18n.t('app.msgs.not_found_for_update')                            
        format.js {render action: "flash", status: :ok }
      end
    end    
  end
  def save_item 

    if params[:content].present?
      klass = Content
      type = :content
    elsif params[:medium].present?
      klass = Medium
      type = :medium
      #Rails.logger.debug "######### image valid: #{@item.image.valid?}; image validations: #{@item.image.errors.full_messages.to_sentence}" if @item.image.present?
      #Rails.logger.debug "######### video valid: #{@item.video.valid?}; video validations: #{@item.video.errors.full_messages.to_sentence}" if @item.video.present?
    elsif params[:slideshow].present?
      klass = Slideshow
      type = :slideshow
    elsif params[:embed_medium].present?
      klass = EmbedMedium
      type = :embed_medium
    elsif params[:youtube].present?  
      klass = Youtube
      type = :youtube
    end   
     @item = klass.find_by_id(params[type][:id]) 
     respond_to do |format|
      if @item.present?
        if @item.update_attributes(params[type].except(:id))     
          @item.reload      
          @item.with_translation(params[:current_locale])
          @item.current_locale = params[:current_locale]     
          flash_success_updated(@item.class.model_name.human,@item.title)    
          @select_next = params[:commit_and_next].present? ? true : false       
          format.js {render action: "build_tree", status: :created }                  
        else
          flash[:error] = u I18n.t('app.msgs.error_updated', obj:@item.class.model_name.human, err:@item.errors.full_messages.to_sentence)                                      
          format.js {render action: "flash" , status: :ok }
        end
      else
        flash[:error] = u I18n.t('app.msgs.not_found_for_update')                            
        format.js {render action: "flash", status: :ok }
      end
    end    
  end


  def destroy_tree_item  
    item = nil    
    type = params[:type]

    if type == 'section'
      item = Section.find_by_id(params[:_id])               
    elsif type == 'content'
      item =  Content.find_by_id(params[:sub_id])      
    elsif type == 'media'
      item = Medium.find_by_id(params[:sub_id])
    elsif type == 'slideshow'
      item = Slideshow.find_by_id(params[:sub_id])    
    elsif type == 'youtube'
      item = Youtube.find_by_id(params[:sub_id])                       
    end

    item.destroy if item.present?
    
    respond_to do |format|
      if !item.present?
         flash[:error] = I18n.t('app.msgs.destroy_item.error_not_found')
         format.json { render json: nil, status: :created } 
      elsif item.destroyed?   
          flash[:success] = I18n.t('app.msgs.destroy_item.success')
          format.json { render json: { e:false } , status: :created } 
      else  
         flash[:error] = I18n.t('app.msgs.destroy_item.error', :err => @item.errors.full_messages.to_sentence)
         format.json {render json: { e:true } , status: :ok }  
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


  def sections
    #Rails.logger.debug("---------------------------------------------#{params.inspect}")
    @story = Story.fullsection(params[:id])   
    @tr = params.has_key?(:tr) ? params[:tr].to_bool : false
    @from  = @story.story_locale
    if @tr
      @from  = params.has_key?(:tr_from) ? params[:tr_from] : @story.story_locale
      @to    = params.has_key?(:tr_to) ? params[:tr_to] : @languages.select{|x| x.locale != @story.story_locale}.first.locale
      gon.translate_from = @from
      gon.translate_to = @to
      gon.translate = true
      #Rails.logger.debug("---------------------------------------------#{@tr} #{@tr_from} #{@tr_to}")
    end
    @story.with_translation(@from) # get the translations for this item or build it if not exist yet
    @story.current_locale = @from

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
                  view_context.log(@item.sections.map{|t| t.content? && t.content.present? && t.content.text.present? }.count(true) )
           format.json {render json: { e:true, msg: (t('app.msgs.error_publish_missing_fields', :obj => @item.title) +  
                " <a href='" +  sections_story_path(@item) + "'>" + t('app.msgs.error_publish_missing_fields_link') + "</a>")} }  
           error = true       
        elsif @item.sections.map{|t| t.content.present? && t.content.text.present? }.count(true) == 0          
           format.json {render json: { e:true, msg: t('app.msgs.error_publish_missing_content_section')} }          
           error = true
        end            
      end


      if !error 
        if @item.update_attributes(published: publishing)     
          flash[:success] =u I18n.t("app.msgs.success_#{publishing ? '' :'un'}publish", obj:"#{Story.model_name.human} \"#{@item.title}\"")                   

          title = publishing ? t('helpers.links.story_menu.title.unpublish') : t('helpers.links.story_menu.title.publish') 
          link = publishing ? t('helpers.links.story_menu.link.unpublish') : t('helpers.links.story_menu.link.publish') 

          #pub_title = link_text + ' ' + title #@item.published ? I18n.t("app.buttons.unpublish")  : I18n.t("app.buttons.publish")                    
          format.json {render json: { title: title , link: link }, status: :ok }
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

      FileUtils.mkpath(path)    
      FileUtils.cp_r "#{Rails.root}/public/media/story/.", "#{path}"  
      
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
      if File.directory?("#{Rails.root}/public/system/places/thumbnail/#{story_id}/thumbnail/.")
          FileUtils.mkpath("#{mediaPath}/thumbnail")    
          FileUtils.cp_r "#{Rails.root}/public/system/places/thumbnail/#{story_id}/thumbnail/.", "#{mediaPath}/thumbnail"
      end
      if File.directory?("#{Rails.root}/public/system/places/images/#{story_id}/.")
          FileUtils.mkpath("#{mediaPath}/images")    
          FileUtils.cp_r "#{Rails.root}/public/system/places/images/#{story_id}/.", "#{mediaPath}/images"
      end
      if File.directory?("#{Rails.root}/public/system/places/video/#{story_id}/.")
        FileUtils.mkpath("#{mediaPath}/video" )
        FileUtils.cp_r "#{Rails.root}/public/system/places/video/#{story_id}/.", "#{mediaPath}/video"  
      end
      if File.directory?("#{Rails.root}/public/system/places/audio/#{story_id}/.")
        FileUtils.mkpath("#{mediaPath}/audio")
        FileUtils.cp_r "#{Rails.root}/public/system/places/audio/#{story_id}/.", "#{mediaPath}/audio"
      end
      if File.directory?("#{Rails.root}/public/system/places/slideshow/#{story_id}/.")
        FileUtils.mkpath("#{mediaPath}/slideshow")
        FileUtils.cp_r "#{Rails.root}/public/system/places/slideshow/#{story_id}/.", "#{mediaPath}/slideshow"
      end
      @export = true

      File.open("#{path}/index.html", "w"){|f| f << render_to_string('storyteller/index', :layout => false) }  
      send_file generate_gzip(path,"#{filename}_#{filename_ext}",filename), :type=>"application/x-gzip", :filename=>"#{filename}.tar.gz"
      
    rescue Exception => e      
       flash[:error] =I18n.t("app.msgs.error_export")       
       ExceptionNotifier::Notifier.exception_notification(request.env, e).deliver
       redirect_to stories_url
    end   
  end
 
  def clone
    had_error = false
    exception = nil
    begin
      Story.transaction do
        @item = Story.find(params[:id])
        dup = @item.clone_story

        if dup.valid?
          flash[:success] =I18n.t("app.msgs.success_clone", obj:"#{Story.model_name.human} \"#{@item.title}\"", to: "#{dup.title}")    
        else
          raise I18n.t('app.msgs.error_clone_notification', msg: dup.errors.full_messages)
        end
      end
    rescue => e
      had_error = true
      exception = e
    end
   
    # if error occurred send email notification
    if had_error
      ExceptionNotifier::Notifier
        .exception_notification(request.env, exception)
        .deliver
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
      permalink_staging = params[:text]
      permalink_temp = permalink_normalize(permalink_staging)
      story = StoryTranslation.select('permalink, permalink_staging').where(:story_id => params[:id]).limit(1).first
      # if the story could not be found, use an empty story
      logger.debug "*********** new staging = #{permalink_staging}; story = #{story.inspect}"
      if story.blank?
        logger.debug "*********** story blank"
        story = StoryTranslation.new(:permalink_staging => permalink_staging)
        story.generate_permalink
        output = {:permalink => story.permalink, :is_duplicate => story.is_duplicate_permalink?}
        
      # if the permalink is the same, do nothing
      elsif story.permalink == permalink_temp
        logger.debug "*********** permalink same"
        output[:permalink] = story.permalink
        
      # permalink is different, so create a new one
      else
        logger.debug "*********** permalink different"
        story.permalink_staging = permalink_staging
        logger.debug "*********** - story = #{story.inspect}"
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
      sending_invitations = false
      user_with_errors = {editors: [], translators: []}
      msgs = {editors: [], translators: []}
      ids = {editors: [], translators: []}
      
      if request.post?
        sending_invitations = true  

        if params[:editor_ids].present?
          user_with_errors[:editors], msgs[:editors], ids[:editors] = process_editor_invitations(params[:editor_ids], params[:message])
        end

        if params[:translators].present?
          user_with_errors[:translators], msgs[:translators], ids[:translators] = process_translator_invitations(params[:translators], params[:message])
        end
      end 

      # if not all ids were processed for invitations
      # record them so they can be shown in the list again
      params[:editor_error_ids] = user_with_errors[:editors]
      params[:translator_error_ids] = user_with_errors[:translators]
      
      if sending_invitations && (user_with_errors[:editors].present? || user_with_errors[:translators].present?)
        flash[:error] = ''
        if user_with_errors[:editors].present?
          if user_with_errors[:editors].length == ids[:editors].length
            flash[:error] << t('app.msgs.collaborators.error_invitations_all', :msg => msgs[:editors].join('; '))
          else
            flash[:error] << t('app.msgs.collaborators.error_invitations_some', :msg => msgs[:editors].join('; '))
          end
        end

        if user_with_errors[:translators].present?
          if user_with_errors[:translators].length == ids[:translators].length
            flash[:error] << t('app.msgs.collaborators.error_invitations_all', :msg => msgs[:translators].join('; '))
          else
            flash[:error] << t('app.msgs.collaborators.error_invitations_some', :msg => msgs[:translators].join('; '))
          end
        end
      elsif sending_invitations
        flash[:success] = t('app.msgs.collaborators.success_invitations')
        params[:message] = ''
      end

      # - have this at the bottom here so any new invitations that were saved will be pulled
      @editors = @story.story_users.editors.sorted
      @translators = @story.story_users.translators.sorted
      @editor_invitations = Invitation.editors.pending_by_story(@story.id)
      @translator_invitations = Invitation.translators.pending_by_story(@story.id)

      set_settings_gon

      @css.push("collaborators.css")
      @js.push("collaborators.js")

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
  def remove_collaborator
    story = Story.find_by_id(params[:id])
		msg = ''
		has_errors = false
  
    user = User.find_by_id(params[:user_id])
    if user.present?
      story.users.delete(user)
      msg = I18n.t('app.msgs.collaborators.success_remove', :name => user.nickname)
    else
      msg = I18n.t('app.msgs.collaborators.user_not_found')
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
  
    if params[:user_id].present?
      Invitation.delete_invitation(params[:id], params[:user_id])
      msg = I18n.t('app.msgs.collaborators.success_remove', :name => params[:user_id])
    else
      msg = I18n.t('app.msgs.collaborators.user_not_found')
  		has_errors = true
    end
  
    respond_to do |format|
      format.json { render json: {msg: msg, success: !has_errors} }
    end
  end
  
  
private

  # if the user is not in StoryUser, stop
  def can_edit_story?(story_id)
    logger.debug "))))))) can edit story check #{story_id}"
    @can_edit_story, @edit_story_role, @edit_translation_locales = Story.can_edit?(story_id, current_user.id)
    redirect_to root_path, :notice => t('app.msgs.not_authorized') if !@can_edit_story
  end

  # if the user is a translator but cannot translate this locale, stop
  # - check for the following locale params
  #   - tr_to - indicates what locale to translate to
  #   - current_locale - indicates form submittal locale 
  def can_edit_story_locale?
    locale = params[:tr_to].present? ? params[:tr_to] : params[:current_locale].present? ? params[:current_locale] : nil
    logger.debug "))))))) can edit story locale check, locale = #{locale}"
    redirect_to root_path, :notice => t('app.msgs.not_authorized') if @edit_story_role == Story::ROLE[:translator] && !@edit_translation_locales.include?(locale.to_s)
  end

  # if the user is a translator, limit their access to actions to editing
  def can_access_action?
    logger.debug "))))))) can access action check, action = #{params[:action]}"
    accessible_actions = [:update, :preview, :get_data, :save_section, :save_content, :save_media, :save_slideshow, :save_embed_media, :save_youtube, :sections, :check_permalink]
    redirect_to root_path, :notice => t('app.msgs.not_authorized') if @edit_story_role == Story::ROLE[:translator] && !accessible_actions.include?(params[:action].to_sym)
  end

  def flash_success_created( obj, title)
      flash[:success] = request.xhr? ? u(I18n.t('app.msgs.success_created', obj:"#{obj} \"#{title}\"")) : I18n.t('app.msgs.success_created', obj:"#{obj} \"#{title}\"")
  end
  def flash_success_updated( obj, title)
    flash[:success] = request.xhr? ? u(I18n.t('app.msgs.success_updated', obj:"#{obj} \"#{title}\"")) : I18n.t('app.msgs.success_updated', obj:"#{obj} \"#{title}\"")
  end

  def generate_gzip(tar,name,ff)      
      system("tar -czf #{tar}.tar.gz -C '#{Rails.root}/tmp/stories/#{name}' .")
      return "#{tar}.tar.gz"
  end

  def asset_filter
    @css.push("stories.css", "embed.css", "modalos.css", "bootstrap-select.min.css", "token-input-facebook.css","navbar.css", "filter.css", "tipsy.css")
    @js.push("stories.js", "modalos.js", "olly.js", "bootstrap-select.min.js", "jquery.tokeninput.js", "zeroclipboard.min.js", "filter.js", "jquery.tipsy.js")
  end 
  
  # process the ids for editor collaboration invitations
  def process_editor_invitations(ids, message)
    logger.debug "__________ PROCESS EDITOR INVITATIONS"
    role = Story::ROLE[:editor]
    user_with_errors = []
    msgs = []

    # split out the ids
    c_ids = ids.split(',')
    
    # pull out the user ids for existing users (numbers)
    user_ids = c_ids.select{|x| x =~ /^[0-9]+$/ }
    
    # pull out the email addresses for new users (not numbers)
    emails = c_ids.select{|x| x !~ /^[0-9]+$/ }.map{|x| x.gsub("'", '')}
    
    logger.debug "__________ user_ids = #{user_ids}"
    logger.debug "__________ emails = #{emails}"

    # send invitation for each existing user
    if user_ids.present?
      user_ids.each do |user_id|
        Rails.logger.debug "_______________user id = #{user_id}"
        user = User.find_by_id(user_id)
        if user.present?
          msg = create_invitation(@story, role, user.id, user.email, message)
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
        msg = create_invitation(@story, role, nil, email, params[:message])
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

    return msgs, user_with_errors, c_ids
  end

  # process the ids for translator collaboration invitations
  # translators is an array of locales and user id/email
  def process_translator_invitations(translators, message)
    logger.debug "__________ PROCESS TRANSLATOR INVITATIONS"
    role = Story::ROLE[:translator]
    user_with_errors = []
    msgs = []
    c_ids = nil

    if translators.present?
      c_ids = translators.values.map{|x| x['id']}
      translators.values.each do |translator|
        user_id = nil
        email = nil
        locals = translator['locale'].join(',')

        if translator['id'].include?('@')
          email = translator['id'].gsub("'", '')
        else
          user_id = translator['id']
        end

        logger.debug "__________ user_id = #{user_id}"
        logger.debug "__________ email = #{email}"

        # send invitation for each existing user
        if user_id.present?
          Rails.logger.debug "_______________user id = #{user_id}"
          user = User.find_by_id(user_id)
          if user.present?
            msg = create_invitation(@story, role, user.id, user.email, message, locals)
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
                   
        # send invitation for new users
        if email.present?
          Rails.logger.debug "_____________email = #{email}"
          msg = create_invitation(@story, role, nil, email, params[:message], locals)
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

    return msgs, user_with_errors, c_ids
  end

  def create_invitation(story, role, user_id=nil, email=nil, msg=nil, translation_locales=nil)
		error_msg = nil

    if story.present? && (user_id.present? || email.present?)
      # see if invitation already exists
      existing_inv = Invitation.where(:story_id => story.id, :to_email => email)
      if existing_inv.present?
        Rails.logger.debug "@@@@@ invitation already exists, ignoring"
        # already sent, so ignore
        return nil
      end

      # save the invitation
      inv = Invitation.new
      inv.story_id = story.id
      inv.role = role
      inv.from_user_id = current_user.id
      inv.to_user_id = user_id
      inv.to_email = email
      inv.message = msg if msg.present?
      inv.translation_locales = translation_locales if translation_locales.present?

      if !inv.save
        Rails.logger.debug "========= message error = #{message.errors.full_messages}"
          error_msg = message.errors.full_messages
      end
    end
    
    return error_msg
  end
  
  def set_form_gon
    gon.fail_change_order = I18n.t('app.msgs.fail_change_order')
    #gon.nothing_selected = I18n.t('app.msgs.nothing_selected') was used on section or item removing , logic changed so doesn't need anymore
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

class Object
  def boolean?
    self.is_a?(TrueClass) || self.is_a?(FalseClass) 
  end
end