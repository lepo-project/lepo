# == Schema Information
#
# Table name: web_sources
#
#  id         :integer          not null, primary key
#  url        :text
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class WebSourceTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid web_source data
  test 'a web_source with valid data is valid' do
    assert build(:web_source).valid?
  end

  # test for validates_presence_of :url
  test 'a web_source without url is invalid' do
    assert_invalid build(:web_source, url: ''), :url
    assert_invalid build(:web_source, url: nil), :url
  end

  # test for validates :url, format: URI.regexp(%w[http https])
  test 'a web_source with incorrect url is invalid' do
    assert_invalid build(:web_source, url: 'abc'), :url
  end
end
