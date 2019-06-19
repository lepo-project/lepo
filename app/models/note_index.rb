# == Schema Information
#
# Table name: note_indices
#
#  id            :integer          not null, primary key
#  note_id       :integer
#  item_id       :integer
#  item_type     :string           default("Snippet")
#  display_order :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class NoteIndex < ApplicationRecord
  belongs_to :note, touch: true
  belongs_to :item, polymorphic: true
  validates :display_order, presence: true
  validates :item_id, presence: true
  validates :item_id, uniqueness: { scope: %i[item_type note_id] }
  validates :item_type, inclusion: { in: %w[Content Snippet Sticky] }
  validates :note_id, presence: true

  # ====================================================================
  # Public Functions
  # ====================================================================
  def self.headers(items)
    return [] unless items
    header_items = items.select { |i| (i.item_type == 'Content') || (i.item_type == 'Snippet' && i.item.category == 'header') }
    headers = []
    header_items.each do |note_item|
      if note_item.item_type == 'Content'
        headers.push(id: note_item.id, title: note_item.item.title)
      else
        headers.push(id: note_item.id, title: note_item.item.description)
      end
    end
    headers
  end

  def header_title(items)
    header_ids = items.select { |i| (i.item_type == 'Content') || (i.item_type == 'Snippet' && i.item.category == 'header') }.pluck :id
    return '' unless header_ids.include? id
    chapter_num = header_ids.index(id) + 1
    title = item_type == 'Content' ? item.title : item.description
    chapter_num.to_s + '. ' + title
  end

  def subheader_title(items)
    return '' unless item_type == 'Snippet' && item.category == 'subheader'
    chapter_num = 0
    section_num = 0
    items.each do |i|
      if (i.item_type == 'Content') || (i.item_type == 'Snippet' && i.item.category == 'header')
        chapter_num += 1
        section_num = 0
      elsif i.item_type == 'Snippet' && i.item.category == 'subheader'
        section_num += 1
        return chapter_num.to_s + '.' + section_num.to_s + '. ' + i.item.description if (i.id == id) && !chapter_num.zero?
      end
    end
    item.description
  end
end
