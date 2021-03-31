class CacheJob < ApplicationJob
  queue_as :default
  # ====================================================================
  # Public Functions
  # ====================================================================

  def perform(*args)
    # Clear cache files for shrine gem
    file_system = Shrine.storages[:cache]
    # delete files older than 1 week
    file_system.clear! { |path| path.mtime < Time.now - 7*24*60*60 } 
  end
end
