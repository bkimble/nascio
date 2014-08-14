def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

generate(:controller, "admin")

route "
  namespace :admin do
     resources :users
   end

  get 'admin' => 'admin/users#index'

  root 'admin/users#index'
"

directory("app/views/admin")
directory("app/views/devise")
copy_file("app/views/layouts/admin.html.haml")
copy_file("app/views/layouts/admin_unprotected.html.haml")
copy_file("app/models/user.rb")
directory("app/assets", force: true)
directory("app/controllers/admin", force: true)

# Gems
gem 'bootstrap-sass', '~> 3.2.0'
gem 'autoprefixer-rails'
gem 'bootstrap_form'
gem 'kaminari'
gem 'jquery-ui-rails'
gem "quiet_assets"
gem 'haml'
gem 'exception_notification', '4.0.1'
gem 'exception_notification-rake', '~> 0.1.2'
gem 'unicorn'
gem 'oj'
gem 'settingslogic'
gem 'mongo'
gem 'carrierwave'
gem 'bson_ext'
gem 'mongoid-grid_fs', github: 'ahoward/mongoid-grid_fs'
gem 'carrierwave-mongoid'
gem 'devise', '3.3.0'

inside app_name do
  run 'bundle install'
end

generate("mongoid:config")

# Devise.
generate('devise:install')
generate(:devise, "AdminUser")
generate("devise:views")
# Add host to default url options for development
insert_into_file("config/environments/development.rb", "\tconfig.action_mailer.default_url_options = { host: 'localhost', port: 3000 }\n", after: "config.assets.debug = true\n")
append_to_file("config/initializers/assets.rb", "Rails.application.config.assets.precompile += %w( admin.css )")
insert_into_file("config/initializers/devise.rb", after: "# config.omniauth_path_prefix = '/my_engine/users/auth'\n") do
  '
  Rails.application.config.to_prepare do
    Devise::SessionsController.layout "admin_unprotected"
    Devise::RegistrationsController.layout proc{ |controller| user_signed_in? ? "admin" : "admin_unprotected" }
    Devise::ConfirmationsController.layout "admin_unprotected"
    Devise::UnlocksController.layout "admin_unprotected"            
    Devise::PasswordsController.layout "admin_unprotected"        
  end
  '
end

#unsure why we need to do two hashes to get a comment to work  but a single is ignored.
insert_into_file("config/initializers/cookies_serializer.rb", "##", before: "Rails")

rake("db:migrate")

# Git initialization
git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }
