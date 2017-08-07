# == Schema Information
#
# Table name: content_members
#
#  id         :integer          not null, primary key
#  content_id :integer
#  user_id    :integer
#  role       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ContentMember < ApplicationRecord
  belongs_to :content
  belongs_to :user
  validates_presence_of :content_id
  validates_presence_of :user_id
  validates_uniqueness_of :content_id, scope: [:user_id]
  validates_inclusion_of :role, in: %w[manager assistant instructor]
  validate :content_manageable_user, if: "role != 'assistant'"

  def content_manageable_user
    errors.add(:base, 'Content manager and instructor must be content_manageable.') unless user.content_manageable?
  end

  def deletable?
    stickies = Sticky.where(content_id: content_id, manager_id: user_id)
    case role
    when 'manager'
      return false
    when 'assistant'
      return stickies.size.zero?
    when 'instructor'
      return stickies.size.zero?
    end
    false
  end
end
