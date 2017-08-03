# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  user_id            :string
#  authentication     :string           default("local")
#  hashed_password    :string
#  salt               :string
#  token              :string
#  role               :string           default("user")
#  familyname         :string
#  familyname_alt     :string
#  givenname          :string
#  givenname_alt      :string
#  folder_id          :string
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :integer
#  image_updated_at   :datetime
#  web_url            :string
#  description        :text
#  default_note_id    :integer          default(0)
#  last_signin_at     :datetime
#  archived_at        :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

FactoryGirl.define do
  factory :user, class: User do
    # test user with local authentication
    sequence(:user_id) { |i| "user#{i}-test" }
    password 'temporary'
    role 'user'
    familyname 'Test'
    familyname_alt 'Test'
    sequence(:givenname) { |i| "User#{i}" }
    sequence(:givenname_alt) { |i| "User#{i}" }
    # test user with ldap authentication
    factory :ldap_user do
      authentication 'ldap'
      hashed_password nil
      salt nil
    end
  end
end
