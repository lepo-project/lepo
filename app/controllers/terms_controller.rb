class TermsController < ApplicationController
  include RosterApi
  # ====================================================================
  # Public Functions
  # ====================================================================
  def ajax_create
    @term = Term.new(term_params)
    begin
      # this action is not permitted when SYSTEM_ROSTER_SYNC is :suspended
      raise unless %i[on off].include? SYSTEM_ROSTER_SYNC
      Term.transaction do
        @term.save!
        if SYSTEM_ROSTER_SYNC == :on
          response = request_roster_api('/academicSessions/', :post, {academicSession: @term.to_roster_hash})
          @term.update_attributes!(sourced_id: response['academicSession']['sourcedId'])
        end
      end
      flash.now[:message] = t('controllers.terms.created')
      flash.now[:message_category] = 'info'
      @term = Term.new
    rescue => error
      flash.now[:message] = t('controllers.terms.creation_failed')
      flash.now[:message_category] = 'error'
    end
    render_term
  end

  def ajax_update
    term = Term.find params[:id]
    begin
      # this action is not permitted when SYSTEM_ROSTER_SYNC is :suspended
      raise unless %i[on off].include? SYSTEM_ROSTER_SYNC
      Term.transaction do
        term.update_attributes!(term_params)
        if SYSTEM_ROSTER_SYNC == :on
          raise if term.sourced_id.blank?
          request_roster_api("/academicSessions/#{term.sourced_id}", :put, {academicSession: term.to_roster_hash})
        end
      end
      flash.now[:message] = t('controllers.terms.updated')
      flash.now[:message_category] = 'info'
    rescue => error
      flash.now[:message] = t('controllers.terms.update_failed')
      flash.now[:message_category] = 'error'
    end
    render_term
  end

  def ajax_new
    render_term
  end

  def ajax_destroy
    term = Term.find params[:id]
    begin
      # this action is not permitted when SYSTEM_ROSTER_SYNC is :suspended
      raise unless %i[on off].include? SYSTEM_ROSTER_SYNC
      Term.transaction do
        raise unless term.deletable? session[:id]
        term.destroy!
        if SYSTEM_ROSTER_SYNC == :on
          raise if term.sourced_id.blank?
          request_roster_api("/academicSessions/#{term.sourced_id}", :delete)
        end
      end
      flash.now[:message] = t('controllers.terms.deleted')
      flash.now[:message_category] = 'info'
    rescue => error
      flash.now[:message] = t('controllers.terms.delete_failed')
      flash.now[:message_category] = 'error'
    end
    render_term
  end

  # ====================================================================
  # Private Functions
  # ====================================================================

  private

  def term_params
    params.require(:term).permit(:title, :start_at, :end_at)
  end

  def render_term
    @term = Term.new unless @term
    @terms = Term.all.order(start_at: :desc)
    render 'layouts/renders/main_pane', locals: { resource: 'new' }
  end
end
