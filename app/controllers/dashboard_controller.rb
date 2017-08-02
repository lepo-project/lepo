class DashboardController < ApplicationController
  # ====================================================================
  # Public Functions
  # ====================================================================
  def ajax_index
    set_nav_session 'home', 'dashboard'
    @user = User.find session[:id]
    get_dashboard_resources @user
    render 'layouts/renders/all', locals: { resource: 'index' }
  end
end
