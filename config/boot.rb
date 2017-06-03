require 'bundler/setup'

MODE = ENV['RACK_ENV'] || 'development'

Bundler.require(:default)
Bundler.require(:development) if MODE == 'development'

# Load Settings
SETTINGS = YAML.load_file('./config/settings.yml').symbolize_keys

# For the contact form
SUBJECTS = {
  :price => 'Prisforespørsel',
  :questions => 'Spørsmål om våre tjenester',
  :marketing => 'Markedsføring',
  :design =>'Design og utvikling',
  :hosting => 'Hosting og Drift',
  :other => 'Annet'
}

require 'sinatra/multi_route'

require './lib/sitemap.rb'
require './lib/app_helper.rb'
require './lib/jobs/email_job.rb'

# Loading routes
ROUTES = YAML.load_file('./config/routes.yml').symbolize_keys

# Loading languages
LANG = {
  'en' => YAML.load_file('./config/locales/en.yml'),
  'no' => YAML.load_file('./config/locales/no.yml')
}

# Email validation
EMAIL_REGEXP = /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,5}\z/

puts "Starting in #{MODE} mode"
