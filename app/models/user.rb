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

require 'net/ldap'
require 'digest/sha1'
require 'csv'
class User < ApplicationRecord
  include ImageUploader::Attachment.new(:image)
  include RandomString
  before_validation :set_default_value
  has_many :archived_courses, -> { where('courses.status = ? and courses.enabled = ?', 'archived', true) }, through: :course_members, source: :course
  has_many :attendances
  has_many :content_members
  has_many :contents, through: :content_members
  has_many :course_members
  has_many :courses, -> { where('courses.enabled = ?', true) }, through: :course_members
  # FIXME: PushNotification
  has_many :devices, foreign_key: :manager_id, dependent: :destroy
  has_many :lessons, foreign_key: :evaluator_id
  has_many :notes, -> { order(updated_at: :desc) }, foreign_key: :manager_id
  has_many :open_courses, -> { where('courses.status = ? and courses.enabled = ?', 'open', true) }, through: :course_members, source: :course
  has_many :outcomes, foreign_key: :manager_id
  has_many :outcome_messages, foreign_key: :manager_id
  has_many :signins
  has_many :snippets, foreign_key: :manager_id
  has_many :stickies, foreign_key: :manager_id
  has_many :sticky_stars, foreign_key: :manager_id
  has_many :user_actions
  validates_presence_of :family_name
  validates_presence_of :hashed_password, if: "authentication == 'local'"
  validates_presence_of :salt, if: "authentication == 'local'"
  validates_presence_of :signin_name
  validates_presence_of :token
  validates_uniqueness_of :signin_name
  validates_uniqueness_of :token
  validates_inclusion_of :authentication, in: %w[local ldap]
  validates_inclusion_of :role, in: %w[admin manager user suspended]
  validates_confirmation_of :password
  validate :password_non_blank, if: "authentication == 'local'"
  validates_length_of :password, in: USER_PASSWORD_MIN_LENGTH..USER_PASSWORD_MAX_LENGTH, allow_blank: true, if: "authentication == 'local'"
  attr_accessor :password_confirmation

  # ====================================================================
  # Public Functions
  # ====================================================================
  def self.authenticate(signin_name, password)
    user = find_by(signin_name: signin_name)

    # No signin_name in DB
    return nil unless user

    # authentication for user
    case user.authentication
    when 'local'
      expected_password = encrypted_password(password, user.salt)
      return user if user.hashed_password == expected_password
    when 'ldap'
      return user if user.ldap_authenticate(signin_name, password)
    end
    nil
  end

  def self.autocomplete(search_word)
    if USER_PHONETIC_NAME_FLAG
      users = where('signin_name LIKE ? OR family_name LIKE ? OR given_name LIKE ? OR phonetic_family_name LIKE ? OR phonetic_given_name LIKE ?', "%#{search_word}%", "%#{search_word}%", "%#{search_word}%", "%#{search_word}%", "%#{search_word}%").where.not(role: 'suspended').order(:signin_name)
    else
      users = where('signin_name LIKE ? OR family_name LIKE ? OR given_name LIKE? ', "%#{search_word}%", "%#{search_word}%", "%#{search_word}%").where.not(role: 'suspended').order(:signin_name)
    end
    users.select('id, signin_name, family_name, given_name')
  end

  def self.content_manageable?(id)
    user = find(id)
    user.content_manageable?
  end

  def self.encrypted_password(password, salt)
    string_to_hash = password + 'lepo' + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end

  def self.sync_roster(rusers)
    # Create and Update with OneRoster data

    ids = []
    rusers.each do |ru|
      user = User.find_or_initialize_by(signin_name: ru['username'])
      if user.update_attributes(authentication: 'ldap', family_name: ru['familyName'], given_name: ru['givenName'])
        ids.push user.id
      end
    end
    ids
  end

  def self.system_staff?(id)
    user = find(id)
    (user.role == 'admin') || (user.role == 'manager')
  end

  def self.system_admin?(id)
    user = find(id)
    user.role == 'admin'
  end

  def self.system_admin
    find_by(role: 'admin')
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
    where('(role = ?) || (role = ?)', 'admin', 'manager')
  end

  def self.sort_by_signin_name(users)
    users.to_a.sort! { |a, b| a.signin_name <=> b.signin_name }
  end

  def self.full_name_for_id(user_id)
    user = find(user_id)
    return user.full_name if user
    ''
  end

  def self.password_editable?(operating_user_role, object_user_role)
    ((operating_user_role == 'admin') && (object_user_role == 'manager' || object_user_role == 'user')) || ((operating_user_role == 'manager') && (object_user_role == 'user'))
  end

  def self.role_editable?(operating_user_role, object_user_role)
    ((operating_user_role == 'admin') && (object_user_role != 'admin')) || ((operating_user_role == 'manager') && (object_user_role == 'user' || object_user_role == 'suspended'))
  end

  def self.search(search_word, role = '', max_search_num = USER_SEARCH_MAX_SIZE)
    specific_role = %w[admin manager user suspended].include? role
    role_array = specific_role ? [role] : %w[admin manager user suspended]

    results = User.where('role in (?)', role_array)
    if USER_PHONETIC_NAME_FLAG
      results = results.where('signin_name like ? or family_name like ? or given_name like ? or phonetic_family_name like ? or phonetic_given_name like ?', "%#{search_word}%", "%#{search_word}%", "%#{search_word}%", "%#{search_word}%", "%#{search_word}%")
    else
      results = results.where('signin_name like ? or family_name like ? or given_name like ?', "%#{search_word}%", "%#{search_word}%", "%#{search_word}%")
    end
    results.uniq.order(signin_name: :asc).limit(max_search_num).to_a
  end

  def dashboard_cards
    cards = []
    if system_staff?
      cards
    else
      cards.concat open_course_cards
      cards.concat archived_course_cards
    end
  end

  def full_name
    # rather than using the family_name or given_name directly in the view files, use the full_name or short_name
    # for the case given_name is nil, to_s is added
    family_name + ' ' + given_name.to_s
  end

  def full_name_all
    return full_name unless USER_PHONETIC_NAME_FLAG
    phonetic_full_name == ' ' ? full_name : full_name + ' / ' + phonetic_full_name
  end

  def highlight_texts(lesson_note_id, page_id)
    ids = NoteIndex.where(note_id: lesson_note_id, item_type: 'Snippet').pluck(:item_id)
    Snippet.where(id: ids, manager_id: id, category: 'text', source_type: 'page', source_id: page_id).pluck(:id, :description)
  end

  def image_id(version)
    image[version.to_sym].id.split("/").last.split(".").first
  end

  def image_rails_url(version_num)
    file_id = image_id('px' + version_num)
    "#{Rails.application.config.relative_url_root}/users/#{id}/image?file_id=#{file_id}&version=px#{version_num}" if image && (%w[40 80 160].include? version_num)
  end

  def open_notes
    notes = Note.where(manager_id: id, category: 'work', course_id: open_course_ids).order(updated_at: :desc).to_a
    notes.delete_if(&:archived?)
    notes += Note.where(manager_id: id, category: 'lesson', course_id: open_course_ids).order(updated_at: :desc)
    notes += Note.where(manager_id: id, category: 'private', status: 'draft').order(updated_at: :desc)
    notes
  end

  def phonetic_full_name
    # rather than using the phonetic_family_name or phonetic_given_name directly in the view files, use the phonetic_full_name
    # for the case phonetic_*_name is nil, to_s is added
    return nil unless USER_PHONETIC_NAME_FLAG
    phonetic_family_name.to_s + ' ' + phonetic_given_name.to_s
  end

  def short_name
    # rather than using the family_name or given_name directly in the view files, use the full_name or short_name
    family_name
  end

  def content_manageable?
    # condition 1
    return true if %w[admin manager].include? role
    course_members.each do |cm|
      # condition 2: content manager and users must be course manager or assistant
      return true if cm.role == 'manager' || cm.role == 'assistant'
    end
    false
  end

  def work_sheet_manageable?
    return true if %w[admin manager].include? role
    distributable_courses = Course.work_sheet_distributable_by id
    return true unless distributable_courses.empty?
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

  def ldap_authenticate(signin_name, password)
    @ldap_config = YAML.safe_load(ERB.new(File.read("#{Rails.root}/config/ldap.yml")).result)[Rails.env]
    ldap = initialize_ldap_authentication
    result = ldap.bind_as(base: @ldap_config['base'], filter: "(#{@ldap_config['attributes']['id']}=#{signin_name})", password: password)
    return true if result
    false
  end

  def preferences
    preferences = [%w[preferences ajax_profile_pref], %w[bookmarks ajax_new], %w[preferences ajax_default_note_pref]]
    # FIXME: PushNotification
    # preferences = [%w[preferences ajax_profile_pref], %w[bookmarks ajax_new], %w[preferences ajax_default_note_pref], %w[devices ajax_index]]

    # ajax_account_pref for password update is displayed only when authentication is local
    authentication == 'local' ? preferences.push(%w[preferences ajax_account_pref]) : preferences
  end

  def system_preferences
    system_staff? ? [%w[preferences ajax_new_user_pref], %w[preferences ajax_user_account_pref], %w[courses ajax_new], %w[courses ajax_course_pref], %w[preferences ajax_notice_pref], %w[terms ajax_new], %w[preferences ajax_update_pref]] : []
  end

  # ====================================================================
  # Private Functions
  # ====================================================================
  private

  def archived_course_cards
    cards = []
    display_days = 14
    courses = archived_courses.to_a.delete_if { |c| c.updated_at < display_days.days.ago }
    courses.each do |course|
      cards.concat [{ title: course.title, list: [{ category: 'archived_course', controller: 'courses', action: 'ajax_index', nav_section: 'repository', nav_id: course.id }] }]
    end
    cards
  end

  def create_new_salt
    self.salt = object_id.to_s + rand.to_s
  end

  def open_course_cards
    cards = []
    open_courses.each do |course|
      list = []
      # snippet_ids is to check whether recently updated snippets exist in the specified course (updated_at is changeable by note.update_items).
      snippet_ids = NoteIndex.where(note_id: course.lesson_note(id).id, item_type: 'Snippet').where('created_at >= ?', 7.days.ago).pluck(:item_id)
      course.open_lessons.each do |lesson|
        # Outcome cards
        marked_outcome_num = lesson.marked_outcome_num id
        if marked_outcome_num > 0
          lesson_role = lesson.user_role(id)
          if %w[learner evaluator].include? lesson_role
            assignment_page_num = lesson.content.assignment_page.display_order
            list.push(category: lesson_role + '_outcome', display_order: lesson.display_order, outcome_num: marked_outcome_num, controller: 'courses', action: 'ajax_show_page_from_others', nav_section: 'open_courses', nav_id: course.id, lesson_id: lesson.id, page_num: assignment_page_num)
          end
        end

        # Lesson note cards
        content = lesson.content
        if (Sticky.where(manager_id: id, target_type: 'Page', course_id: course.id, content_id: content.id).where('updated_at >= ?', 7.days.ago).size + Snippet.where(id: snippet_ids, source_type: 'page', source_id: content.pages.pluck(:id)).size) > 0
          list.push(category: 'lesson_note_update', display_order: lesson.display_order, controller: 'courses', action: 'ajax_show_lesson_note_from_others', nav_section: 'open_courses', nav_id: course.id, lesson_id: lesson.id)
        end
      end
      cards.concat [{ title: ApplicationController.helpers.course_combined_title(course), list: list }] unless list.size.zero?
    end
    cards
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
  end
end
