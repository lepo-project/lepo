# == Schema Information
#
# Table name: outcome_files
#
#  id                  :integer          not null, primary key
#  outcome_id          :integer
#  upload_file_name    :string
#  upload_content_type :string
#  upload_file_size    :integer
#  upload_updated_at   :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  upload_data         :string
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

  # test for validates_presence_of :upload_file_name
  test 'a outcome_file without upload_file_name is invalid' do
    assert_invalid build(:outcome_file, upload_file_name: ''), :upload_file_name
    assert_invalid build(:outcome_file, upload_file_name: nil), :upload_file_name
  end

  # test for validates_uniqueness_of :upload_file_name, scope: [:outcome_id]
  test 'some outcome_files with same upload_file_name and outcome_id are invalid' do
    outcome_file = create(:outcome_file)
    assert_invalid build(:outcome_file, upload_file_name: outcome_file.upload_file_name, outcome_id: outcome_file.outcome_id), :upload_file_name
  end
end
