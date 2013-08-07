source 'http://rubygems.org'

gem 'formtastic', '2.2.1'
gem "airbrake"
gem 'delayed_job_active_record', '~> 0.4.4'
gem 'authlogic', '3.3.0'
gem 'will_paginate', '~> 3.0.4'
gem 'paperclip', '~> 2.7.5'
# gem 'aws-sdk', '~> 1.8.0'
# gem 'acts_as_list', '~> 0.1.6'
# gem 'declarative_authorization', '~> 0.5.5'
gem 'ruby_parser' # for declarative_authorization
gem 'nokogiri', '1.5.4' # so it doesn't autoupdate
gem 'hominid' # for mailchimper in plutolib
gem 'trollop', '2.0' # Command-line parser.
gem 'json'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'useragent' 
  
if File.exists?('../m2mhub')
  gem 'm2mhub', :path => '../m2mhub'
else
  gem 'm2mhub', :git => 'git@github.com:heedspin/m2mhub.git'
end

if File.exists?('../plutolib')
  gem 'plutolib', :path => '../plutolib'
else
  gem 'plutolib', :git => 'git@github.com:heedspin/plutolib.git'
end

group :database do
  gem 'mysql', '2.8.1'
  gem 'tiny_tds', '0.5.1'
  gem 'activerecord-sqlserver-adapter', '3.2.10'
end

group :development do
  gem 'mongrel'
  gem 'ruby-debug'
  gem 'ruby-debug-base'
  gem 'annotate', :git => 'git://github.com/ctran/annotate_models.git'
end

group :test do
  gem 'factory_girl', '2.5.1'
  gem 'transactional-factories', '0.5.0'
end
