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
#

require 'date'
class Term < ApplicationRecord
  has_many :courses
  validates_presence_of :end_at
  validates_presence_of :start_at
  validates_presence_of :title
  validates_uniqueness_of :title

  # ====================================================================
  # Public Functions
  # ====================================================================
  def self.selectables(category)
    terms = Term.all.order(start_at: :desc)
    selectables = []
    day = Date.today
    terms.each do |term|
      case category
      when 'hereafter'
        # new course can be created from 10 months prior to term.start_at
        selectables.push([term.title, term.id]) if ((term.start_at - 10.months)..term.end_at).cover? day
      when 'all'
        selectables.push([term.title, term.id])
      end
    end
    selectables
  end

  def deletable?(user_id)
    return false if new_record?
    user = User.find user_id
    user && user.system_staff? && courses.size.zero?
  end
end
