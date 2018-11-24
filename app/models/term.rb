# == Schema Information
#
# Table name: terms
#
#  id         :integer          not null, primary key
#  sourced_id :string
#  title      :string
#  start_at   :datetime
#  end_at     :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Term < ApplicationRecord
  has_many :courses, -> { where('courses.enabled = ?', true) }
  validates_presence_of :end_at
  validates_presence_of :start_at
  validates_presence_of :title
  validates_uniqueness_of :sourced_id, allow_nil: true
  validates_uniqueness_of :title
  validate :end_at_is_after_start_at

  # ====================================================================
  # Public Functions
  # ====================================================================
  def self.sync_roster(rterms)
    # Create and Update with OneRoster data

    # Synchronous term condition
    now = Time.zone.now
    rterms.select!{|rt| ((Time.zone.parse(rt['startDate']) - 1.month)...Time.zone.parse(rt['endDate'])).cover? now}

    ids = []
    rterms.each do |rt|
      term = Term.find_or_initialize_by(sourced_id: rt['sourcedId'])
      if term.update_attributes(title: rt['title'], start_at: rt['startDate'], end_at: rt['endDate'])
        ids.push({id: term.id, sourced_id: term.sourced_id, status: term.status})
      end
    end
    ids
  end

  def creatable?(user_id)
    # Not permitted when SYSTEM_ROSTER_SYNC is :suspended
    return false if %i[on off].exclude? SYSTEM_ROSTER_SYNC
    user = User.find user_id
    user && user.system_staff?
  end

  def deletable?(user_id)
    return false if new_record?
    return false unless courses.size.zero?
    updatable? user_id
  end

  def updatable?(user_id)
    return false if SYSTEM_ROSTER_SYNC == :on && sourced_id.blank?
    return false if SYSTEM_ROSTER_SYNC == :off && sourced_id.present?
    creatable? user_id
  end

  def status
    now = Time.zone.now
    if now < start_at
      'draft'
    elsif end_at <= now
      'archived'
    else
      'open'
    end
  end

  def to_roster_hash
    hash = {
      title: self.title,
      type: 'term',
      startDate: self.start_at,
      endDate: self.end_at,
      schoolYear: self.end_at.year
    }
  end

  # ====================================================================
  # Private Functions
  # ====================================================================

  private

  def end_at_is_after_start_at
    # start_at: inclusive start date for the term
    # end_at: exclusive end date for the term
    if start_at.present? && end_at.present?
      errors.add(:end_at) unless end_at > start_at
    end
  end
end
