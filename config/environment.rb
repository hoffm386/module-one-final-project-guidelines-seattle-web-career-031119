require 'bundler'
require 'pry'
require 'json'
require 'rake'
require 'sqlite3'
require 'io/console'
require 'paint'
require 'yaml'

Bundler.require

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.db')

API_KEY = YAML.load_file('config/secrets.yml')["api_key"]

require_all 'app'

# ActiveRecord::Base.logger.level = Logger::INFO
