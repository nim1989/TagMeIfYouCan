source 'http://rubygems.org'

gem 'rails', '3.2.1'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'mysql2'

# RDF
gem 'rdf'
gem 'backports'
gem 'rdf-raptor'

gem 'jquery-rails'
gem 'haml'
gem 'heroku'
gem 'rack-ssl'
gem 'devise'
gem 'fb_graph'
gem 'thin'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
group :development, :test do 
  if RUBY_VERSION =~ /1.9/ 
    gem 'ruby-debug19' 
  else 
    gem 'ruby-debug' 
  end 
end
group :test do
  # Pretty printed test output
  gem 'turn', '0.8.2', :require => false
end
