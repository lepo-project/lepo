module MessageTemplatesHelper
  # ====================================================================
  # Public Functions
  # ====================================================================

  def dropdown_position(text, left_max_size)
    text.size <= left_max_size ? '' : 'pull-right'
  end

  def template_btn_class(content_id, objective_id)
    return 'btn btn-sm btn-success' if content_id.zero?
    return 'btn btn-sm btn-warning' if objective_id > 0
    'btn btn-sm btn-light'
  end
end
