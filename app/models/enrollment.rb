# == Schema Information
#
# Table name: enrollments
#
#  id          :integer          not null, primary key
#  course_id   :integer
#  user_id     :integer
#  role        :string
#  group_index :integer          default(0)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  sourced_id  :string
#

class Enrollment < ApplicationRecord
  belongs_to :course
  belongs_to :user
  validates :course_id, presence: true
  validates :course_id, uniqueness: { scope: :user_id }
  # FIXME: Group work
  validates :group_index, inclusion: { in: (0...COURSE_GROUP_MAX_SIZE).to_a }
  validates :role, inclusion: { in: %w[manager assistant learner] }
  validates :user_id, presence: true

  # ====================================================================
  # Public Functions
  # ====================================================================
  def self.sync_roster(course_id, user_ids, renrollments)
    # Create and Update with OneRoster data
    ids = []
    renrollments.each do |re|
      enrollment = find_or_initialize_by(sourced_id: re['sourcedId'])
      user_id = user_ids.find{|u| u[:sourced_id] == re['userSourcedId']}[:id]
      role = to_lepo_role re['role']
      if enrollment.update_attributes(course_id: course_id, user_id: user_id, role: role)
        ids.push enrollment.id
      end
    end
    ids
  end

  def self.destroy_unused(course_id, enrollment_ids)
    enrollments = where(course_id: course_id).where.not(id: enrollment_ids)
    ids = []
    unless enrollments.empty?
      ids = enrollments.destroy_all
      ids.map{|e| e.user_id}
    end
    ids
  end

  def self.update_managers(course_id, current_ids, ids)
    transaction do
      # unregister
      current_ids.each do |c_id|
        if ids.include? c_id
          # neednot add or delete
          ids.delete c_id
        else
          enrollment = Enrollment.find_by(course_id: course_id, user_id: c_id, role: 'manager')
          enrollment.destroy! if enrollment.destroyable?
        end
      end
      # register
      ids.each do |id|
        enrollment = Enrollment.new(course_id: course_id, user_id: id, role: 'manager')
        enrollment.save!
      end
    end
    return true
  rescue StandardError
    logger.info(e.inspect)
    return false
  end

  def to_roster_hash
    raise if user.sourced_id.nil?
    hash = {
      classSourcedId: course.sourced_id,
      schoolSourcedId: Rails.application.secrets.roster_school_sourced_id,
      userSourcedId: user.sourced_id,
      role: Enrollment.to_roster_role(role)
    }
  end

  def self.to_lepo_role role
    case role
    when 'teacher'
      'manager'
    when 'aide'
      'assistant'
    when 'student'
      'learner'
    else
      raise
    end
  end

  def self.to_roster_role role
    case role
    when 'manager'
      'teacher'
    when 'assistant'
      'aide'
    when 'learner'
      'student'
    else
      raise
    end
  end

  def self.creatable?(course_id, operator_id, role = nil)
    # Not permitted when SYSTEM_ROSTER_SYNC is :suspended
    return false if %i[on off].exclude? SYSTEM_ROSTER_SYNC
    course = Course.find course_id
    return false if course.status == 'archived'
    raise 'ERROR: Assistant can not create manager' if (course.assistant?(operator_id) && role == 'manager')
    user = User.find operator_id
    user.system_staff? || course.staff?(operator_id)
  end

  def destroyable?(operator_id)
    return false if new_record?
    if role == 'manager'
      course = Course.find_enabled_by course_id
      return false if course.evaluator? user_id
      manager_num = Enrollment.where(course_id: course_id, role: 'manager').size
      return false if manager_num == 1
    end
    updatable? operator_id
  end

  def updatable?(operator_id, role = nil)
    # FIXME updat_to role must be inputted
    return false if SYSTEM_ROSTER_SYNC == :on && sourced_id.blank?
    return false if SYSTEM_ROSTER_SYNC == :off && sourced_id.present?
    Enrollment.creatable?(course.id, operator_id, role)
  end
end
