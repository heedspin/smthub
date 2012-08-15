source 'http://rubygems.org'

gem 'formtastic', '2.0.2'
gem "airbrake", '3.0.9'
gem 'delayed_job_active_record', '~> 0.3.2'
gem 'active_hash', '0.9.9'
gem 'authlogic', '3.1.0'
gem 'will_paginate', '~> 3.0.3'
gem 'paperclip', '~> 2.7.0'
gem 'aws-sdk', '~> 1.3.4'
gem 'acts_as_list', '~> 0.1.6'
gem 'declarative_authorization', '~> 0.5.5'
  
if File.exists?('../m2mhub')
  gem 'm2mhub', :path => '../m2mhub'
else
  gem 'm2mhub', :git => 'git@github.com:heedspin/m2mhub.git'
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
