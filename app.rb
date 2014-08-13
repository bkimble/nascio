def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

generate(:controller, "admin")
#generate(:controller, "admin/users")

route "
  namespace :admin do
     resources :users
   end

  get 'admin' => 'admin/users#index'
"

copy_file("app/views/admin/users/index.html.haml")
copy_file("app/views/admin/_navigation.html.haml")
copy_file("app/views/layouts/admin.html.haml")
copy_file("app/models/user.rb")
directory("app/assets/stylesheets", force: true)
directory("app/assets/javascripts", force: true)
copy_file("app/controllers/admin/users_controller.rb", force: true)

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

rake("db:migrate")

# Git initialization
git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }
