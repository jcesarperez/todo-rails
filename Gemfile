source "https://rubygems.org"
ruby "3.3.2"

gem "rails", "~> 7.1.6"
gem "sprockets-rails"
gem "sqlite3", ">= 1.4"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[windows jruby]
gem "bootsnap", require: false

group :development, :test do
  gem "debug", platforms: %i[mri windows]
  gem "rspec-rails", "~> 7.1"
  gem "shoulda-matchers"
end

group :development do
  gem "web-console"
  gem "standard", "~> 1.51"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end

gem "annotate", "~> 3.2", group: :development
