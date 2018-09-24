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
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  image_data  :text
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

  # test for validates_presence_of :description, if: '%w[direct page].include? source_type'
  test 'a snippet without description is invalid' do
    assert_invalid build(:snippet, description: ''), :description
    assert_invalid build(:snippet, description: nil), :description
    assert_invalid build(:page_text_snippet, description: ''), :description
    assert_invalid build(:page_text_snippet, description: nil), :description
  end

  # test for validates_presence_of :manager_id
  test 'a snippet without manager_id is invalid' do
    assert_invalid build(:snippet, manager_id: ''), :manager_id
    assert_invalid build(:snippet, manager_id: nil), :manager_id
  end

  # test for validates_presence_of :source_id, if: '%w[page web].include? source_type'
  test 'a snippet without source_id is invalid' do
    assert_invalid build(:page_text_snippet, source_id: ''), :source_id
    assert_invalid build(:page_text_snippet, source_id: nil), :source_id
    assert_invalid build(:web_text_snippet, source_id: ''), :source_id
    assert_invalid build(:web_text_snippet, source_id: nil), :source_id
  end

  # test for validates_inclusion_of :category, in: %w[text header subheader], if: "source_type == 'direct'"
  test 'a direct snippet with category that is not included in[text header subheader] is invalid' do
    assert_invalid build(:snippet, category: ''), :category
    assert_invalid build(:snippet, category: nil), :category
  end

  # test for validates_inclusion_of :category, in: %w[text], if: "source_type == 'page'"
  test 'a page snippet with category that is not included in[text] is invalid' do
    assert_invalid build(:page_text_snippet, category: ''), :category
    assert_invalid build(:page_text_snippet, category: nil), :category
  end

  # test for validates_inclusion_of :category, in: %w[image pdf], if: "source_type == 'upload'"
  test 'an upload snippet with category that is not included in[image pdf] is invalid' do
    assert_invalid build(:upload_image_snippet, category: ''), :category
    assert_invalid build(:upload_image_snippet, category: nil), :category
  end

  # test for validates_inclusion_of :category, in: %w[text image pdf scratch ted youtube], if: "source_type == 'web'"
  test 'a web snippet with category that is not included in[text image pdf scratch ted youtube] is invalid' do
    assert_invalid build(:web_text_snippet, category: ''), :category
    assert_invalid build(:web_text_snippet, category: nil), :category
  end

  # test for validates_inclusion_of :source_type, in: %w[direct page upload web]
  test 'a snippet with source_type that is not included in[direct page upload web] is invalid' do
    assert_invalid build(:snippet, source_type: ''), :source_type
    assert_invalid build(:snippet, source_type: nil), :source_type
  end

  # test for validates_format_of :description, with: /\.(gif|jpe?g|png)/i, message: 'must have an image extension', if: "source_type == 'web' && category == 'image'"
  test 'a snippet with incorrect format description is invalid' do
    assert_invalid build(:web_image_snippet, description: ''), :description
    assert_invalid build(:web_image_snippet, description: nil), :description
  end
end
