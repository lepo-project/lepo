# == Schema Information
#
# Table name: devices
#
#  id              :integer          not null, primary key
#  manager_id      :integer
#  title           :string
#  registration_id :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Device < ActiveRecord::Base
  # FIXME: PushNotification
  belongs_to :manager, class_name: 'User'
  validates :manager_id, presence: true
  validates :registration_id, uniqueness: true
  validates :title, presence: true
end
