module PreferencesHelper
  # ====================================================================
  # Public Functions
  # ====================================================================

  def preference_title(controller_name, action_name)
    case controller_name
    when 'courses'
      t('views.preferences.new_course') + ' : ' + t('views.preferences.new_course_summary')
    when 'devices'
      # FIXME: PushNotification
      t('views.preferences.device') + ' : ' + t('views.preferences.device_summary')
    when 'links'
      t('views.preferences.link') + ' : ' + t('views.preferences.link_summary')
    when 'preferences'
      case action_name
      when 'ajax_account_pref'
        t('views.preferences.account') + ' : ' + t('views.preferences.account_summary')
      when 'ajax_new_user_pref'
        t('views.preferences.new_user') + ' : ' + t('views.preferences.new_user_summary')
      when 'ajax_notice_pref'
        t('views.preferences.system_notice') + ' : ' + t('views.preferences.system_notice_summary')
      when 'ajax_profile_pref'
        t('views.preferences.profile') + ' : ' + t('views.preferences.profile_summary')
      when 'ajax_default_note_pref'
        t('views.preferences.note') + ' : ' + t('views.preferences.note_summary')
      when 'ajax_user_account_pref'
        t('views.preferences.user_account') + ' : ' + t('views.preferences.user_account_summary')
      end
    when 'terms'
      t('views.preferences.term') + ' : ' + t('views.preferences.term_summary')
    end
  end

  def preference_title_id(controller_name, action_name)
    case controller_name
    when 'courses'
      'new-course-pref'
    when 'devices'
      # FIXME: PushNotification
      'device-pref'
    when 'links'
      'link-pref'
    when 'preferences'
      case action_name
      when 'ajax_account_pref'
        'account-pref'
      when 'ajax_new_user_pref'
        'new-user-pref'
      when 'ajax_notice_pref'
        'system-notice-pref'
      when 'ajax_profile_pref'
        'profile-pref'
      when 'ajax_default_note_pref'
        'note-pref'
      when 'ajax_user_account_pref'
        'user-account-pref'
      end
    when 'terms'
      'term-pref'
    end
  end
end
