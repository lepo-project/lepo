class TermJob < ApplicationJob
  queue_as :default
  # ====================================================================
  # Public Functions
  # ====================================================================

  def perform(*args)
    @logger = ActiveSupport::Logger.new(Rails.root.join(SYSTEM_JOB_LOG_FILE), 'monthly')
    @logger.formatter = ActiveSupport::Logger::Formatter.new
    @logger.info 'Started TermJob'
    ActiveRecord::Base.transaction do
      terms = Term.all
      terms.each do |term|
        updated_ids = Course.update_status term.id, term.status
        @logger.info "Updated status #{updated_ids.size} course(s) for term_id #{term.id}" if updated_ids.present?
      end
      @logger.info 'Completed TermJob'
    end
  end
end
