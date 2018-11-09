# == Schema Information
#
# Table name: courses
#
#  id           :integer          not null, primary key
#  term_id      :integer
#  title        :string
#  overview     :text
#  status       :string           default("draft")
#  groups_count :integer          default(1)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  image_data   :text
#  guid         :string
#  weekday      :integer          default(9)
#  period       :integer          default(0)
#  enabled      :boolean          default(TRUE)
#

class Course < ApplicationRecord
  include ImageUploader::Attachment.new(:image)
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
  validates_presence_of :overview
  validates_presence_of :term_id
  validates_presence_of :title
  # FIXME: Group work
  validates_inclusion_of :groups_count, in: (1..COURSE_GROUP_MAX_SIZE).to_a
  validates_inclusion_of :status, in: %w[draft open archived]
  validates :enabled, inclusion: { in: [true, false] }
  validates_inclusion_of :period, in: (0..COURSE_PERIOD_MAX_SIZE).to_a
  # 1: Mon, 2: Tue, 3: Wed, 4: Thu, 5: Fri, 6: Sat, 7: Sun, 9: Not weekly course
  validates_inclusion_of :weekday, in: [1, 2, 3, 4, 5, 6, 7, 9]
  validates_uniqueness_of :guid, allow_nil: true
  accepts_nested_attributes_for :goals, allow_destroy: true, reject_if: proc { |att| att['title'].blank? }, limit: COURSE_GOAL_MAX_SIZE

  # ====================================================================
  # Public Functions
  # ====================================================================
  def self.associated_by(user_id, role)
    courses = CourseMember.where(user_id: user_id, role: role).order(updated_at: :desc).to_a
    courses.map!(&:course)
    courses.delete_if { |c| !c.enabled }
  end

  def self.find_enabled_by course_id
    find_by(id: course_id, enabled: true)
  end

  def self.work_sheet_distributable_by(user_id)
    courses = associated_by(user_id, %w[manager assistant])
    courses.delete_if { |c| !c.enabled }
    courses.delete_if { |c| %w[draft open].exclude? c.status }
  end

  def self.open_with(user_id)
    user = User.find(user_id)
    return Course.where(status: 'open', enabled: true).order(:weekday, :period).limit(100) if user.system_staff?

    courses = CourseMember.where(user_id: user_id).to_a
    courses.map!(&:course)
    courses.delete_if { |c| !c.enabled }
    courses.delete_if { |c| c.status != 'open' }
    courses.sort! do |a, b|
      (a[:weekday] <=> b[:weekday]).nonzero? || (a[:period] <=> b[:period])
    end
  end

  def self.not_open_with(user_id)
    courses = CourseMember.where(user_id: user_id).order(updated_at: :desc).to_a
    courses.map!(&:course)
    courses.delete_if { |c| !c.enabled }
    courses.delete_if { |c| (c.status == 'open') || ((c.status == 'draft') && (c.learner? user_id)) }
  end

  def self.search(term_id, status, title_parts, manager_parts)
    @candidates = Course.where(enabled: true)
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

  def self.sync_roster(term_id, rcourses)
    # Create and Update with OneRoster data

    ids = []
    rcourses.each do |rc|
      # REQUIREMENT: period vaule in OneRoster is [weekday number]-[time period number] format
      weekday = rc['periods'].split(',')[0].split('-')[0]
      period = rc['periods'].split(',')[0].split('-')[1]
      course = Course.find_or_initialize_by(guid: rc['sourcedId'])
      overview = course.overview.blank? ? '...' : course.overview
      if course.update_attributes(enabled: true, term_id: term_id, title: rc['title'], overview: overview, weekday: weekday, period: period)
        ids.push({id: course.id, guid: course.guid})
        Goal.create(course_id: course.id, title: '...') unless Goal.where(course_id: course.id).present?
      end
    end
    ids
  end

  def self.logical_delete_unused(term_id, course_ids)
    api_ids = course_ids.map{|ci| ci[:id]}
    courses = where(term_id: term_id).where.not(id: api_ids)
    courses.each do |course|
      course.update_atributes(enabled: false)
    end
    courses.empty? ? [] : courses.pluck(:id)
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
    Sticky.where("category = 'course' and course_id = ? and created_at >= ? and stars_count > 1", id, duration.days.ago).order('stars_count DESC, created_at DESC').limit(max_size)
  end

  def hot_notes
    duration = 14
    max_size = 5
    notes = Note.where("category = 'work' and course_id = ? and updated_at >= ? and stars_count > 1", id, duration.days.ago).order('stars_count DESC, created_at DESC').limit(max_size)
    notes.to_a.delete_if { |note| !note.open? }
  end

  def image_id(version)
    image[version.to_sym].id.split("/").last.split(".").first
  end

  def image_rails_url(version_num)
    file_id = image_id('px' + version_num)
    "#{Rails.application.config.relative_url_root}/courses/#{id}/image?file_id=#{file_id}&version=px#{version_num}" if image && (%w[40 80 160].include? version_num)
  end

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
    association = CourseMember.find_by(user_id: user_id, course_id: id)
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
end
