# == Schema Information
#
# Table name: links
#
#  id            :integer          not null, primary key
#  manager_id    :integer
#  display_order :integer
#  url           :text
#  title         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'test_helper'

class LinkTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid link data
  test 'a link with valid data is valid' do
    assert build(:link).valid?
  end

  # test for validates_presence_of :display_order
  test 'a link without display_order is invalid' do
    assert_invalid build(:link, display_order: ''), :display_order
    assert_invalid build(:link, display_order: nil), :display_order
  end

  # test for validates_presence_of :manager_id
  test 'a link without manager_id is invalid' do
    assert_invalid build(:link, manager_id: ''), :manager_id
    assert_invalid build(:link, manager_id: nil), :manager_id
  end

  # test for validates_presence_of :title
  test 'a link without title is invalid' do
    assert_invalid build(:link, title: ''), :title
    assert_invalid build(:link, title: nil), :title
  end

  # test for validates_presence_of :url
  test 'a link without url is invalid' do
    assert_invalid build(:link, url: ''), :url
    assert_invalid build(:link, url: nil), :url
  end

  # test for validates_uniqueness_of :title, scope: [:manager_id]
  test 'some links with same title and manager_id are invalid' do
    link = create(:link)
    assert_invalid build(:link, title: link.title, manager_id: link.manager_id), :title
  end

  # test for  validates :url, format: URI.regexp(%w[http https])
  test 'a link with incorrect url is invalid' do
    assert_invalid build(:link, url: 'abc'), :url
  end
end
