require 'rest-client'
require 'json'

class RosterImportJob < ApplicationJob
  queue_as :default
  # ====================================================================
  # Public Functions
  # ====================================================================

  def perform(*args)
    rterms = get_roster '/terms'
    term_ids = Term.sync_roster rterms

    term_ids.each do |tid|
      rcourses = get_roster "/terms/#{tid[:guid]}/classes"
      course_ids = Course.sync_roster tid[:id], rcourses
    end
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
