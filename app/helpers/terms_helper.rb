require 'date'
module TermsHelper
  # ====================================================================
  # Public Functions
  # ====================================================================

  def selectable_terms(category)
    terms = Term.all.order(start_at: :desc)
    selectables = []
    day = Date.today
    terms.each do |term|
      next if SYSTEM_ROSTER_SYNC == :on && term.sourced_id.blank?
      next if SYSTEM_ROSTER_SYNC == :off && term.sourced_id.present?
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
end
