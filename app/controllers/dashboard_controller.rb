class DashboardController < ApplicationController
  # ====================================================================
  # Public Functions
  # ====================================================================
  def ajax_index
    set_nav_session 'home', 'dashboard'
    get_dashboard_resources current_user
    render 'layouts/renders/all', locals: { resource: 'index' }
  end
end
