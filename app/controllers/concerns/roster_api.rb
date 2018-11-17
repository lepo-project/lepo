require 'rest-client'
require 'json'

module RosterApi
  extend ActiveSupport::Concern

  private

  def request_roster_api(endpoint, method, payload={})
    url = Rails.application.secrets.roster_url_prefix + endpoint
    # FIXME: verify_ssl should be true!
    request_hash = {
      url: url,
      method: method,
      headers: {Authorization: 'Bearer ' + Rails.application.secrets.roster_token},
      verify_ssl: false
    }
    request_hash.merge!({payload: payload}) if payload.present?
    response = RestClient::Request.execute(request_hash)
    JSON.parse(response.body) if response.body.present?
  end
end
