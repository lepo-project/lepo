# == Schema Information
#
# Table name: objectives
#
#  id         :integer          not null, primary key
#  content_id :integer
#  title      :string
#  criterion  :text
#  allocation :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Objective < ApplicationRecord
  belongs_to :content, touch: true
  has_many :goals_objectives, dependent: :destroy
  has_many :goals, -> { order(id: :asc) }, through: :goals_objectives
  has_many :outcomes_objectives, dependent: :destroy
  has_many :outcomes, through: :outcomes_objectives
  validates_presence_of :title
  validates_inclusion_of :allocation, in: (1..10).to_a, allow_nil: true

  def selected?(lessons)
    (lessons.select { |l| l.content_id == content_id }).size == 1
  end
end
