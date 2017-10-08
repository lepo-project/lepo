# == Schema Information
#
# Table name: web_pages
#
#  id         :integer          not null, primary key
#  url        :text
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class WebPageTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid web_page data
  test 'a web_page with valid data is valid' do
    assert build(:web_page).valid?
  end

  # test for validates_presence_of :url
  test 'a web_page without url is invalid' do
    assert_invalid build(:web_page, url: ''), :url
    assert_invalid build(:web_page, url: nil), :url
  end

  # test for validates :url, format: URI.regexp(%w[http https])
  test 'a web_page with incorrect url is invalid' do
    assert_invalid build(:web_page, url: 'abc'), :url
  end
end
