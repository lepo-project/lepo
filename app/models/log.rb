# == Schema Information
#
# Table name: logs
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  controller :string
#  action     :string
#  params     :json
#  src_ip     :string
#  user_agent :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Log < ApplicationRecord
    belongs_to :user
    validates :user_id, presence: true
end
