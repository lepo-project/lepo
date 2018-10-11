require 'rest-client'
require 'json'

class RosterImportJob < ApplicationJob
  # ====================================================================
  # Public Functions
  # ====================================================================
  queue_as :default

  def perform(*args)
    roster_terms = get_request '/terms'
    now = Time.zone.now
    open_rterms = roster_terms.select{|rt| ((Time.zone.parse(rt['startDate']) - 1.month)...Time.zone.parse(rt['endDate'])).cover? now}

    open_rterms.each do |ort|
      Term.create_from_roster ort
      roster_courses = get_request "/terms/#{ort['sourcedId']}/classes"
      roster_courses.each do |rc|
        create_course_from_roster ort, rc
      end
    end
  end

  # ====================================================================
  # Private Functions
  # ====================================================================

  private

  def create_course_from_roster(roster_term, roster_course)
    return unless Course.where(guid: roster_course['sourcedId']).count.zero?
    term_id = Term.find_by(guid: roster_term['sourcedId']).id
    roster_period = roster_course['periods'].split(',')[0]
    Course.create(
      guid: roster_course['sourcedId'],
      term_id: term_id,
      title: roster_course['title'],
      overview: '(blank overview)',
      weekday: roster_period.split('-')[0],
      period: roster_period.split('-')[1]
    )
    # FIXME: create course manager
    # FIXME: create course learners
    # FIXME: create course goal (place holder)
  end

  def get_request(endpoint)
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
