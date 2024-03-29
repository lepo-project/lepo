# == Schema Information
#
# Table name: logs
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  controller     :string
#  action         :string
#  params         :json
#  nav_section    :string
#  nav_controller :string
#  nav_id         :integer
#  content_id     :integer
#  page_num       :integer
#  max_page_num   :integer
#  src_ip         :string
#  user_agent     :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class Log < ApplicationRecord
    belongs_to :user
    validates :user_id, presence: true
end
