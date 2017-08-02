# == Schema Information
#
# Table name: attendances
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  lesson_id  :integer
#  memo       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Attendance < ApplicationRecord
  belongs_to :user
  belongs_to :lesson
end
