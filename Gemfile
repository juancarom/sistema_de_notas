source "https://rubygems.org"

gem "rails", "~> 8.1.3"
gem "propshaft"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"

# Auth
gem "devise", "~> 4.9"

# Authorization
gem "pundit", "~> 2.3"

# Multi-tenancy via subdomain
gem "acts_as_tenant", "~> 0.6"

# Soft delete
gem "discard", "~> 1.3"

# CSS
gem "tailwindcss-rails"

# Forms
gem "simple_form", "~> 5.3"

# Pagination
gem "pagy", "~> 43.5"

# Background jobs (Rails 8 built-in, no Redis needed)
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false
gem "image_processing", "~> 1.2"

gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "rspec-rails", "~> 7.0"
  gem "factory_bot_rails"
  gem "faker"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
  gem "annotate"
  gem "letter_opener"
  gem "bullet"
end

group :test do
  gem "shoulda-matchers"
  gem "pundit-matchers"
  gem "capybara"
  gem "selenium-webdriver"
end
