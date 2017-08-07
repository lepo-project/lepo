# == Schema Information
#
# Table name: courses
#
#  id                 :integer          not null, primary key
#  term_id            :integer
#  folder_id          :string
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :integer
#  image_updated_at   :datetime
#  title              :string
#  overview           :text
#  status             :string           default("draft")
#  groups_count       :integer          default(1)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'date'
class Course < ApplicationRecord
  include RandomString
  before_validation :set_default_value
  has_attached_file :image,
  path: ':rails_root/public/system/:class/:folder_id/:style/:filename',
  url: ':relative_url_root/system/:class/:folder_id/:style/:filename',
  default_url: '/assets/:class/:style/missing.png',
  styles: { px40: '40x40>', px80: '80x80>', original: '160x160>' }
  validates_attachment_content_type :image, content_type: ['image/gif', 'image/jpeg', 'image/pjpeg', 'image/png', 'image/x-png']
  validates_attachment_size :image, less_than: IMAGE_MAX_FILE_SIZE.megabytes # original file is resized, so this is not important
  belongs_to :term
  has_many :assistants, -> { where('course_members.role = ?', 'assistant') }, through: :course_members, source: :user
  has_many :contents, -> { order(display_order: :asc) }, through: :lessons
  has_many :course_members, dependent: :destroy
  has_many :goals, -> { order(id: :asc) }, dependent: :destroy
  has_many :learners, -> { where('course_members.role = ?', 'learner').order(user_id: :asc) }, through: :course_members, source: :user
  has_many :lessons, -> { order(display_order: :asc) }
  has_many :managers, -> { where('course_members.role = ?', 'manager') }, through: :course_members, source: :user
  has_many :master_draft_notes, -> { where('notes.status = ?', 'master_draft').order(updated_at: :desc) }, class_name: 'Note'
  has_many :master_open_notes, -> { where('notes.status = ?', 'master_open').order(updated_at: :desc) }, class_name: 'Note'
  has_many :master_review_notes, -> { where('notes.status = ?', 'master_review').order(updated_at: :desc) }, class_name: 'Note'
  has_many :members, through: :course_members, source: :user
  has_many :notices, dependent: :destroy
  has_many :open_lessons, -> { where('lessons.status = ?', 'open').order(display_order: :asc) }, class_name: 'Lesson'
  has_many :outcomes, dependent: :destroy
  has_many :staff_course_notes, -> { where('notes.status = ? and notes.master_id = ?', 'course', 0).order(updated_at: :desc) }, class_name: 'Note'
  has_many :notes
  validates_presence_of :folder_id
  validates_presence_of :term_id
  validates_presence_of :title
  validates_uniqueness_of :folder_id
  # FIXME: Group work
  validates_inclusion_of :groups_count, in: (1..COURSE_GROUP_MAX_SIZE).to_a
  validates_inclusion_of :status, in: %w[draft open archived]
  accepts_nested_attributes_for :goals, allow_destroy: true, reject_if: proc { |att| att['title'].blank? }, limit: COURSE_GOAL_MAX_SIZE

  # ====================================================================
  # Public Functions
  # ====================================================================
  # FIXME: Group work
  def group_id_for(user_id)
    CourseMember.where(course_id: id, user_id: user_id).first.group_id
  end

  # FIXME: Group work
  def learners_in_group(index)
    user_ids = course_members.where('course_members.role = ? and course_members.group_id = ?', 'learner', index).order(user_id: :asc).pluck(:user_id)
    User.where(id: user_ids).order(user_id: :asc)
  end

  def duplicate_goals_to(course_id)
    goals.each do |g|
      goal = Goal.new(title: g.title, course_id: course_id)
      goal.save
    end
  end

  def duplicate_lessons_to(course_id, manager_id)
    lessons.each do |l|
      evaluator_id = l.evaluator_id > 0 ? manager_id : 0
      lesson = Lesson.new(evaluator_id: evaluator_id, course_id: course_id, content_id: l.content.id, display_order: l.display_order, status: LESSON_STATUS_DEFAULT)
      lesson.save
    end
  end

  def hot_stickies
    duration = 7
    max_size = 3
    Sticky.where("category = 'course' and course_id = ? and created_at >= ? and stars_count > 1", id, Date.today - duration).order('stars_count DESC, created_at DESC').limit(max_size)
  end

  def hot_notes
    duration = 28
    max_size = 5
    notes = Note.where("status = 'course' and course_id = ? and updated_at >= ? and stars_count > 1", id, Date.today - duration).order('stars_count DESC, created_at DESC').limit(max_size)
    notes.to_a.delete_if { |note| !note.open? }
  end

  def hot_sources
    duration = 28
    max_size = 5

    notes_by_members = []
    members.each do |member|
      # notes = Note.where("status = 'course' and course_id = ? and manager_id = ?", self.id, member.id).select(:id)
      # notes_by_members.push [member.id, notes.to_a]

      notes = Note.where("status = 'course' and course_id = ? and manager_id = ?", id, member.id)
      notes.to_a.delete_if { |note| !note.open? }
      note_ids = []
      notes.each do |note|
        note_ids.push note.id
      end
      notes_by_members.push [member.id, note_ids]
    end

    snippets = []
    notes_by_members.each do |sbm|
      snippets.push Snippet.where("source_type = 'web' and note_id in (?) and updated_at >= ?", sbm[1], Date.today - duration).select(:source_id).distinct
    end
    snippets.flatten!

    snippets_with_count = []
    snippets.each do |s|
      count = snippets.select { |snppt| snppt['source_id'] == s['source_id'] }.size
      snippets_with_count.push [s['source_id'], count]
    end
    snippets_with_count.uniq!
    snippets_with_count.sort! { |p, q| q[1] <=> p[1] }

    hot_sources = []
    snippets_with_count[0, max_size].each do |swc|
      hot_sources.push WebSource.find_by(id: swc[0]) if swc[1] > 1
    end
    hot_sources
  end

  def learner_course_notes(user_id, course_staff)
    notes = []
    if course_staff
      master_draft_notes.each do |mos|
        notes += Note.where(course_id: id, status: 'course', master_id: mos.id).order(updated_at: :desc).to_a
      end
    else
      master_draft_notes.each do |mos|
        notes += Note.where(course_id: id, status: 'course', master_id: mos.id, manager_id: user_id).order(updated_at: :desc).to_a
      end
    end
    master_review_notes.each do |mos|
      notes += Note.where(course_id: id, status: 'course', master_id: mos.id).order(updated_at: :desc).to_a
    end
    master_open_notes.each do |mos|
      notes += Note.where(course_id: id, status: 'course', master_id: mos.id).order(updated_at: :desc).to_a
    end
    notes
  end

  def self.archived_courses_in_days(user_id, days)
    courses = CourseMember.where(user_id: user_id).order(updated_at: :desc).to_a
    courses.map!(&:course)
    courses.delete_if { |c| c.status != 'archived' }
    limit_time = Time.now - days * 24 * 60 * 60
    courses.delete_if { |c| c.updated_at < limit_time }
  end

  def self.associated_by(user_id, role)
    courses = CourseMember.where(user_id: user_id, role: role).order(updated_at: :desc).to_a
    courses.map!(&:course)
  end

  def self.not_associated_by(user_id)
    courses = Course.where(status: 'open').order(created_at: :desc).limit(30).to_a
    courses.delete_if { |c| CourseMember.find_by_course_id_and_user_id(c.id, user_id) }
  end

  # def self.associated_by_with_status user_id, role, status
  #  courses = self.associated_by user_id, role
  #  return courses.delete_if { |c| c.status != status }
  # end
  #
  # def self.associated_by_without_status user_id, role, status
  #  courses = self.associated_by user_id, role
  #  return courses.delete_if { |c| c.status == status }
  # end

  def self.open_with(user_id)
    user = User.find(user_id)
    return Course.where(status: 'open').order(updated_at: :desc).limit(100) if user.system_staff?

    courses = CourseMember.where(user_id: user_id).order(updated_at: :desc).to_a
    courses.map!(&:course)
    courses.delete_if { |c| c.status != 'open' }
  end

  def self.not_open_with(user_id)
    courses = CourseMember.where(user_id: user_id).order(updated_at: :desc).to_a
    courses.map!(&:course)
    courses.delete_if { |c| (c.status == 'open') || ((c.status == 'draft') && (c.learner? user_id)) }
  end

  def self.transitionable?(from_status, to_status)
    return true if from_status == to_status
    case from_status
    when 'draft'
      return true if to_status != 'archived'
    when 'open'
      return true if to_status == 'archived'
    when 'archived'
      return true if to_status == 'open'
    end
    false
  end

  def deletable?(user_id)
    return false if new_record?
    lessons.size.zero? && (staff? user_id)
  end

  def fill_goals
    (COURSE_GOAL_MAX_SIZE - goals.size).times do |_g|
      goals.build
    end
  end

  def assistant?(user_id)
    user_role(user_id) == 'assistant'
  end

  def evaluator?(user_id)
    lessons.each do |l|
      return true if user_id.to_i == l.evaluator_id
    end
    false
  end

  def learner?(user_id)
    user_role(user_id) == 'learner'
  end

  def manager?(user_id)
    user_role(user_id) == 'manager'
  end

  def manager_changeable?(user_id)
    (managers.size > 1) && (manager?(user_id) || User.find(user_id).system_staff?)
  end

  def staff?(user_id)
    role = user_role user_id
    (role == 'manager') || (role == 'assistant')
  end

  def staffs
    managers + assistants
  end

  def presence_of_goal
    errors.add(:goals, 'を、1つ以上設定する必要があります') if goals.empty?
  end

  def user_role(user_id)
    return 'new' unless User.find_by_id(user_id)
    association = CourseMember.find_by_user_id_and_course_id(user_id, id)
    association ? association.role : 'pending'
  end

  def eval_category
    lessons = self.lessons
    return if lessons.size.zero?
    eval_lessons = lessons.select { |x| x.evaluator_id > 0 }
    case eval_lessons.size
    when 0
      return 'none'
    when lessons.size
      return 'all'
    else
      return 'some'
    end
  end

  # ====================================================================
  # Private Functions
  # ====================================================================
  private

  def set_default_value
    self.folder_id = ym_random_string(FOLDER_NAME_LENGTH) unless folder_id
  end
end
