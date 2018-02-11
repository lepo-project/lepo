class PreferencesController < ApplicationController
  include ::NoticesController::AllActions
  include ::UsersController::AllActions

  # ====================================================================
  # Public Functions
  # ====================================================================
  def ajax_index
    set_nav_session params[:nav_section], 'preferences'
    render 'layouts/renders/all', locals: { resource: 'index' }
  end

  def ajax_update_pref
    render 'layouts/renders/main_pane', locals: { resource: 'update_pref' }
  end
end
