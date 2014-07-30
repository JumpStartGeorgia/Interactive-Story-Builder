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
set :output, "log/cron.log"
job_type :video_processing_script, "cd :path/script/video_processing && sh :task >> :path/log/cron.log 2>&1"

# clear tmp folder stories created during story downloads
every 3.hours do
  rake "story:tmp_stories_clear"
end

# process videos
every 3.minutes do
  video_processing_script "process_videos.sh"
  runner "NotificationTrigger.process_processed_videos"
end

case @environment
when 'production'
  # send notifications
  every 30.minutes do
    runner "NotificationTrigger.process_all_types"
  end
end
