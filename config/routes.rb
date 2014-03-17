BootstrapStarter::Application.routes.draw do
  

	#--------------------------------
	# all resources should be within the scope block below
	#--------------------------------
	scope ":locale", locale: /#{I18n.available_locales.join("|")}/ do

		match '/admin', :to => 'admin#index', :as => :admin, :via => :get
		devise_for :users, :path_names => {:sign_in => 'login', :sign_out => 'logout'}

		namespace :admin do
			resources :users
		end
		
		resources :stories do
			member do
    			get 'sections'    			
    			post 'new_section'
    			post 'new_content'
    			post 'new_media'
    			post 'save_content'
    			post 'save_media'
    			post 'upload_file'
    			get 'get_section'
    			get 'get_content'
    			get 'get_media'
  			end

		end
		root :to => 'root#index'
	  match "*path", :to => redirect("/#{I18n.default_locale}") # handles /en/fake/path/whatever
	end

	match '', :to => redirect("/#{I18n.default_locale}") # handles /
	match '*path', :to => redirect("/#{I18n.default_locale}/%{path}") # handles /not-a-locale/anything

end
