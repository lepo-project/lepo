# == Schema Information
#
# Table name: outcome_files
#
#  id          :integer          not null, primary key
#  outcome_id  :integer
#  upload_data :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
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

  # validates :outcome_id, presence: true
  test 'a outcome_file without outcome_id is invalid' do
    assert_invalid build(:outcome_file, outcome_id: ''), :outcome_id
    assert_invalid build(:outcome_file, outcome_id: nil), :outcome_id
  end

  # validates :upload_data, presence: true
  test 'a outcome_file without upload_data is invalid' do
    assert_invalid build(:outcome_file, upload_data: ''), :upload_data
    assert_invalid build(:outcome_file, upload_data: nil), :upload_data
  end
end
