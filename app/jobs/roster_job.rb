require 'rest-client'
require 'json'

class RosterJob < ApplicationJob
  queue_as :default
  # ====================================================================
  # Public Functions
  # ====================================================================

  def perform(*args)
    @logger = ActiveSupport::Logger.new(Rails.root.join(SYSTEM_JOB_LOG_FILE), 'monthly')
    @logger.formatter = ActiveSupport::Logger::Formatter.new

    case SYSTEM_ROSTER_SYNC
    when :on
      @logger.info 'Started RosterJob'
      ActiveRecord::Base.transaction do
        term_ids = Term.sync_roster get_roster('/terms', 'academicSessions')
        @logger.info "Synchronized #{term_ids.size} term(s)" if term_ids.present?
        term_ids.each do |tid|
          sync_with_term tid
        end
        @logger.info 'Completed RosterJob'
      end
    when :off, :suspended
      @logger.info "Nothing has done with RosterJob because SYSTEM_ROSTER_SYNC is #{SYSTEM_ROSTER_SYNC}"
    else
      @logger.warn "Incorrect value (#{SYSTEM_ROSTER_SYNC}) is set to constant SYSTEM_ROSTER_SYNC"
    end
  end

  # ====================================================================
  # Private Functions
  # ====================================================================

  private

  def get_roster(endpoint, obj_name)
    flag = true
    offset = 0
    limit = 100
    responses = []

    while flag
      url = Rails.application.credentials.oneroster[:url_prefix] + endpoint + "?offset=#{offset}&limit=#{limit}"
      # FIXME: verify_ssl should be true!
      response = RestClient::Request.execute(
        :url => url,
        :method => :get,
        :headers => {Authorization: 'Bearer ' + Rails.application.credentials.oneroster[:token]},
        :verify_ssl => false
      )
      flag = (response.code == 200) && !JSON.parse(response.body)[obj_name].empty?
      responses.concat JSON.parse(response.body)[obj_name] if flag
      offset += limit
    end
    responses
  end

  def sync_with_course cid
    manager_ids = User.sync_roster get_roster("/classes/#{cid[:sourced_id]}/teachers", 'users')
    learner_ids = User.sync_roster get_roster("/classes/#{cid[:sourced_id]}/students", 'users')
    # FIXME: get_roster for aide

    school_id = Rails.application.credentials.oneroster[:school_sourced_id]
    renrollments = get_roster("/schools/#{school_id}/classes/#{cid[:sourced_id]}/enrollments", 'enrollments')
    enrollment_ids = Enrollment.sync_roster cid[:id], manager_ids.concat(learner_ids), renrollments
    destroyed_ids = Enrollment.destroy_unused cid[:id], enrollment_ids
    @logger.info("Deleted from enrollments for course_id: #{cid[:id]} => user_id: #{destroyed_ids.join(', ')}") if destroyed_ids.present?
  end

  def sync_with_term tid
    rcourses = get_roster("/terms/#{tid[:sourced_id]}/classes", 'classes')
    course_ids = Course.sync_roster tid[:id], tid[:status], rcourses
    deleted_ids = Course.logical_delete_unused tid[:id], course_ids
    @logger.info("Logicaly deleted from courses => #{deleted_ids.join(', ')}") if deleted_ids.present?
    @logger.info "Synchronized #{course_ids.size} course(s) for term_id #{tid[:id]}" if course_ids.present?
    course_ids.each do |cid|
      sync_with_course cid
    end
    @logger.info "Synchronized enrollments for term_id #{tid[:id]}" if course_ids.present?
  end
end
