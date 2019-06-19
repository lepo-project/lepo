# == Schema Information
#
# Table name: bookmarks
#
#  id            :integer          not null, primary key
#  manager_id    :integer
#  display_order :integer
#  display_title :string
#  target_id     :integer
#  target_type   :string           default("web")
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Bookmark < ApplicationRecord
  belongs_to :manager, class_name: 'User'
  belongs_to :target, class_name: 'WebPage'
  validates :display_order, presence: true
  validates :display_title, presence: true
  validates :display_title, uniqueness: { scope: :manager_id }
  validates :manager_id, presence: true
  validates :target_id, presence: true
  validates :target_type, inclusion: { in: %w[web] }
  after_destroy :destroy_target

  # ====================================================================
  # Public Functions
  # ====================================================================
  def self.by_system_staffs
    bookmarks = []
    User.system_staffs.each do |ss|
      bookmarks += by_user ss.id
    end
    bookmarks.sort_by(&:display_order)
  end

  def self.by_user(user_id)
    Bookmark.where(manager_id: user_id).order(display_order: :asc).limit(BOOKMARK_MAX_SIZE).to_a
  end

  def deletable?(user)
    return true if user.system_staff?
    (manager_id == user.id)
  end

  def url
    target_type == 'web' ? target.url : ''
  end

  # ====================================================================
  # Private Functions
  # ====================================================================
  private

  def destroy_target
    case target_type
    when 'web'
      target.destroy if target.deletable?
    end
  end
end
