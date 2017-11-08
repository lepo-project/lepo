# == Schema Information
#
# Table name: bookmarks
#
#  id            :integer          not null, primary key
#  manager_id    :integer
#  display_order :integer
#  display_title :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  target_id     :integer
#  target_type   :string           default("web")
#

class Bookmark < ApplicationRecord
  belongs_to :manager, class_name: 'User'
  belongs_to :target, class_name: 'WebPage'
  validates_presence_of :display_order
  validates_presence_of :display_title
  validates_presence_of :manager_id
  validates_presence_of :target_id
  validates_inclusion_of :target_type, in: %w[web]
  validates_uniqueness_of :display_title, scope: [:manager_id]
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
