source "https://rubygems.org"
git_source(:gitlab) { |repo| "https://oauth2:#{ENV['GITLAB_ACCESS_TOKEN']}@gitlab.mesvaccins.net/syadem/#{repo}.git" }

gem 'rspec', '~> 3.4'
gem 'siphash', '~> 0.0.1'
gem 'redcarpet'

group :development do
  gem 'ostruct'
  gem 'medcon', gitlab: 'medcon', glob: 'ruby/medcon.gemspec'
end
