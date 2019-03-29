require 'bundler'
require 'pry'
require 'json'
require 'rake'
require 'sqlite3'
require 'paint'

Bundler.require

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.db')
require_all 'app'

# ActiveRecord::Base.logger.level = Logger::INFO
