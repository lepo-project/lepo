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

set :output, "#{path}/log/cron.log"
set :environment, :production

# For SYSTEM_ROSTER_SYNC = 'on' only
every 1.day, at: ['6:00 am'] do
  runner 'RosterJob.perform_now'
end

# To update course status according to term
# For all SYSTEM_ROSTER_SYNC settings
every 1.day, at: ['0:10 am'] do
  runner 'TermJob.perform_now'
end
