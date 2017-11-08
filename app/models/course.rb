# == Schema Information
#
# Table name: courses
#
#  id                 :integer          not null, primary key
#  term_id            :integer
#  folder_name        :string
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
  path: ':rails_root/public/system/:class/:folder_name/:style/:filename',
  url: ':relative_url_root/system/:class/:folder_name/:style/:filename',
  default_url: '/assets/:class/:style/missing.png',
  styles: { px40: '40x40>', px80: '80x80>', original: '160x160>' }
  validates_attachment_content_type :image, content_type: ['image/gif', 'image/jpeg', 'image/pjpeg', 'image/png', 'image/x-png']
  validates_attachment_size :image, less_than: IMAGE_MAX_FILE_SIZE.megabytes # original file is resized, so this is not important
  belongs_to :term
  has_many :assistants, -> { where('course_members.role = ?', 'assistant') }, through: :course_members, source: :user
  has_many :contents, -> { order('lessons.display_order asc') }, through: :lessons
  has_many :course_members, dependent: :destroy
  has_many :goals, -> { order(id: :asc) }, dependent: :destroy
  has_many :learners, -> { where('course_members.role = ?', 'learner').order(signin_name: :asc) }, through: :course_members, source: :user
  has_many :lessons, -> { order(display_order: :asc) }
  has_many :managers, -> { where('course_members.role = ?', 'manager') }, through: :course_members, source: :user
  has_many :original_draft_work_sheets, -> { where('notes.category = ? and notes.status = ?', 'work', 'distributed_draft').order(updated_at: :desc) }, class_name: 'Note'
  has_many :original_open_work_sheets, -> { where('notes.category = ? and notes.status = ?', 'work', 'open').order(updated_at: :desc) }, class_name: 'Note'
  has_many :original_review_work_sheets, -> { where('notes.category = ? and notes.status = ?', 'work', 'review').order(updated_at: :desc) }, class_name: 'Note'
  has_many :original_work_sheets, -> { where('notes.category = ? and notes.status in (?)', 'work', %w[distributed_draft open review]).order(updated_at: :desc) }, class_name: 'Note'
  has_many :members, through: :course_members, source: :user
  has_many :notices, dependent: :destroy
  has_many :open_lessons, -> { where('lessons.status = ?', 'open').order(display_order: :asc) }, class_name: 'Lesson'
  has_many :outcomes, dependent: :destroy
  has_many :notes
  validates_presence_of :folder_name
  validates_presence_of :overview
  validates_presence_of :term_id
  validates_presence_of :title
  validates_uniqueness_of :folder_name
  # FIXME: Group work
  validates_inclusion_of :groups_count, in: (1..COURSE_GROUP_MAX_SIZE).to_a
  validates_inclusion_of :status, in: %w[draft open archived]
  accepts_nested_attributes_for :goals, allow_destroy: true, reject_if: proc { |att| att['title'].blank? }, limit: COURSE_GOAL_MAX_SIZE

  # ====================================================================
  # Public Functions
  # ====================================================================
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

  def self.work_sheet_distributable_by(user_id)
    courses = associated_by(user_id, %w[manager staff])
    courses.delete_if { |c| %w[draft open].exclude? c.status }
  end

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

  def self.search(term_id, status, title_parts, manager_parts)
    @candidates = Course.all
    @candidates = @candidates.where(term_id: term_id) unless term_id.empty?
    @candidates = @candidates.where(status: status) unless status.empty?
    @candidates = @candidates.where('title like ?', '%' + title_parts + '%') if title_parts.present?
    if manager_parts.present?
      manager_parts = manager_parts.tr('　', ' ')
      search_words = manager_parts.split(' ')
      case search_words.length
      when 2
        manager_ids = User.where('family_name like ? and given_name like ?', "%#{search_words[0]}%", "%#{search_words[1]}%").or(User.where('family_name like ? and given_name like ? ', "%#{search_words[1]}%", "%#{search_words[0]}%")).pluck(:id)
      else
        manager_ids = User.search(manager_parts, '', User.count).pluck(:id)
      end
      course_ids = CourseMember.where(role: 'manager').where('user_id IN (?)', manager_ids).pluck(:course_id).uniq
      @candidates = @candidates.where('id IN(?)', course_ids)
    end
    @candidates.limit(COURSE_SEARCH_MAX_SIZE)
  end

  # FIXME: Group work
  def group_index_for(user_id)
    CourseMember.where(course_id: id, user_id: user_id).first.group_index
  end

  # FIXME: Group work
  def learners_in_group(index)
    user_ids = course_members.where('course_members.role = ? and course_members.group_index = ?', 'learner', index).order(user_id: :asc).pluck(:user_id)
    User.where(id: user_ids).order(signin_name: :asc)
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
    notes = Note.where("category = 'work' and course_id = ? and updated_at >= ? and stars_count > 1", id, Date.today - duration).order('stars_count DESC, created_at DESC').limit(max_size)
    notes.to_a.delete_if { |note| !note.open? }
  end

  # def hot_sources
  #   duration = 28
  #   max_size = 5
  #
  #   notes_by_members = []
  #   members.each do |member|
  #     notes = Note.where("category = 'work' and course_id = ? and manager_id = ?", id, member.id)
  #     notes.to_a.delete_if { |note| !note.open? }
  #     note_ids = []
  #     notes.each do |note|
  #       note_ids.push note.id
  #     end
  #     notes_by_members.push [member.id, note_ids]
  #   end
  #
  #   snippets = []
  #   notes_by_members.each do |sbm|
  #     snippets.push Snippet.where("source_type = 'web' and note_id in (?) and updated_at >= ?", sbm[1], Date.today - duration).select(:source_id).distinct
  #   end
  #   snippets.flatten!
  #
  #   snippets_with_count = []
  #   snippets.each do |s|
  #     count = snippets.select { |snppt| snppt['source_id'] == s['source_id'] }.size
  #     snippets_with_count.push [s['source_id'], count]
  #   end
  #   snippets_with_count.uniq!
  #   snippets_with_count.sort! { |p, q| q[1] <=> p[1] }
  #
  #   hot_sources = []
  #   snippets_with_count[0, max_size].each do |swc|
  #     hot_sources.push WebPage.find_by(id: swc[0]) if swc[1] > 1
  #   end
  #   hot_sources
  # end

  def learner_work_sheets(user_id, course_staff)
    notes = []
    if course_staff
      original_draft_work_sheets.each do |ow|
        notes += Note.where(course_id: id, category: 'work', original_ws_id: ow.id).order(updated_at: :desc).to_a
      end
    else
      original_draft_work_sheets.each do |ow|
        notes += Note.where(course_id: id, category: 'work', original_ws_id: ow.id, manager_id: user_id).order(updated_at: :desc).to_a
      end
    end
    original_review_work_sheets.each do |ow|
      notes += Note.where(course_id: id, category: 'work', original_ws_id: ow.id).order(updated_at: :desc).to_a
    end
    original_open_work_sheets.each do |ow|
      notes += Note.where(course_id: id, category: 'work', original_ws_id: ow.id).order(updated_at: :desc).to_a
    end
    notes
  end

  def lesson_note(manager_id)
    # create lesson note if it doesn't exist
    lesson_note = Note.find_by(manager_id: manager_id, course_id: id, category: 'lesson')
    lesson_note ||= Note.create(manager_id: manager_id, course_id: id, category: 'lesson', title: title, overview: overview, status: 'associated_course')
    lesson_note
  end

  def update_lesson_notes
    notes = Note.where(course_id: id, category: 'lesson')
    notes.each do |note|
      note.update_attributes(title: title, overview: overview) if (note.title != title) || (note.overview != overview)
    end
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
    (managers.size > 1) && (manager?(user_id) || User.system_staff?(user_id))
  end

  def member?(user_id)
    role = user_role user_id
    (role == 'manager') || (role == 'assistant') || (role == 'learner')
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
    return 'new' unless User.find_by(id: user_id)
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
    self.folder_name = ym_random_string(FOLDER_NAME_LENGTH) unless folder_name
  end
end
