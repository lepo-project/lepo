# == Schema Information
#
# Table name: content_members
#
#  id         :integer          not null, primary key
#  content_id :integer
#  user_id    :integer
#  role       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :content_assistant, class: ContentMember do
    association :content
    association :user
    role 'assistant'

    factory :content_manager do
      association :user, factory: :admin_user
      role 'manager'

      factory :content_manager_for_user do
        association :user, role: 'user'
      end
    end

    factory :content_user do
      association :user, factory: :admin_user
      role 'user'

      factory :content_user_for_user do
        association :user, role: 'user'
      end
    end
  end
end
