module ContentsHelper
  # ====================================================================
  # Public Functions
  # ====================================================================

  def content_crumbs(content_title, nav_section, _page_num)
    c1 = ['', { action: 'ajax_index', nav_section: nav_section }]
    # c2 = [get_short_string(content_title, 10), {action: 'ajax_show_page', page_num: 0}]
    c2 = [get_short_string(content_title, 10)]
    [c1, c2]
  end

  def content_icon_info(resource_status)
    case resource_status
    when 'open'
      { class: 'no-icon', text: '公開中' }
    when 'draft'
      { class: 'fa fa-lock fa-lg', text: '準備中' }
    when 'archived'
      { class: 'fa fa-archive fa-lg', text: 'アーカイブ' }
    end
  end
end
