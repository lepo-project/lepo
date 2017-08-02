class PreferencesController < ApplicationController
  include ::NoticesController::AllActions
  include ::UsersController::AllActions

  # ====================================================================
  # Public Functions
  # ====================================================================
  def ajax_index
    set_nav_session params[:nav_section], 'preferences'
    @user = User.find session[:id]
    render 'layouts/renders/all', locals: { resource: 'index' }
  end
end
