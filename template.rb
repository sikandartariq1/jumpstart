require "fileutils"
require "shellwords"

# Copied from: https://github.com/mattbrictson/rails-template
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
def add_template_repository_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    require "tmpdir"
    source_paths.unshift(tempdir = Dir.mktmpdir("jumpstart-"))
    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
      "--quiet",
      "https://github.com/sikandartariq1/jumpstart.git",
      tempdir
    ].map(&:shellescape).join(" ")

    if (branch = __FILE__[%r{jumpstart/(.+)/template.rb}, 1])
      Dir.chdir(tempdir) { git checkout: branch }
    end
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

def rails_version
  @rails_version ||= Gem::Version.new(Rails::VERSION::STRING)
end

def rails_5?
  Gem::Requirement.new(">= 5.2.0", "< 6.0.0.beta1").satisfied_by? rails_version
end

def rails_6?
  Gem::Requirement.new(">= 6.0.0.beta1", "< 7").satisfied_by? rails_version
end

def add_gems
  gem 'activeadmin'
  gem 'bootstrap', '~> 4.3', '>= 4.3.1'
  gem 'devise', '~> 4.6', '>= 4.6.1'
  gem 'devise-bootstrapped', github: 'excid3/devise-bootstrapped', branch: 'bootstrap4'
  gem 'font-awesome-sass', '~> 5.6', '>= 5.6.1'
  gem 'friendly_id', '~> 5.2', '>= 5.2.5'
  gem 'name_of_person', '~> 1.1'
  gem 'sidekiq', '~> 5.2', '>= 5.2.5'
  gem 'arctic_admin'
  gem 'activeadmin_addons'
  gem 'exception_notification'
end

def set_application_name
  # Add Application Name to Config
  if rails_5?
    environment "config.application_name = Rails.application.class.parent_name"
  else
    environment "config.application_name = Rails.application.class.module_parent_name"
  end

  # Announce the user where he can change the application name in the future.
  puts "You can change application name inside: ./config/application.rb"
end

def add_users
  # Install Devise
  generate "devise:install"

  # Configure Devise
  environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }",
              env: 'development'

  # Devise notices are installed via Bootstrap
  generate "devise:views:bootstrapped"

  # Create Devise User
  generate :devise, "User",
           "first_name",
           "last_name"

  if Gem::Requirement.new("> 5.2").satisfied_by? rails_version
    gsub_file "config/initializers/devise.rb",
      /  # config.secret_key = .+/,
      "  config.secret_key = Rails.application.credentials.secret_key_base"
  end
end

def copy_templates
  remove_file "app/assets/stylesheets/application.css"
  remove_file "app/assets/stylesheets/active_admin.scss"
  remove_file "app/assets/javascripts/active_admin.js"

  append_to_file 'Gemfile', "\n#eof\n"
  append_to_file '.gitignore', "\n.DS_Store\n"

  directory "app", force: true
  directory "config", force: true
  directory "lib", force: true
  directory "vendor", force: true
  directory "db", force: true
end

def add_sidekiq
  environment "config.active_job.queue_adapter = :sidekiq"
end

def add_activeadmin
  generate "active_admin:install"
end

def add_friendly_id
  generate "friendly_id"

  insert_into_file(
    Dir["db/migrate/**/*friendly_id_slugs.rb"].first,
    "[5.2]",
    after: "ActiveRecord::Migration"
  )
end

def stop_spring
  run "spring stop"
end

# Main setup
add_template_repository_to_source_path

add_gems

after_bundle do
  set_application_name
  stop_spring
  add_users
  add_sidekiq
  add_friendly_id
  add_activeadmin

  copy_templates

  # Migrate
  rails_command "db:create"
  rails_command "db:migrate"
  rails_command "db:seed"

  # Commit everything to git
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }

  say
  say "Jumpstart app successfully created!", :blue
  say
  say "To get started with your new app:", :green
  say "cd #{app_name} - Switch to your new app's directory."
end
