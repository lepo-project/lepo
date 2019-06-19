# == Schema Information
#
# Table name: snippets
#
#  id          :integer          not null, primary key
#  manager_id  :integer
#  category    :string           default("text")
#  description :text
#  source_type :string           default("direct")
#  source_id   :integer
#  image_data  :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'test_helper'

class SnippetTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid snippet data
  test 'a snippet with valid data is valid' do
    assert build(:snippet).valid?
    assert build(:header_snippet).valid?
    assert build(:subheader_snippet).valid?
    assert build(:page_text_snippet).valid?
    assert build(:upload_image_snippet).valid?
    assert build(:web_text_snippet).valid?
    assert build(:web_image_snippet).valid?
    assert build(:web_pdf_snippet).valid?
    assert build(:web_scratch_snippet).valid?
    assert build(:web_ted_snippet).valid?
    assert build(:web_youtube_snippet).valid?
  end

  # validates :category, inclusion: { in: %w[text header subheader] }, if: "source_type == 'direct'"
  test 'a direct snippet with category that is not included in[text header subheader] is invalid' do
    assert_invalid build(:snippet, category: ''), :category
    assert_invalid build(:snippet, category: nil), :category
  end

  # validates :category, inclusion: { in: %w[text] }, if: "source_type == 'page'"
  test 'a page snippet with category that is not included in[text] is invalid' do
    assert_invalid build(:page_text_snippet, category: ''), :category
    assert_invalid build(:page_text_snippet, category: nil), :category
  end

  # validates :category, inclusion: { in: %w[image] }, if: "source_type == 'upload'"
  test 'an upload snippet with category that is not included in[image pdf] is invalid' do
    assert_invalid build(:upload_image_snippet, category: ''), :category
    assert_invalid build(:upload_image_snippet, category: nil), :category
  end

  # validates :category, inclusion: { in: %w[text image pdf scratch ted youtube] }, if: "source_type == 'web'"
  test 'a web snippet with category that is not included in[text image pdf scratch ted youtube] is invalid' do
    assert_invalid build(:web_text_snippet, category: ''), :category
    assert_invalid build(:web_text_snippet, category: nil), :category
  end

  # validates :description, presence: true, if: '%w[direct page].include? source_type'
  test 'a snippet without description is invalid' do
    assert_invalid build(:snippet, description: ''), :description
    assert_invalid build(:snippet, description: nil), :description
    assert_invalid build(:page_text_snippet, description: ''), :description
    assert_invalid build(:page_text_snippet, description: nil), :description
  end

  # validates :description, format: { with: /\.(gif|jpe?g|png)/i, message: 'must have an image extension' }, if: "source_type == 'web' && category == 'image'"
  test 'a snippet with incorrect format description is invalid' do
    assert_invalid build(:web_image_snippet, description: ''), :description
    assert_invalid build(:web_image_snippet, description: nil), :description
  end

  # validates :image_data, presence: true, if: "source_type == 'upload' && category == 'image'"
  test 'a snippet without image_data is invalid' do
    assert_invalid build(:upload_image_snippet, image_data: ''), :image_data
    assert_invalid build(:upload_image_snippet, image_data: nil), :image_data
  end

  # validates :manager_id, presence: true
  test 'a snippet without manager_id is invalid' do
    assert_invalid build(:snippet, manager_id: ''), :manager_id
    assert_invalid build(:snippet, manager_id: nil), :manager_id
  end

  # validates :source_id, presence: true, if: '%w[page web].include? source_type'
  test 'a snippet without source_id is invalid' do
    assert_invalid build(:page_text_snippet, source_id: ''), :source_id
    assert_invalid build(:page_text_snippet, source_id: nil), :source_id
    assert_invalid build(:web_text_snippet, source_id: ''), :source_id
    assert_invalid build(:web_text_snippet, source_id: nil), :source_id
  end

  # validates :source_type, inclusion: { in: %w[direct page upload web] }
  test 'a snippet with source_type that is not included in[direct page upload web] is invalid' do
    assert_invalid build(:snippet, source_type: ''), :source_type
    assert_invalid build(:snippet, source_type: nil), :source_type
  end
end
