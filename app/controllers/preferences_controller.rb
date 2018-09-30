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

  def ajax_update
    flash[:message] = t('controllers.preferences.update_success', version: params[:version])
    flash[:message_category] = 'info'
    case params[:version]
    when '0.2.4'
      # flash[:message_category] = 'error' unless update_0_2_4
    else
      flash[:message] = t('controllers.preferences.update_failed', version: params[:version])
      flash[:message_category] = 'error'
    end
    render 'layouts/renders/main_pane', locals: { resource: 'update_pref' }
  end

  # ====================================================================
  # Private Functions
  # ====================================================================

  private

  # def update_0_2_4
  # end
end
