# == Schema Information
#
# Table name: contents
#
#  id          :integer          not null, primary key
#  category    :string
#  folder_name :string
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
    assert build(:content_with_file_assignment).valid?
    assert build(:content_with_outside_assignment).valid?
    assert build(:archived_content).valid?
  end

  # validates :as_category, inclusion: { in: %w[text file outside] }
  test 'a content with as_category that is not included in [text file outside] is invalid' do
    assert_invalid build(:content, as_category: ''), :as_category
    assert_invalid build(:content, as_category: nil), :as_category
  end

  # validates :category, inclusion: { in: %w[upload] }
  test 'a content with category that is not included in [upload] is invalid' do
    assert_invalid build(:content, category: ''), :category
    assert_invalid build(:content, category: nil), :category
  end

  # validates :folder_name, presence: true
  # this test is no need because of before_validation callback

  # validates :folder_name, uniqueness: true
  test 'some contents with same folder_name are invalid' do
    content = create(:content)
    assert_invalid build(:content, folder_name: content.folder_name), :folder_name
  end

  # validates :overview, presence: true
  test 'a content without overview is invalid' do
    assert_invalid build(:content, overview: ''), :overview
    assert_invalid build(:content, overview: nil), :overview
  end

  # validates :status, inclusion: { in: %w[open archived] }
  test 'a content with status that is not included in [open archived] is invalid' do
    assert_invalid build(:content, status: ''), :status
    assert_invalid build(:content, status: nil), :status
  end

  # validates :title, presence: true
  test 'a content without title is invalid' do
    assert_invalid build(:content, title: ''), :title
    assert_invalid build(:content, title: nil), :title
  end
end
