# == Schema Information
#
# Table name: message_templates
#
#  id           :integer          not null, primary key
#  manager_id   :integer
#  content_id   :integer
#  objective_id :integer
#  counter      :integer          default(0)
#  message      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class MessageTemplate < ApplicationRecord
  belongs_to :content
  belongs_to :manager, class_name: 'User'
  belongs_to :objective
  validates_presence_of :content_id
  validates_presence_of :manager_id
  validates_presence_of :message
  validates_presence_of :objective_id
end
