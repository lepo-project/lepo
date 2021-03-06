# == Schema Information
#
# Table name: lessons
#
#  id                  :integer          not null, primary key
#  evaluator_id        :integer
#  content_id          :integer
#  course_id           :integer
#  display_order       :integer
#  status              :string
#  attendance_start_at :datetime
#  attendance_end_at   :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Lesson < ApplicationRecord
  belongs_to :evaluator, class_name: 'User'
  belongs_to :content
  belongs_to :course, touch: true
  has_many :attendances
  has_many :goals_objectives, dependent: :destroy
  has_many :outcomes
  validates :content_id, presence: true
  validates :content_id, uniqueness: { scope: :course_id }
  validates :course_id, presence: true
  validates :display_order, presence: true
  validates :evaluator_id, presence: true
  validates :status, inclusion: { in: %w[draft open] }

  # ====================================================================
  # Public Functions
  # ====================================================================
  def self.select_open(lessons)
    lessons.select { |l| l.status == 'open' }
  end

  def self.select_evaluator(lessons)
    lessons.select { |l| l.evaluator_id > 0 }
  end

  def deletable?(user_id)
    stickies = Sticky.where(content_id: content_id, course_id: course_id)
    return false if !outcomes.empty? || !stickies.empty?
    course.staff? user_id
  end

  def evaluator?(user_id)
    evaluator_id == user_id
  end

  def marked_outcome_num(user_id)
    case user_role user_id
    when 'evaluator'
      outcomes = Outcome.where(lesson_id: id, status: 'submit').order(updated_at: :asc) || []
      return outcomes.size
    when 'learner'
      outcome = Outcome.find_by(manager_id: user_id, lesson_id: id)
      return 1 if (outcome && outcome.status == 'return' && !outcome.checked) || (outcome && outcome.status == 'self_submit' && !outcome.checked)
    end
    0
  end

  def no_goal_objectives
    objs = content.objectives.to_a
    goals_objectives.each do |go|
      objs.reject!{|obj| obj.id == go.objective_id} unless go.goal_id.zero?
    end
    objs
  end

  def user_role(user_id)
    return 'observer' if new_record?
    return 'evaluator' if user_id == evaluator_id
    enrollment = Enrollment.find_by(user_id: user_id, course_id: course_id)
    enrollment ? enrollment.role : 'observer'
  end
end
