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
  validates_presence_of :manager_id
  validates_presence_of :title
  validates_uniqueness_of :registration_id
end
