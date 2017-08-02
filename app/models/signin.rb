# == Schema Information
#
# Table name: signins
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  src_ip     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Signin < ApplicationRecord
  belongs_to :user
  validates_presence_of :user_id
end
