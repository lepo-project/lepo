# == Schema Information
#
# Table name: user_actions
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  src_ip             :string
#  category           :string
#  course_id          :integer
#  lesson_id          :integer
#  content_id         :integer
#  page_id            :integer
#  sticky_id          :integer
#  sticky_star_id     :integer
#  snippet_id         :integer
#  outcome_id         :integer
#  outcome_message_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class UserAction < ApplicationRecord
  belongs_to :user
  validates_presence_of :user_id
  validates_inclusion_of :category, in: %w[created read updated deleted signined signouted]
end
