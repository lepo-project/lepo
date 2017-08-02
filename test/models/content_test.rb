# == Schema Information
#
# Table name: contents
#
#  id          :integer          not null, primary key
#  category    :string
#  folder_id   :string
#  title       :string
#  condition   :text
#  overview    :text
#  status      :string           default("open")
#  as_category :string           default("text")
#  as_overview :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'test_helper'

class ContentTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid content data
  test 'a content with valid data is valid' do
    assert build(:content).valid?
  end

  # test for validates_presence_of :as_category
  test 'a content without as_category is invalid' do
    assert_invalid build(:content, as_category: ''), :as_category
    assert_invalid build(:content, as_category: nil), :as_category
  end

  # test for validates_presence_of :category
  test 'a content without category is invalid' do
    assert_invalid build(:content, category: ''), :category
    assert_invalid build(:content, category: nil), :category
  end

  # test for validates_presence_of :overview
  test 'a content without overview is invalid' do
    assert_invalid build(:content, overview: ''), :overview
    assert_invalid build(:content, overview: nil), :overview
  end

  # test for validates_presence_of :status
  test 'a content without status is invalid' do
    assert_invalid build(:content, status: ''), :status
    assert_invalid build(:content, status: nil), :status
  end

  # test for validates_presence_of :title
  test 'a content without title is invalid' do
    assert_invalid build(:content, title: ''), :title
    assert_invalid build(:content, title: nil), :title
  end

  # test for validates_uniqueness_of :folder_id
  test 'some contents with same folder_id are invalid' do
    content = create(:content)
    assert_invalid build(:content, folder_id: content.folder_id), :folder_id
  end
end
