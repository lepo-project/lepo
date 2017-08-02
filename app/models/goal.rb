# == Schema Information
#
# Table name: goals
#
#  id         :integer          not null, primary key
#  course_id  :integer
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Goal < ApplicationRecord
  belongs_to :course, touch: true
  has_many :goals_objectives, dependent: :destroy
  has_many :lessons, through: :goals_objectives
  has_many :objectives, -> { order(id: :asc) }, through: :goals_objectives
  validates_presence_of :title
end
