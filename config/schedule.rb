# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

ENV.each_key do |key|
  env key.to_sym, ENV[key]
end

set :environment, ENV["RAILS_ENV"]

set :output, { error: 'log/cron_error.log', standard: 'log/cron.log' }

every '0 1 1 * *' do
  rake 'initialise:current_month'
end
