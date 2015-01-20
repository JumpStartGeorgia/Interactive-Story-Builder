BootstrapStarter::Application.routes.draw do

	#--------------------------------
	# all resources should be within the scope block below
	#--------------------------------
	scope ":locale", locale: /#{I18n.available_locales.join("|")}/ do

		match '/admin', :to => 'admin#index', :as => :admin, :via => :get
		#devise_for :users, :path_names => {:sign_in => 'login', :sign_out => 'logout'}
		devise_for :users, :path_names => {:sign_in => 'login', :sign_out => 'logout'},
											 :controllers => {:omniauth_callbacks => "omniauth_callbacks"}

		namespace :admin do
      resources :pages
			resources :users
      resources :news
      resources :languages
      resources :categories
		  resources :story_types
		  resources :themes
		end

		#get 'tinymce_assets' ,to: 'tinymceassets#index'
		post '/tinymce_assets', to: 'imageuploader#create', as: 'imageuploader'

		match "stories/check_permalink" => "stories#check_permalink", as: 'story_check_permalink', :via => :post
		match "stories/tag_search" => "stories#tag_search", as: 'story_tag_search', :via => :post, :defaults => { :format => 'json' }
		match "review/:id" => "stories#review", as: 'review'
		match "stories/:id/collaborator_search" => "stories#collaborator_search", as: 'story_collaborator_search', :via => :post, :defaults => { :format => 'json' }
		match "stories/:id/invite_collaborators" => "stories#invite_collaborators", as: 'story_invite_collaborators', :via => :post, :defaults => { :format => 'json' }
		match "stories/:id/remove_collaborator" => "stories#remove_collaborator", as: 'story_remove_collaborator', :via => :post, :defaults => { :format => 'json' }
		match "stories/:id/remove_invitation" => "stories#remove_invitation", as: 'story_remove_invitation', :via => :post, :defaults => { :format => 'json' }
		match "stories/index" => "stories#index", as: 'index', :via => :post, :defaults => { :format => 'json' }

		resources :stories do	

			member do
	        get 'preview'

	        get 'collaborators'
	        post 'collaborators'

	        get 'get_data'

	        put 'content', to: 'stories#save_content'
	        post 'content', to: 'stories#new_content'

	        delete 'tree', to: 'stories#destroy_tree_item'

	        put 'media', to: 'stories#save_media'
	        post 'media', to: 'stories#new_media'				



	        put 'section', to: 'stories#save_section'
	        post 'section', to: 'stories#new_section'	
	        post 'up', to: 'stories#up'
	        post 'down', to: 'stories#down'	
	        post 'up_slideshow', to: 'stories#up_slideshow'
	        post 'down_slideshow', to: 'stories#down_slideshow'						

	        get 'sections'    	
	        get 'publish', to: 'stories#publish'    		
	        get 'clone', to: 'stories#clone'    
	        get 'export', to: 'stories#export' 		

	        put 'slideshow', to: 'stories#save_slideshow'
	        post 'slideshow', to: 'stories#new_slideshow'


	        put 'embed_media', to: 'stories#save_embed_media'
	        post 'embed_media', to: 'stories#new_embed_media'				

	        put 'youtube', to: 'stories#save_youtube'
	        post 'youtube', to: 'stories#new_youtube'

	        get 'get_embed_code', to: 'stories#get_embed_code'

	        get 'section_translation'
			end			
		end
		#match '/stories/:id/edit' => 'stories#get_story'

#		match "storyteller/:id" => "storyteller#index", as: 'storyteller_show'
#		match "storyteller/:id/staff_pick" => "storyteller#staff_pick", as: 'storyteller_staff_pick'
#		match "storyteller/:id/staff_unpick" => "storyteller#staff_unpick", as: 'storyteller_staff_unpick'

		
    # user settings section
		match "settings" => "settings#index", as: 'settings'
		match "settings/notifications" => "settings#notifications", as: 'settings_notifications'
		match "settings/remove_avatar" => "settings#remove_avatar", as: 'settings_remove_avatar'
		match "settings/check_nickname" => "settings#check_nickname", as: 'settings_check_nickname', :via => :post, :defaults => { :format => 'json' }
		match "settings/invitations" => "settings#invitations", as: 'settings_invitations', :via => :get
		match "settings/invitations/accept/:key" => "settings#accept_invitation", as: 'settings_accept_invitation', :via => :get
		match "settings/invitations/decline/:key" => "settings#decline_invitation", as: 'settings_decline_invitation', :via => :get
		match "settings/follow_user" => "settings#follow_user", as: 'settings_follow_user', :via => :post, :defaults => { :format => 'json' }
		match "settings/unfollow_user" => "settings#unfollow_user", as: 'settings_unfollow_user', :via => :post, :defaults => { :format => 'json' }

    # root pages
		match "about" => "root#about", as: 'about'
		match "author/:user_id" => "root#author", as: 'author'
		match "embed/:story_id" => "root#embed", as: 'embed'		
		match "feed" => "root#feed", as: 'feed', :format => 'atom'
		match "theme/:id" => "root#theme", as: 'theme'
		match "type/:id" => "root#story_type", as: 'story_type'



    # published story url/actions
    match ":id" => "storyteller#index", as: 'storyteller_show'
		match ":id/staff_pick" => "storyteller#staff_pick", as: 'storyteller_staff_pick', :defaults => { :format => 'json' }
		match ":id/staff_unpick" => "storyteller#staff_unpick", as: 'storyteller_staff_unpick', :defaults => { :format => 'json' }
		match ":id/like" => "storyteller#like", as: 'storyteller_like', :defaults => { :format => 'json' }
		match ":id/unlike" => "storyteller#unlike", as: 'storyteller_unlike', :defaults => { :format => 'json' }
		match ":id/record_comment" => "storyteller#record_comment", as: 'storyteller_record_comment', :defaults => { :format => 'json' }

		root :to => 'root#index'
	  match "*path", :to => redirect("/#{I18n.default_locale}") # handles /en/fake/path/whatever

	end

	match '', :to => redirect("/#{I18n.default_locale}") # handles /
	match '*path', :to => redirect("/#{I18n.default_locale}/%{path}") # handles /not-a-locale/anything

end
