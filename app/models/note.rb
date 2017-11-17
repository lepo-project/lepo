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
  has_many :contents, -> { order('note_indices.display_order asc') }, through: :note_indices, source: :item, source_type: 'Content'
  has_many :direct_snippets, -> { where('snippets.source_type = ?', 'direct').order('note_indices.display_order asc') }, through: :note_indices, source: :item, source_type: 'Snippet'
  has_many :note_indices, -> { order('note_indices.display_order asc, note_indices.updated_at asc') }, dependent: :destroy
  has_many :note_stars, dependent: :destroy
  has_many :snippets, -> { order('note_indices.display_order asc') }, through: :note_indices, source: :item, source_type: 'Snippet'
  has_many :stared_users, -> { where('note_stars.stared = ?', true) }, through: :note_stars, source: :manager
  has_many :stickies, as: :target, dependent: :destroy
  has_many :text_snippets, -> { where('snippets.category in ("text", "header", "subheader")').order('note_indices.display_order asc') }, through: :note_indices, source: :item, source_type: 'Snippet'
  has_many :upload_snippets, -> { where('snippets.source_type = ?', 'upload').order('note_indices.display_order asc') }, through: :note_indices, source: :item, source_type: 'Snippet'
  has_many :web_snippets, -> { where('snippets.source_type = ?', 'web').order('note_indices.display_order asc') }, through: :note_indices, source: :item, source_type: 'Snippet'
  has_many :web_text_snippets, -> { where('snippets.source_type = ? and snippets.category = ?', 'web', 'text').order('note_indices.display_order asc') }, through: :note_indices, source: :item, source_type: 'Snippet'
  validates_presence_of :manager_id
  validates_presence_of :title
  validates_inclusion_of :peer_reviews_count, in: (0..NOTE_PEER_REVIEW_MAX_SIZE).to_a
  validates_inclusion_of :category, in: %w[private lesson work]
  validates_inclusion_of :status, in: %w[draft archived], if: "category == 'private'"
  validates_inclusion_of :status, in: %w[associated_course], if: "category == 'lesson'"
  validates_inclusion_of :status, in: %w[draft distributed_draft review open archived original_ws], if: "category == 'work'"
  validates_numericality_of :course_id, allow_nil: false, equal_to: 0, if: "category == 'private'"
  validates_numericality_of :course_id, allow_nil: false, greater_than: 0, if: "category != 'private'"
  validates_numericality_of :original_ws_id, allow_nil: false, greater_than_or_equal_to: 0, if: "category == 'work'"
  validates_numericality_of :original_ws_id, allow_nil: false, equal_to: 0, if: "category != 'work'"
  # FIXME: following validation does NOT work with if condition
  # validates_uniqueness_of :manager_id, scope: [:course_id], if: "category == 'lesson'"
  # validates_uniqueness_of :manager_id, scope: [:course_id], if: proc { |note| note.category == 'lesson' }

  # ====================================================================
  # Public Functions
  # ====================================================================
  def align_display_order
    note_indices.each_with_index do |ni, i|
      ni.update_attributes(display_order: i + 1)
    end
  end

  # For the mutual review of notes by anonymously
  def anonymous?(user_id)
    return false if manager_id == user_id
    if category == 'work' && status == 'original_ws'
      original_ws = Note.find_by(id: original_ws_id)
      (original_ws.status == 'review')
    else
      false
    end
  end

  def content_header_id(content_id)
    return unless category == 'lesson'
    ni = NoteIndex.find_by(note_id: id, item_type: 'Content', item_id: content_id)
    ni ? ni.id : nil
  end

  def deletable?(user_id)
    case category
    when 'private'
      (manager_id == user_id) && snippets.size.zero? && stickies.size.zero?
    when 'work'
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
    note_indices.each do |ni|
      case ni.item_type
      when 'Snippet'
        case ni.item.category
        when 'text'
          export_html += '<p>' + ni.item.description + '</p>' if ni.item.source_type == 'direct'
        when 'header'
          export_html += '<h2>' + ni.header_title(note_indices) + '</h2>'
        when 'subheader'
          export_html += '<h3>' + ni.subheader_title(note_indices) + '</h3>'
        end
      when 'Content'
        export_html += '<h2>' + ni.header_title(note_indices) + '</h2>'
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
    when 'work'
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
      references.push WebPage.find(id)
    end
    references
  end

  def review_or_open?
    case category
    when 'work'
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
    when 'work'
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

  def snippets_char_count(source_type)
    char_count = 0
    case source_type
    when 'all'
      snippets.each do |sni|
        char_count += sni.description.size if (%w[text header subheader].include? sni.category) || (sni.source_type == 'web' && sni.category == 'pdf')
      end
    when 'direct'
      direct_snippets.each do |sni|
        char_count += sni.description.size if %w[text header subheader].include? sni.category
      end
    when 'web'
      web_snippets.each do |sni|
        char_count += sni.description.size if sni.category == 'text'
      end
    end
    char_count
  end

  def snippets_media_count(source_type)
    case source_type
    when 'all'
      snippets.size - text_snippets.size
    when 'upload'
      upload_snippets.size
    when 'web'
      web_snippets.size - web_text_snippets.size
    end
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
    when 'work'
      course = Course.find_by(id: course_id)
      return false if !course || !course.staff?(user_id)
      case update_status
      when 'draft'
        new_record? || Note.where(original_ws_id: id).empty?
      when 'distributed_draft'
        !new_record? && course.original_work_sheets.empty?
      when 'review', 'open'
        Note.where(original_ws_id: id).any? && course.original_work_sheets.size == 1
      when 'archived'
        !new_record?
      else
        false
      end
    else
      false
    end
  end

  def update_items(open_lessons)
    # prepare items for lesson note
    items = []
    display_order = 0
    open_lessons.each do |lesson|
      display_order += 1
      content = lesson.content
      items.push note_id: id, item_id: content.id, item_type: 'Content', display_order: display_order
      stickies = Sticky.where(manager_id: manager_id, course_id: course_id, content_id: content.id, target_type: 'PageFile')
      stickies.each do |s|
        display_order += 1
        items.push note_id: id, item_id: s.id, item_type: 'Sticky', display_order: display_order
      end
      content.page_files.each do |pf|
        snippets = Snippet.where(manager_id: manager_id, category: 'text', source_type: 'page_file', source_id: pf.id)
        snippets.each do |s|
          display_order += 1
          items.push note_id: id, item_id: s.id, item_type: 'Snippet', display_order: display_order
        end
      end
    end

    # update note_indices for lesson note
    current_indices = note_indices.to_a
    items.each do |item|
      indices = current_indices.select { |ci| (ci.item_id == item[:item_id]) && (ci.item_type == item[:item_type]) }
      if indices[0]
        indices[0].update_attributes(display_order: item[:display_order]) if indices[0].display_order != item[:display_order]
        current_indices.delete_if { |ci| ci.id == indices[0].id }
      else
        NoteIndex.create item
      end
    end
    current_indices.each(&:destroy)
  end
end
