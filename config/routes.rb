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
			resources :users
      resources :news
		end
		#get 'tinymce_assets' ,to: 'tinymceassets#index'
		post '/tinymce_assets', to: 'imageuploader#create', as: 'imageuploader'

		resources :stories do	

			member do

				get 'reviewer_key'

				get 'preview'

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

  			end			
		end
		#match '/stories/:id/edit' => 'stories#get_story'

		match "storyteller/:id" => "storyteller#index", as: 'storyteller_show'

		match "review/:id" => "review#index", as: 'review'

		match "demo" => "root#demo", as: 'demo'
		match "news" => "root#news", as: 'news'
		match "news/:id" => "root#news_show", as: 'news_show'
		match 'feedback' => 'root#feedback', :as => 'feedback', :via => [:get, :post]
		match 'todo_list' => 'root#todo_list', :as => 'todo_list'

		root :to => 'root#index'
	  match "*path", :to => redirect("/#{I18n.default_locale}") # handles /en/fake/path/whatever
	end

	match '', :to => redirect("/#{I18n.default_locale}") # handles /
	match '*path', :to => redirect("/#{I18n.default_locale}/%{path}") # handles /not-a-locale/anything

end
