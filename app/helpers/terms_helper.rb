require 'date'
module TermsHelper
  # ====================================================================
  # Public Functions
  # ====================================================================

  def term_display_title term_title
    # FIXME: term format condition, xxxx-yyyyy
    term_words = term_title.split '-'
    t('helpers.term_year', year: term_words[0]) + t("helpers.term_category_#{term_words[1]}")
  end

  def selectable_terms(category)
    terms = Term.all.order(start_at: :desc)
    selectables = []
    day = Date.today
    terms.each do |term|
      title = term_display_title term.title
      case category
      when 'hereafter'
        # new course can be created from 10 months prior to term.start_at
        selectables.push([title, term.id]) if ((term.start_at - 10.months)..term.end_at).cover? day
      when 'all'
        selectables.push([title, term.id])
      end
    end
    selectables
  end
end
