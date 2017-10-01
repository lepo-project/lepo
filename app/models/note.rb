# == Schema Information
#
# Table name: notes
#
#  id                 :integer          not null, primary key
#  manager_id         :integer
#  course_id          :integer          default(0)
#  original_ws_id     :integer          default(0)
#  title              :string
#  overview           :text
#  status             :string           default("draft")
#  stars_count        :integer          default(0)
#  peer_reviews_count :integer          default(0)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  category           :string           default("private")
#

class Note < ApplicationRecord
  belongs_to :course
  belongs_to :manager, class_name: 'User'
  has_many :direct_snippets, -> { where('snippets.source_type = ?', 'direct').order(display_order: :asc, updated_at: :desc) }, class_name: 'Snippet'
  has_many :direct_text_snippets, -> { where('snippets.source_type = ? and snippets.category in ("text", "header", "subheader")', 'direct').order(display_order: :asc, updated_at: :desc) }, class_name: 'Snippet'
  has_many :note_stars, dependent: :destroy
  has_many :snippets, -> { order(display_order: :asc, updated_at: :asc) }
  has_many :stared_users, -> { where('note_stars.stared = ?', true) }, through: :note_stars, source: :manager
  has_many :stickies, -> { where('stickies.target_type = ?', 'note') }, foreign_key: 'target_id', dependent: :destroy
  has_many :text_snippets, -> { where('snippets.category in ("text", "header", "subheader")').order(display_order: :asc, updated_at: :desc) }, class_name: 'Snippet'
  has_many :web_snippets, -> { where('snippets.source_type = ?', 'web').order(display_order: :asc, updated_at: :desc) }, class_name: 'Snippet'
  has_many :web_text_snippets, -> { where('snippets.source_type = ? and snippets.category in ("text", "header", "subheader")', 'web').order(display_order: :asc, updated_at: :desc) }, class_name: 'Snippet'
  validates_presence_of :manager_id
  validates_presence_of :title
  validates_inclusion_of :peer_reviews_count, in: (0..NOTE_PEER_REVIEW_MAX_SIZE).to_a
  validates_inclusion_of :category, in: %w[private worksheet]
  validates_inclusion_of :status, in: %w[draft archived associated_course], if: "category == 'private'"
  validates_inclusion_of :status, in: %w[draft distributed_draft review open archived original_ws], if: "category == 'worksheet'"
  validates_numericality_of :course_id, allow_nil: false, greater_than_or_equal_to: 0, if: "category == 'private'"
  validates_numericality_of :course_id, allow_nil: false, greater_than: 0, if: "category == 'worksheet'"
  validates_numericality_of :original_ws_id, allow_nil: false, equal_to: 0, if: "category == 'private'"
  validates_numericality_of :original_ws_id, allow_nil: false, greater_than_or_equal_to: 0, if: "category == 'worksheet'"

  # ====================================================================
  # Public Functions
  # ====================================================================
  def align_display_order
    snippets.each_with_index do |snippet, i|
      snippet.update_attributes(display_order: i + 1)
    end
  end

  # For the mutual review of notes by anonymously
  def anonymous?(user_id)
    return false if manager_id == user_id
    if category == 'worksheet' && status == 'original_ws'
      original_ws = Note.find_by(id: original_ws_id)
      (original_ws.status == 'review')
    else
      false
    end
  end

  def deletable?(user_id)
    case category
    when 'private'
      (manager_id == user_id) && snippets.size.zero? && stickies.size.zero?
    when 'worksheet'
      if original_ws_id.zero?
        !Note.where(original_ws_id: id).exists?
      else
        false
      end
    else
      false
    end
  end

  def export_html
    export_html = '<h1>' + title + '</h1>'
    export_html += '<p>' + overview + '</p>'
    snippets.each do |snippet|
      case snippet.category
      when 'text'
        export_html += '<p>' + snippet.description + '</p>' if snippet.source_type == 'direct'
      when 'header'
        export_html += '<h2>' + snippet.header_title(snippets) + '</h2>'
      when 'subheader'
        export_html += '<h3>' + snippet.subheader_title(snippets) + '</h3>'
      end
    end

    unless references.size.zero?
      export_html += '<h2>' + ApplicationController.helpers.t('notes.show.references') + '</h2>'
      references.each_with_index do |ref, i|
        export_html += '<p>' + (i + 1).to_s + '. &quot;' + ApplicationController.helpers.display_title(ref) + '&quot;, ' + ref.url + ' (' + ref.created_at.strftime('%Y年%-m月%-d日') + '閲覧)</p>'
      end
    end
    export_html
  end

  def group_index
    return nil unless course_id > 0
    CourseMember.where(course_id: course_id, user_id: manager_id).first.group_index
  end

  def manager?(user_id)
    manager_id == user_id
  end

  def open?
    case category
    when 'worksheet'
      if status == 'original_ws'
        original_ws = Note.find(original_ws_id)
        (original_ws.status == 'open')
      else
        (status == 'open')
      end
    else
      false
    end
  end

  def review_or_open?
    case category
    when 'worksheet'
      if status == 'original_ws'
        original_ws = Note.find(original_ws_id)
        (original_ws.status == 'review') || (original_ws.status == 'open')
      else
        (status == 'review') || (status == 'open')
      end
    else
      false
    end
  end

  def review?
    case category
    when 'worksheet'
      if status == 'original_ws'
        original_ws = Note.find(original_ws_id)
        (original_ws.status == 'review')
      else
        (status == 'review')
      end
    else
      false
    end
  end

  def snippets_count(source_type = 'all')
    case source_type
    when 'direct'
      direct_snippets.size
    when 'web'
      web_snippets.size
    when 'media'
      snippets.size - text_snippets.size
    when 'direct_media'
      direct_snippets.size - direct_text_snippets.size
    when 'web_media'
      web_snippets.size - web_text_snippets.size
    when 'all'
      snippets.size
    end
  end

  def snippets_char_count(source_type)
    char_count = 0
    case source_type
    when 'direct'
      direct_snippets.each do |sni|
        char_count += sni.description.size if %w[text header subheader].include? sni.category
      end
    when 'web'
      web_snippets.each do |sni|
        char_count += sni.description.size if sni.category == 'text'
      end
    when 'all'
      snippets.each do |sni|
        char_count += sni.description.size if (%w[text header subheader].include? sni.category) || (sni.source_type == 'web' && sni.category == 'pdf')
      end
    end
    char_count
  end

  def reference_ids
    ids = []
    web_snippets.each do |s|
      ids.push s.source_id unless ids.include? s.source_id
    end
    ids
  end

  def references
    ids = reference_ids
    references = []
    ids.each do |id|
      references.push WebSource.find(id)
    end
    references
  end

  def status_updatable?(update_status, user_id)
    return true if status == update_status
    case category
    when 'private'
      case update_status
      when 'draft'
        true
      when 'archived'
        !new_record?
      else
        false
      end
    when 'worksheet'
      course = Course.find_by(id: course_id)
      return false if !course || !course.staff?(user_id)
      case update_status
      when 'draft'
        new_record? || Note.where(original_ws_id: id).empty?
      when 'distributed_draft'
        !new_record? && course.original_worksheets.empty?
      when 'review', 'open'
        Note.where(original_ws_id: id).any? && course.original_worksheets.size == 1
      when 'archived'
        !new_record?
      else
        false
      end
    else
      false
    end
  end
end
