require 'rest-client'
require 'json'

class RosterJob < ApplicationJob
  queue_as :default
  # ====================================================================
  # Public Functions
  # ====================================================================

  def perform(*args)
    logger = ActiveSupport::Logger.new(Rails.root.join(SYSTEM_ROSTER_LOG_FILE), 'monthly')
    logger.formatter = ActiveSupport::Logger::Formatter.new
    logger.info 'Started RosterJob'

    rterms = get_roster '/terms'
    term_ids = Term.sync_roster rterms['academicSessions']
    logger.info "Synchronized #{term_ids.size} term(s)" if term_ids.present?

    term_ids.each do |tid|
      rcourses = get_roster "/terms/#{tid[:guid]}/classes"
      course_ids = Course.sync_roster tid[:id], rcourses['classes']
      logger.info "Synchronized #{course_ids.size} course(s) for term_id #{tid[:id]}" if course_ids.present?
      course_ids.each do |cid|
        rmanagers = get_roster "/classes/#{cid[:guid]}/teachers"
        manager_ids = User.sync_roster rmanagers['users']
        CourseMember.sync_roster cid[:id], manager_ids, 'manager'
        rlearners = get_roster "/classes/#{cid[:guid]}/students"
        learner_ids = User.sync_roster rlearners['users']
        CourseMember.sync_roster cid[:id], learner_ids, 'learner'
      end
      logger.info "Synchronized course members for term_id #{tid[:id]}" if course_ids.present?
    end
    logger.info 'Completed RosterJob'
  end

  # ====================================================================
  # Private Functions
  # ====================================================================

  private

  def get_roster(endpoint)
    url = Rails.application.secrets.roster_url_prefix + endpoint
    # FIXME: verify_ssl should be true!
    response = RestClient::Request.execute(
      :url => url,
      :method => :get,
      :headers => {Authorization: 'Bearer ' + Rails.application.secrets.roster_token},
      :verify_ssl => false
    )
    JSON.parse(response.body)
  end
end
