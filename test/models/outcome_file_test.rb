# == Schema Information
#
# Table name: outcome_files
#
#  id          :integer          not null, primary key
#  outcome_id  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  upload_data :text
#

require 'test_helper'

class OutcomeFileTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid outcome_file data
  test 'a outcome_file with valid data is valid' do
    assert build(:outcome_file).valid?
  end

  # test for validates_presence_of :outcome_id
  test 'a outcome_file without outcome_id is invalid' do
    assert_invalid build(:outcome_file, outcome_id: ''), :outcome_id
    assert_invalid build(:outcome_file, outcome_id: nil), :outcome_id
  end

  # test for validates_presence_of :upload_data
  test 'a outcome_file without upload_data is invalid' do
    assert_invalid build(:outcome_file, upload_data: ''), :upload_data
    assert_invalid build(:outcome_file, upload_data: nil), :upload_data
  end
end
