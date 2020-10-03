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
  validates :content_id, presence: true
  validates :content_id, uniqueness: { scope: :user_id }
  validates :role, inclusion: { in: %w[manager assistant user] }
  validates :user_id, presence: true
  validate :content_manageable_user, if: -> {role != 'assistant'}

  def content_manageable_user
    errors.add(:base, 'Content manager and user must be content_manageable.') unless user.content_manageable?
  end

  def deletable?
    stickies = Sticky.where(content_id: content_id, manager_id: user_id)
    case role
    when 'manager'
      return false
    when 'assistant'
      return stickies.size.zero?
    when 'user'
      return stickies.size.zero?
    end
    false
  end
end
