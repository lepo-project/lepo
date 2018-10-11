# == Schema Information
#
# Table name: terms
#
#  id         :integer          not null, primary key
#  title      :string
#  start_at   :date
#  end_at     :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  guid       :string
#

class Term < ApplicationRecord
  has_many :courses
  validates_presence_of :end_at
  validates_presence_of :start_at
  validates_presence_of :title
  validates_uniqueness_of :guid, allow_nil: true
  validates_uniqueness_of :title

  # ====================================================================
  # Public Functions
  # ====================================================================
  def self.create_from_roster(roster_term)
    return unless where(guid: roster_term['sourcedId']).count.zero?
    Term.create(guid: roster_term['sourcedId'], title: roster_term['title'], start_at: roster_term['startDate'], end_at: roster_term['endDate'])
  end

  def deletable?(user_id)
    return false if new_record?
    user = User.find user_id
    user && user.system_staff? && courses.size.zero?
  end
end
