# == Schema Information
#
# Table name: notes
#
#  id                 :integer          not null, primary key
#  manager_id         :integer
#  course_id          :integer
#  master_id          :integer          default(0)
#  title              :string
#  overview           :text
#  status             :string           default("private")
#  stars_count        :integer          default(0)
#  peer_reviews_count :integer          default(0)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Note < ApplicationRecord
  belongs_to :manager, class_name: 'User'
  belongs_to :course
  has_many :note_stars, dependent: :destroy
  has_many :snippets, -> { order(display_order: :asc, updated_at: :asc) }
  has_many :stickies, -> { where('stickies.target_type = ?', 'note') }, foreign_key: 'target_id', dependent: :destroy
  has_many :direct_snippets, -> { where('snippets.source_type = ?', 'direct').order(display_order: :asc, updated_at: :desc) }, class_name: 'Snippet'
  has_many :web_snippets, -> { where('snippets.source_type = ?', 'web').order(display_order: :asc, updated_at: :desc) }, class_name: 'Snippet'
  has_many :text_snippets, -> { where('snippets.category in ("text", "header", "subheader")').order(display_order: :asc, updated_at: :desc) }, class_name: 'Snippet'
  has_many :direct_text_snippets, -> { where('snippets.source_type = ? and snippets.category in ("text", "header", "subheader")', 'direct').order(display_order: :asc, updated_at: :desc) }, class_name: 'Snippet'
  has_many :web_text_snippets, -> { where('snippets.source_type = ? and snippets.category in ("text", "header", "subheader")', 'web').order(display_order: :asc, updated_at: :desc) }, class_name: 'Snippet'
  has_many :stared_users, -> { where('note_stars.stared = ?', true) }, through: :note_stars, source: :manager
  validates_presence_of :manager_id
  validates_presence_of :title
  validates_inclusion_of :peer_reviews_count, in: (0..NOTE_PEER_REVIEW_MAX_SIZE).to_a
  validates_inclusion_of :status, in: %w[private course master_draft master_review master_open]

  # ====================================================================
  # Public Functions
  # ====================================================================
  def self.course_note_manageable?(course_id, user_id)
    course_id = course_id.to_i
    return false if course_id.zero?
    course = Course.find course_id
    course.staff? user_id.to_i
  end

  def align_display_order
    snippets.each_with_index do |snippet, i|
      snippet.update_attributes(display_order: i + 1)
    end
  end

  def anonymous?(user_id)
    return false if manager_id == user_id
    return false if master_id.zero?
    master = Note.find(master_id)
    (master.status == 'master_review')
  end

  def deletable?(user_id)
    ((manager_id == user_id) && stickies.size.zero?)
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
    case status
    when 'private', 'master_draft', 'master_review'
      return false
    when 'course'
      if master_id && master_id > 0
        # controlled by master note
        master_note = Note.find(master_id)
        (master_note.status == 'master_open')
      else
        # staff's course note (no draft status)
        true
      end
    when 'master_open'
      true
    end
  end

  def review_or_open?
    case status
    when 'private', 'master_draft'
      return false
    when 'course'
      if master_id && master_id > 0
        # controlled by master note
        master_note = Note.find(master_id)
        (master_note.status == 'master_review') || (master_note.status == 'master_open')
      else
        # staff's course note (no draft status)
        true
      end
    when 'master_review', 'master_open'
      return true
    end
  end

  # FIXME: PeerReview
  def review?
    return false if master_id.zero?
    master = Note.find(master_id)
    master.status == 'master_review'
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
end
