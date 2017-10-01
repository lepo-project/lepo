# == Schema Information
#
# Table name: snippets
#
#  id            :integer          not null, primary key
#  manager_id    :integer
#  note_id       :integer
#  category      :string           default("text")
#  description   :text
#  source_type   :string           default("direct")
#  source_id     :integer
#  master_id     :integer
#  display_order :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Snippet < ApplicationRecord
  belongs_to :manager, class_name: 'User'
  belongs_to :note, touch: true
  belongs_to :source, class_name: 'WebSource'
  has_one :snippet_file
  validates_presence_of :manager_id
  validates_inclusion_of :category, in: %w[text header subheader], if: "source_type == 'direct'"
  validates_inclusion_of :category, in: %w[image pdf], if: "source_type == 'upload'"
  validates_inclusion_of :category, in: %w[text image pdf scratch ted youtube], if: "source_type == 'web'"
  validates_inclusion_of :source_type, in: %w[direct upload web]
  validates_format_of :description, with: /\.(gif|jpe?g|png)/i, message: 'must have an image extension', if: "source_type == 'web' && category == 'image'"
  after_destroy :cleanup

  # ====================================================================
  # Public Functions
  # ====================================================================

  def self.headers(snippets)
    headers = []
    snippets.each do |snippet|
      headers.push(snippet) if snippet.category == 'header'
    end
    headers
  end

  def self.with_source_by(manager_id)
    Snippet.where(manager_id: manager_id, source_type: 'web').to_a
  end

  def self.with_source_and_without_note_by(manager_id)
    Snippet.where(manager_id: manager_id, source_type: 'web').where(note_id: nil).order(created_at: :desc).to_a
  end

  def deletable?(user_id)
    (manager_id == user_id)
  end

  def importable?(user_id)
    # can not import one's own snippet
    return false if manager_id == user_id
    # can not import non web snippet
    return false if source_type != 'web'
    # can not import imported snippet
    return false if master_id
    # can not import already imported snippet
    return false if imported? user_id

    note = self.note
    # can not import from private or original_worksheet note
    return false if note.original_ws_id.zero?
    # can not import by course staff
    return false if !note.course || (note.course.staff? user_id)
    true
  end

  def imported?(user_id)
    !Snippet.where(manager_id: user_id, master_id: id).empty?
  end

  def imported_snippets
    return [] unless note_id
    Snippet.where(master_id: id).order(created_at: :asc).to_a
  end

  def original_note
    return unless master_id
    unless Snippet.find_by(id: master_id).nil?
      master_snippet = Snippet.find(master_id)
      return if !master_snippet.note_id || master_snippet.note_id.zero?
      return master_snippet.note if master_snippet.note
    end
    nil
  end

  def reference_num
    return '' unless note_id
    note = Note.find(note_id)
    if note
      note.reference_ids.each_with_index do |id, i|
        return "[#{i + 1}]" if id == source_id
      end
    end
    ''
  end

  def header_title(snippets)
    return '' unless category == 'header'
    header_ids = snippets.map { |s| s.id if s.category == 'header' }.compact
    chapter_num = header_ids.index id
    chapter_num.nil? ? description : (chapter_num + 1).to_s + '. ' + description
  end

  def subheader_title(snippets)
    return '' unless category == 'subheader'
    chapter_num = 0
    section_num = 0
    snippets.each do |s|
      case s.category
      when 'header'
        chapter_num += 1
        section_num = 0
      when 'subheader'
        section_num += 1
        return chapter_num.to_s + '.' + section_num.to_s + '. ' + description if (s.id == id) && !chapter_num.zero?
      end
    end
    description
  end

  # ====================================================================
  # Private Functions
  # ====================================================================

  private

  def cleanup
    return unless (source_type == 'upload') && (category == 'image')
    snippet_file.destroy if snippet_file
  end
end
