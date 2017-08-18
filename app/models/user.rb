require 'net/ldap'
require 'digest/sha1'
require 'csv'
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

class User < ApplicationRecord
  include RandomString
  before_validation :set_default_value
  has_attached_file :image,
  path: ':rails_root/public/system/:class/:folder_id/:style/:filename',
  url: ':relative_url_root/system/:class/:folder_id/:style/:filename',
  default_url: '/assets/:class/:style/missing.png',
  styles: { px40: '40x40>', px80: '80x80>', original: '160x160>' }
  validates_attachment_content_type :image, content_type: ['image/gif', 'image/jpeg', 'image/pjpeg', 'image/png', 'image/x-png']
  validates_attachment_size :image, less_than: IMAGE_MAX_FILE_SIZE.megabytes # original file is resized, so this is not important
  has_many :attendances
  has_many :content_members
  has_many :contents, through: :content_members
  has_many :course_members
  has_many :courses, through: :course_members
  # FIXME: PushNotification
  has_many :devices, foreign_key: :manager_id, dependent: :destroy
  has_many :lessons, foreign_key: :evaluator_id
  has_many :outcomes, foreign_key: :manager_id
  has_many :outcome_messages, foreign_key: :manager_id
  has_many :signins
  has_many :snippets, foreign_key: :manager_id
  has_many :stickies, foreign_key: :manager_id
  has_many :sticky_stars, foreign_key: :manager_id
  has_many :notes, -> { order(updated_at: :desc) }, foreign_key: :manager_id
  validates_presence_of :familyname
  validates_presence_of :folder_id
  validates_presence_of :hashed_password, if: "authentication == 'local'"
  validates_presence_of :salt, if: "authentication == 'local'"
  validates_presence_of :token
  validates_presence_of :user_id
  validates_uniqueness_of :folder_id
  validates_uniqueness_of :token
  validates_uniqueness_of :user_id
  validates_inclusion_of :authentication, in: %w[local ldap]
  validates_inclusion_of :role, in: %w[admin manager user suspended]
  validates_confirmation_of :password
  validate :password_non_blank, if: "authentication == 'local'"
  validates_length_of :password, in: USER_PASSWORD_MIN_LENGTH..USER_PASSWORD_MAX_LENGTH, allow_blank: true, if: "authentication == 'local'"
  attr_accessor :password_confirmation

  # ====================================================================
  # Public Functions
  # ====================================================================
  def self.authenticate(user_id, password)
    user = find_by_user_id(user_id)

    # No user_id in DB
    return nil unless user

    # authentication for user
    case user.authentication
    when 'local'
      expected_password = encrypted_password(password, user.salt)
      return user if (user.hashed_password == expected_password) && !user.archived_at
    when 'ldap'
      return user if user.ldap_authenticate(user_id, password)
    end
    nil
  end

  def self.autocomplete(search_word)
    case AUTOCOMPLETE_CATEGORY
    when 'fullname'
      users = where('user_id LIKE ? OR familyname LIKE ? OR givenname LIKE? ', "%#{search_word}%", "%#{search_word}%", "%#{search_word}%").where.not(role: 'suspended').order(:user_id)
    when 'fullname_alt'
      users = where('user_id LIKE ? OR familyname LIKE ? OR givenname LIKE ?  OR familyname_alt LIKE ? OR givenname_alt LIKE ?', "%#{search_word}%", "%#{search_word}%", "%#{search_word}%", "%#{search_word}%", "%#{search_word}%").where.not(role: 'suspended').order(:user_id)
    else
      users = where('user_id LIKE ?', "%#{search_word}%").where.not(role: 'suspended').order(:user_id)
    end
    users.select("id, user_id || ' / ' || familyname || givenname AS id_fullname")
  end

  def self.content_manageable?(id)
    user = find(id)
    user.content_manageable?
  end

  def self.encrypted_password(password, salt)
    string_to_hash = password + 'lepo' + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end

  def self.system_staff?(id)
    user = find(id)
    # FIXME: role
    (user.role == 'admin') || (user.role == 'manager')
  end

  def self.system_admin?(id)
    user = find(id)
    # FIXME: role
    user.role == 'admin'
  end

  def self.system_admin
    find_by_role 'admin'
  end

  def self.system_managers
    where(role: 'manager')
  end

  def self.system_users(limit_size)
    where(role: 'user').order(created_at: :desc).limit(limit_size)
  end

  def self.system_users_size
    where(role: 'user').size
  end

  def self.system_staffs
    # FIXME: role
    where('(role = ?) || (role = ?)', 'admin', 'manager')
  end

  def self.sort_by_user_id(users)
    users.to_a.sort! { |a, b| a.user_id <=> b.user_id }
  end

  def self.fullname_for_id(user_id)
    user = find(user_id)
    return user.fullname if user
    ''
  end

  def self.search(keyword, role = '', max_search_num = 50)
    specific_role = %w[admin manager user suspended].include? role
    role_array = specific_role ? [role] : %w[admin manager user suspended]
    results = User.where('user_id like ? and role in (?)', "%#{keyword}%", role_array).order(user_id: :asc).limit(max_search_num).to_a
    rest_search_num = max_search_num - results.size
    results += User.where('familyname like ? and role in (?)', "%#{keyword}%", role_array).limit(rest_search_num).to_a if rest_search_num > 0
    rest_search_num = max_search_num - results.size
    results += User.where('givenname like ? and role in (?)', "%#{keyword}%", role_array).limit(rest_search_num).to_a if rest_search_num > 0

    rest_search_num = max_search_num - results.size
    results += User.where('familyname_alt like ? and role in (?)', "%#{keyword}%", role_array).limit(rest_search_num).to_a if rest_search_num > 0
    rest_search_num = max_search_num - results.size
    results += User.where('givenname_alt like ? and role in (?)', "%#{keyword}%", role_array).limit(rest_search_num).to_a if rest_search_num > 0

    results.sort! { |a, b| a.user_id <=> b.user_id }
    results.uniq
  end

  def fullname
    fullname = ''
    fullname += familyname if familyname
    fullname += ' ' + givenname if givenname
    fullname = '---' if fullname == ''
    fullname
  end

  def fullname_alt
    fullname_alt = ''
    fullname_alt += familyname_alt if familyname_alt
    fullname_alt += ' ' + givenname_alt if givenname_alt
    fullname_alt = '---' if fullname_alt == ''
    fullname_alt
  end

  def content_manageable?
    # condition 1
    return true if %w[admin manager].include? role
    course_members.each do |cm|
      # condition 2: content manager and instructors must be course manager or assistant
      return true if cm.role == 'manager' || cm.role == 'assistant'
    end
    # content_members.each do |cm|
    #   # condition 3: content manager and instructors must be assistant of other content
    #   return true if cm.role == 'assistant'
    # end
    false
  end

  def system_admin?
    role == 'admin'
  end

  def system_staff?
    (role == 'admin') || (role == 'manager')
  end

  attr_reader :password

  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = User.encrypted_password(password, salt)
  end

  def ldap_authenticate(user_id, password)
    @ldap_config = YAML.safe_load(ERB.new(File.read("#{Rails.root}/config/ldap.yml")).result)[Rails.env]
    ldap = initialize_ldap_authentication
    result = ldap.bind_as(base: @ldap_config['base'], filter: "(#{@ldap_config['attributes']['id']}=#{user_id})", password: password)
    return true if result
    false
  end

  def preferences
    preferences = [%w[preferences ajax_profile_pref], %w[links ajax_new], %w[preferences ajax_default_note_pref]]
    # # FIXME: PushNotification
    # preferences = [%w[preferences ajax_profile_pref], %w[links ajax_new], %w[preferences ajax_default_note_pref], %w[devices ajax_index]]

    # ajax_account_pref for password update is displayed only when authentication is local
    authentication == 'local' ? preferences.push(%w[preferences ajax_account_pref]) : preferences
  end

  def system_preferences
    system_staff? ? [%w[preferences ajax_new_user_pref], %w[preferences ajax_user_account_pref], %w[courses ajax_new], %w[preferences ajax_notice_pref], %w[terms ajax_new]] : []
  end

  # ====================================================================
  # Private Functions
  # ====================================================================
  private

  def create_new_salt
    self.salt = object_id.to_s + rand.to_s
  end

  def password_non_blank
    errors.add(:password, 'パスワードを入力して下さい') if hashed_password.blank?
  end

  def initialize_ldap_authentication
    options = {
      host: @ldap_config['host'],
      port: @ldap_config['port'],
      encryption: (@ldap_config['tls'] ? :simple_tls : nil),
      auth: { method: :simple, username: @ldap_config['admin_user'], password: @ldap_config['admin_password'] }
    }
    Net::LDAP.new options
  end

  def set_default_value
    self.token = random_string(USER_TOKEN_LENGTH) unless token
    self.folder_id = ym_random_string(FOLDER_NAME_LENGTH) unless folder_id
  end
end
