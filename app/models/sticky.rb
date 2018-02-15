# == Schema Information
#
# Table name: stickies
#
#  id          :integer          not null, primary key
#  manager_id  :integer
#  content_id  :integer
#  course_id   :integer
#  target_id   :integer
#  target_type :string           default("Page")
#  stars_count :integer          default(0)
#  category    :string           default("private")
#  message     :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Sticky < ApplicationRecord
  belongs_to :manager, class_name: 'User'
  belongs_to :content
  belongs_to :target, polymorphic: true
  has_many :notes, through: :note_indices
  has_many :note_indices, as: :item, dependent: :destroy
  has_many :sticky_stars, dependent: :destroy
  has_many :stared_users, -> { where('sticky_stars.stared = ?', true) }, through: :sticky_stars, source: :manager
  validates_absence_of :content_id, if: "target_type == 'Note'"
  validates_presence_of :content_id, if: "target_type == 'Page'"
  validates_presence_of :course_id, if: "category == 'course'"
  validates_presence_of :manager_id
  validates_presence_of :target_id
  validates_inclusion_of :category, in: %w[private course]
  validates_inclusion_of :target_type, in: %w[Page Note]

  # ====================================================================
  # Public Functions
  # ====================================================================
  def self.search_by_course(user_id, course_id, keyword = nil)
    result_limit = 20
    if keyword && !keyword.empty?
      results = where('course_id = ? AND category = ? AND manager_id = ? AND  message LIKE ?', course_id, 'private', user_id, "%#{keyword}%").order(created_at: :desc).limit(result_limit).to_a
      results += where('course_id = ? AND category = ? AND  message LIKE ?', course_id, 'course', "%#{keyword}%").order(created_at: :desc).limit(result_limit).to_a
      searched_users = User.search keyword, '', result_limit
      searched_users.each do |su|
        results += where(course_id: course_id, category: 'private', manager_id: su.id).order(created_at: :desc).limit(result_limit).to_a if su.id == user_id
        results += where(course_id: course_id, category: 'course', manager_id: su.id).order(created_at: :desc).limit(result_limit).to_a
      end
    else
      results = where(course_id: course_id, category: 'private', manager_id: user_id).order(created_at: :desc).limit(result_limit).to_a
      results += where(course_id: course_id, category: 'course').order(created_at: :desc).limit(result_limit).to_a
    end
    results.sort! { |a, b| b.created_at <=> a.created_at }
    results[0..(result_limit - 1)]
  end

  def self.search_by_manager(user_id, keyword = nil)
    result_limit = 20
    if keyword && !keyword.empty?
      where('manager_id = ? AND message LIKE ?', user_id, "%#{keyword}%").order(created_at: :desc).limit(result_limit)
    else
      where(manager_id: user_id).order(created_at: :desc).limit(result_limit)
    end
  end

  def self.size_by_user(user_id)
    stickies = {}
    s_private = Sticky.where(category: 'private', manager_id: user_id)
    s_course = Sticky.where(category: 'course', manager_id: user_id)

    stickies['private'] = s_private.size
    stickies['course'] = s_course.size
    stickies
  end

  def manager?(user_id)
    manager.id == user_id
  end

  def course_id_for_link
    return 0 if !course_id || course_id.zero?
    course_id
  end

  def destroyable?(user_id)
    manager? user_id
  end

  def related_to?(user_id)
    return true if manager_id == user_id
    user_star = StickyStar.find_by(sticky_id: id, manager_id: user_id)
    return true if user_star && user_star.stared
    false
  end
end
