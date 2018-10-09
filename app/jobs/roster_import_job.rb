require 'rest-client'
require 'json'

class RosterImportJob < ApplicationJob
  # ====================================================================
  # Public Functions
  # ====================================================================
  queue_as :default

  def perform(*args)
    terms = get_request '/terms'
    now = Time.zone.now
    open_terms = terms.reject{|t| (now < Time.zone.parse(t['startDate']) - 1.month) || (Time.zone.parse(t['endDate']) <= now)}
    open_terms.each do |t|
      Term.create_from_roster t
      classes = get_request "/terms/#{t['sourcedId']}/classes"
      # p classes
    end
    open_terms
  end

  # ====================================================================
  # Private Functions
  # ====================================================================

  private

  def get_request(endpoint)
    url = SYSTEM_ROSTER_URL_PREFIX + endpoint
    # FIXME: verify_ssl should be true!
    response = RestClient::Request.execute(
      :url => url,
      :method => :get,
      :headers => {Authorization: 'Bearer ' + SYSTEM_ROSTER_TOKEN},
      :verify_ssl => false
    )
    JSON.parse(response.body)
  end
end
