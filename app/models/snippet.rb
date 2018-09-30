# == Schema Information
#
# Table name: snippets
#
#  id          :integer          not null, primary key
#  manager_id  :integer
#  category    :string           default("text")
#  description :text
#  source_type :string           default("direct")
#  source_id   :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  image_data  :text
#

class Snippet < ApplicationRecord
  include ImageUploader::Attachment.new(:image)
  belongs_to :manager, class_name: 'User'
  belongs_to :source, class_name: 'WebPage'
  # FIXME: Correct this to be appropriate 'belongs_to' according to the value of source_type
  # belongs_to :source, class_name: 'Page'
  has_many :notes, through: :note_indices
  has_many :note_indices, as: :item, dependent: :destroy
  validates_presence_of :description, if: '%w[direct page].include? source_type'
  validates_presence_of :manager_id
  validates_presence_of :source_id, if: '%w[page web].include? source_type'
  validates_inclusion_of :category, in: %w[text header subheader], if: "source_type == 'direct'"
  validates_inclusion_of :category, in: %w[text], if: "source_type == 'page'"
  validates_inclusion_of :category, in: %w[image], if: "source_type == 'upload'"
  validates_inclusion_of :category, in: %w[text image pdf scratch ted youtube], if: "source_type == 'web'"
  validates_inclusion_of :source_type, in: %w[direct page upload web]
  validates_format_of :description, with: /\.(gif|jpe?g|png)/i, message: 'must have an image extension', if: "source_type == 'web' && category == 'image'"
  after_destroy :destroy_source
  before_save :limit_description_length

  # ====================================================================
  # Public Functions
  # ====================================================================
  def self.web_snippets_without_note_by(manager_id)
    snippets = where(manager_id: manager_id, source_type: 'web').order(created_at: :desc).to_a
    snippets.delete_if { |s| s.note_indices.count > 0 }
  end

  def deletable?(user_id)
    (manager_id == user_id)
  end

  def display_order_for(note_id = nil)
    return nil unless note_id
    note_index = NoteIndex.find_by(item_id: id, item_type: 'Snippet', note_id: note_id)
    note_index ? note_index.display_order : nil
  end

  def image_id
    image[:px1280].id.split("/").last.split(".").first
  end

  def image_rails_url
    "#{Rails.application.config.relative_url_root}/snippets/#{id}/image?file_id=#{image_id}" if image
  end

  def reference_num(note_id)
    note = Note.find(note_id)
    if note
      note.reference_ids.each_with_index do |id, i|
        return "[#{i + 1}]" if id == source_id
      end
    end
    ''
  end

  def transferable?(user_id, to_note_id = nil)
    manager = manager_id == user_id
    # snippets in work sheet with the operation by course learner
    return false unless manager
    # snippets in work sheet with the operation by work sheet manager
    return false if note_indices.size > 1
    case note_indices.size
    when 1
      # snippet manager: from note to nil
      return true unless to_note_id
      # snippet manager: from note to note
      to_note_category = Note.find_by(id: to_note_id).category
      return (note_indices[0].note_id != to_note_id) && (to_note_category != 'lesson')
    when 0
      # snippet manager: from nil to nil
      return false unless to_note_id
      # snippet manager: from nil to note
      to_note = Note.find_by(id: to_note_id)
      (to_note.manager_id == user_id) && (to_note.category != 'lesson')
    end
  end

  # ====================================================================
  # Private Functions
  # ====================================================================
  private

  def destroy_source
    case source_type
    when 'web'
      source.destroy if source.deletable?
    end
  end

  def limit_description_length
    # max character length for snippet is SNIPPET_MAX_LENGTH
    # description is image url for source_type == web and category == image
    self.description = description[0, SNIPPET_MAX_LENGTH] unless category == "image"
  end
end
