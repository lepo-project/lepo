# == Schema Information
#
# Table name: links
#
#  id            :integer          not null, primary key
#  manager_id    :integer
#  display_order :integer
#  url           :text
#  title         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Link < ApplicationRecord
  belongs_to :manager, class_name: 'User'
  validates_presence_of :display_order
  validates_presence_of :manager_id
  validates_presence_of :title
  validates_presence_of :url
  validates_uniqueness_of :title, scope: [:manager_id]
  validates :url, format: URI.regexp(%w[http https])

  # ====================================================================
  # Public Functions
  # ====================================================================
  def self.by_user(user_id)
    Link.where(manager_id: user_id).order(display_order: :asc).limit(10).to_a
  end

  def self.by_system_staffs
    links = []
    User.system_staffs.each do |sm|
      links += by_user sm.id
    end
    links.sort_by(&:display_order)
  end

  def deletable?(user)
    return true if user.system_staff?
    (manager_id == user.id)
  end
end
