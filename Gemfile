source 'http://rubygems.org'

gem 'rails', '3.2.13'
gem 'active_model_serializers', '0.8.1'
gem 'rack', '1.4.5'
gem 'rack-cache', '1.2'
gem 'rake', '10.4.2'

gem 'formtastic', '2.2.1'
gem "airbrake", '4.1.0'
gem 'delayed_job_active_record', '~> 0.4.4'
gem 'lighthouse-api', :git => 'https://github.com/tongueroo/lighthouse-api.git'
# gem 'active_hash', '0.9.9'
gem 'authlogic', '3.3.0'
gem 'will_paginate', '~> 3.0.4'
gem 'paperclip', '~> 2.7.5'
# gem 'aws-sdk', '~> 1.8.0'
# gem 'acts_as_list', '~> 0.1.6'
# gem 'declarative_authorization', '~> 0.5.5'
gem 'ruby_parser' # for declarative_authorization
gem 'amatch', '~> 0.2.11'
gem 'nokogiri', '1.5.4' # so it doesn't autoupdate
gem 'hominid' # for mailchimper in plutolib
gem 'trollop', '2.0' # Command-line parser.
gem 'useragent', '0.10.0'
gem 'json', '1.8.1'
gem 'jquery-rails', '3.1.2'
gem 'jquery-ui-rails', '4.1.2'
gem 'oauth', '0.4.7'

if File.exists?('../doogle')
  gem 'doogle', :path => '../doogle'
elsif File.exists?('../../Dropbox/p/doogle')
  gem 'doogle', :path => '../../Dropbox/p/doogle'
elsif Dir.getwd.include?('lxd')
  gem 'doogle', :git => 'git@github.com:heedspin/doogle.git'
end

if File.exists?('../lxd_m2mhub')
  gem 'm2mhub', :path => '../smt_m2mhub'
else
  gem 'm2mhub', :git => 'git@github.com:heedspin/m2mhub.git'
end

if File.exists?('../plutolib')
  gem 'plutolib', :path => '../plutolib'
else
  gem 'plutolib', :git => 'git@github.com:heedspin/plutolib.git'
end

group :assets do
  # gem 'sass-rails',   "~> 3.2.3"
  # gem 'coffee-rails', "~> 3.2.1"
  # gem 'uglifier',     ">= 1.0.3"
end

group :database do
  # gem 'pg'
  gem 'mysql', '2.8.1'
  gem 'tiny_tds', '0.5.1'
  gem 'activerecord-sqlserver-adapter', '3.2.10'
end

group :development do
  # gem 'byebug'
  gem 'annotate', :git => 'git://github.com/ctran/annotate_models.git'
end

group :test do
  gem 'factory_girl', '2.5.1'
  gem 'transactional-factories', '0.5.0'
end
