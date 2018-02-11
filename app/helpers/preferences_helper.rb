module PreferencesHelper
  # ====================================================================
  # Public Functions
  # ====================================================================

  def preference_title(controller_name, action_name)
    case controller_name
    when 'courses'
      case action_name
      when 'ajax_new'
        t('helpers.new_course') + ' : ' + t('helpers.new_course_summary')
      when 'ajax_course_pref'
        t('helpers.edit_course') + ' : ' + t('helpers.edit_course_summary')
      end
    when 'devices'
      # FIXME: PushNotification
      t('helpers.device') + ' : ' + t('helpers.device_summary')
    when 'bookmarks'
      t('helpers.bookmark') + ' : ' + t('helpers.bookmark_summary')
    when 'preferences'
      case action_name
      when 'ajax_account_pref'
        t('helpers.account') + ' : ' + t('helpers.account_summary')
      when 'ajax_new_user_pref'
        t('helpers.new_user') + ' : ' + t('helpers.new_user_summary')
      when 'ajax_notice_pref'
        t('helpers.system_notice') + ' : ' + t('helpers.system_notice_summary')
      when 'ajax_profile_pref'
        t('helpers.profile') + ' : ' + t('helpers.profile_summary')
      when 'ajax_default_note_pref'
        t('helpers.note') + ' : ' + t('helpers.note_summary')
      when 'ajax_user_account_pref'
        t('helpers.user_account') + ' : ' + t('helpers.user_account_summary')
      when 'ajax_update_pref'
        t('helpers.update') + ' : ' + t('helpers.update_summary')
      end
    when 'terms'
      t('helpers.term') + ' : ' + t('helpers.term_summary')
    end
  end

  def preference_title_id(controller_name, action_name)
    case controller_name
    when 'courses'
      case action_name
      when 'ajax_new'
        'new-course-pref'
      when 'ajax_course_pref'
        'edit-course-pref'
      end
    when 'devices'
      # FIXME: PushNotification
      'device-pref'
    when 'bookmarks'
      'bookmark-pref'
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
