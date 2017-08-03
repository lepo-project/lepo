# == Schema Information
#
# Table name: snippets
#
#  id            :integer          not null, primary key
#  manager_id    :integer
#  note_id       :integer
#  category      :string           default("text")
#  description   :text
#  source_type   :string           default("direct")
#  source_id     :integer
#  master_id     :integer
#  display_order :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'test_helper'

class SnippetTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid snippet data
  test 'a snippet with valid data is valid' do
    assert build(:snippet).valid?
  end

  # test for validates_presence_of :category
  test 'a snippet without category is invalid' do
    assert_invalid build(:snippet, category: ''), :category
    assert_invalid build(:snippet, category: nil), :category
  end

  # test for validates_presence_of :manager_id
  test 'a snippet without manager_id is invalid' do
    assert_invalid build(:snippet, manager_id: ''), :manager_id
    assert_invalid build(:snippet, manager_id: nil), :manager_id
  end

  # test for validates_presence_of :source_type
  test 'a snippet without source_type is invalid' do
    assert_invalid build(:snippet, source_type: ''), :source_type
    assert_invalid build(:snippet, source_type: nil), :source_type
  end
end
