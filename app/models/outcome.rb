# == Schema Information
#
# Table name: outcomes
#
#  id          :integer          not null, primary key
#  manager_id  :integer
#  course_id   :integer
#  lesson_id   :integer
#  folder_name :string
#  status      :string           default("draft")
#  score       :integer
#  checked     :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Outcome < ApplicationRecord
  include RandomString
  belongs_to :course
  belongs_to :lesson
  belongs_to :manager, class_name: 'User'
  has_one :outcome_text, -> { order(updated_at: :desc) }
  has_many :outcome_files, -> { order(updated_at: :desc) }
  has_many :outcome_messages, -> { order(updated_at: :desc) }
  has_many :outcomes_objectives, -> { order(objective_id: :asc) }
  has_many :objectives, -> { order(id: :asc) }, through: :outcomes_objectives
  validates_presence_of :course_id
  validates_presence_of :lesson_id
  validates_presence_of :manager_id
  validates_uniqueness_of :lesson_id, scope: [:manager_id]
  validates_inclusion_of :score, in: (0..10).to_a, allow_nil: true
  validates_inclusion_of :status, in: %w[draft submit self_submit return]

  accepts_nested_attributes_for :outcome_messages, allow_destroy: true
  accepts_nested_attributes_for :outcome_text, allow_destroy: true
  accepts_nested_attributes_for :outcomes_objectives, allow_destroy: true

  # ====================================================================
  # Public Functions
  # ====================================================================
  def self.all_by_lesson_id_and_lesson_role_and_manager_id(course_id, lesson_id, lesson_role, manager_id)
    case lesson_role
    when 'observer'
      outcomes = [Outcome.new_with_associations(manager_id, 0, 0, 'observer')]
    when 'learner'
      outcome = Outcome.find_by(manager_id: manager_id, lesson_id: lesson_id)
      if !outcome
        outcomes = [Outcome.new_with_associations(manager_id, course_id, lesson_id, lesson_role)]
      else
        case outcome.status
        when 'draft'
          outcome.outcome_messages.build
          outcome.build_outcome_text unless outcome.outcome_text
        when 'return', 'self_submit'
          outcome.update_attributes(checked: true) unless outcome.checked
          outcome.outcome_messages.build
        end
        outcomes = [outcome]
      end
    when 'evaluator', 'manager'
      outcomes = []
      outcomes_submit = []
      outcomes_draft = []

      course = Course.find_enabled_by course_id
      course.learners.each do |learner|
        outcome = Outcome.find_by(manager_id: learner.id, lesson_id: lesson_id)
        if outcome
          case outcome.status
          when 'submit'
            outcomes_submit.push outcome
          when 'draft'
            outcomes_draft.push outcome
          else
            outcomes.push outcome
          end
        else
          outcomes_draft.push Outcome.new(manager_id: learner.id, course_id: course_id, lesson_id: lesson_id)
        end
      end
      outcomes_submit.sort! { |a, b| a.updated_at <=> b.updated_at }
      outcomes.sort! { |a, b| a.updated_at <=> b.updated_at }
      outcomes = outcomes_submit + outcomes + outcomes_draft
    end
    outcomes
  end

  def self.new_with_associations(manager_id, course_id, lesson_id, lesson_role)
    outcome = Outcome.new(manager_id: manager_id, course_id: course_id, lesson_id: lesson_id)
    outcome.save if lesson_role == 'learner'
    outcome.outcome_messages.build
    outcome.build_outcome_text
    outcome
  end

  def self.report_displayable?(lesson_id, user_id, user_role)
    case user_role
    when 'learner'
      outcome = Outcome.find_by(manager_id: user_id, lesson_id: lesson_id)
      outcome && outcome.report_candidate?
    when 'manager', 'assistant'
      true
    end
  end

  def selected?(lessons)
    (lessons.select { |l| l.id == lesson_id }).size == 1
  end

  def self_evaluated?
    status != 'draft'
  end

  def report_candidate?
    # if assignments have evaluator, assignments before evaluator's evaluation are not shown in portfolio report
    status != 'draft' && score
  end

  def set_folder_name
    self.folder_name = random_string(FOLDER_NAME_LENGTH) unless folder_name
  end
end
