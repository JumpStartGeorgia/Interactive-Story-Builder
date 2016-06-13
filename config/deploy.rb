####################################################################
##### SET ALL VARIABLES UNDER config/deploy/env.rb             #####
####################################################################

set :stages, %w(production staging)
set :default_stage, "staging" # if just run 'cap deploy' the staging environment will be used
set :whenever_command, "bundle exec whenever" # must use bundle exec
set :whenever_environment, defer { stage } # get it to work with stages

require 'capistrano/ext/multistage' # so we can deploy to staging and production servers
require "bundler/capistrano" # Load Bundler's capistrano plugin.
require "whenever/capistrano" # whenever gem to update crontab

# these vars are set in deploy/env.rb
#set :user, "placeholder"
#set :application, "placeholder"

set(:deploy_to) {"/home/#{user}/#{application}"}

set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set(:branch) {"#{git_branch_name}"}
set(:repository) {"git@github.com:#{github_account_name}/#{github_repo_name}.git"}

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :keep_releases, 2
after "deploy", "deploy:cleanup" # remove the old releases


namespace :deploy do
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command, roles: :app, except: {no_release: true} do
      run "/etc/init.d/unicorn_#{application} #{command}"
    end
  end

  task :setup_config, roles: :app do
    sudo "ln -nfs #{current_path}/config/deploy/#{ngnix_conf_file_loc} /etc/nginx/sites-enabled/#{application}"
    sudo "ln -nfs #{current_path}/config/deploy/#{unicorn_init_file_loc} /etc/init.d/unicorn_#{application}"
    run "mkdir -p #{shared_path}/config"
    put File.read("config/database.example.yml"), "#{shared_path}/config/database.yml"
    puts "Now edit the config files in #{shared_path}."
  end
  after "deploy:setup", "deploy:setup_config"

  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
		puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
		puts "If this is first time, be sure to run the following so app starts on server bootup: sudo update-rc.d unicorn_#{application} defaults"
		puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
  end
  after "deploy:finalize_update", "deploy:symlink_config"

  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/#{git_branch_name}`
      puts "WARNING: HEAD is not the same as origin/#{git_branch_name}"
      puts "Run `git push` to sync changes."
      exit
    end
  end
  before "deploy", "deploy:check_revision"

  task :folder_cleanup, roles: :app do
#		logger.info "cleaning up release/db"
#		run "rm -rf #{release_path}/db/*"
		logger.info "cleaning up release/.git"
		run "rm -rf #{release_path}/.git"
  end
  after "deploy:cleanup", "deploy:folder_cleanup"

	# the code to test whether or not assets have changed and therefore need to be compiled was taken from answer at:
	# - http://stackoverflow.com/questions/12919509/capistrano-deploy-assets-precompile-never-compiles-assets-why
	# the code that builds assets locally and then copies to server was taken from:
	# - http://www.rostamizadeh.net/blog/2012/04/14/precompiling-assets-locally-for-capistrano-deployment/
	namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do
      # Check if assets have changed. If not, don't run the precompile task - it takes a long time.
      force_compile = false
      changed_asset_count = 0
      begin
        from = source.next_revision(current_revision)
        asset_locations = 'app/assets/ lib/assets vendor/assets'
        changed_asset_count = capture("cd #{latest_release} && #{source.local.log(from)} #{asset_locations} | wc -l").to_i
      rescue Exception => e
        logger.info "Error: #{e}, forcing precompile"
				logger.info "--> If this is the first deploy (deploy:cold), this is normal"
        force_compile = true
      end
      if changed_asset_count > 0 || force_compile
        logger.info "#{changed_asset_count} assets have changed; force_compile = #{force_compile}. Pre-compiling locally and pushing to shared/assets folder on server"
        run_locally("bundle exec rake assets:clean RAILS_ENV=#{rails_env} && bundle exec rake assets:precompile RAILS_ENV=#{rails_env} ")
        run_locally "cd public && tar -jcf assets.tar.bz2 assets"
        top.upload "public/assets.tar.bz2", "#{shared_path}", :via => :scp
        run "cd #{shared_path} && tar -jxf assets.tar.bz2 && rm assets.tar.bz2"
        run_locally "rm public/assets.tar.bz2"
        run_locally("bundle exec rake assets:clean RAILS_ENV=#{rails_env}")
      else
        logger.info "#{changed_asset_count} assets have changed. Skipping asset pre-compilation"
      end
    end
  end

end
