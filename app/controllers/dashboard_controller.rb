class DashboardController < ApplicationController
  # ====================================================================
  # Public Functions
  # ====================================================================
  def ajax_index
    set_nav_session 'home', 'dashboard'
    render 'layouts/renders/all', locals: { resource: 'index' }
  end
end
