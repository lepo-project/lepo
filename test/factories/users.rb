# == Schema Information
#
# Table name: users
#
#  id                   :integer          not null, primary key
#  signin_name          :string
#  authentication       :string           default("local")
#  hashed_password      :string
#  salt                 :string
#  token                :string
#  role                 :string           default("user")
#  family_name          :string
#  given_name           :string
#  phonetic_family_name :string
#  phonetic_given_name  :string
#  web_url              :string
#  description          :text
#  default_note_id      :integer          default(0)
#  last_signin_at       :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  image_data           :text
#

FactoryBot.define do
  factory :user, class: User do
    sequence(:signin_name) { |i| "user#{i}-test" }
    password 'temporary'
    password_confirmation 'temporary'
    role 'user'
    family_name 'Test'
    phonetic_family_name 'Test' if USER_PHONETIC_NAME_FLAG
    sequence(:given_name) { |i| "User#{i}" }
    sequence(:phonetic_given_name) { |i| "User#{i}" } if USER_PHONETIC_NAME_FLAG

    factory :admin_user do
      role 'admin'
    end

    factory :manager_user do
      role 'manager'
    end

    factory :suspended_user do
      role 'suspended'
    end

    factory :ldap_user do
      authentication 'ldap'
      hashed_password nil
      salt nil
    end
  end
end
