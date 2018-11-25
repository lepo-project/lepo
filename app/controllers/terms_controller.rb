class TermsController < ApplicationController
  include RosterApi
  # ====================================================================
  # Public Functions
  # ====================================================================
  def create
    @term = Term.new(term_params)
    begin
      raise unless @term.creatable? session[:id]
      Term.transaction do
        @term.save!
        if SYSTEM_ROSTER_SYNC == :on
          payload = {academicSession: @term.to_roster_hash}
          response = request_roster_api('/academicSessions/', :post, payload)
          @term.update_attributes!(sourced_id: response['academicSession']['sourcedId'])
        end
      end
      flash.now[:message] = t('controllers.terms.created')
      flash.now[:message_category] = 'info'
      @term = Term.new
    rescue => error
      notify_error error, t('controllers.terms.creation_failed')
    end
    render_term
  end

  def update
    term = Term.find params[:id]
    begin
      raise unless term.updatable? session[:id]
      Term.transaction do
        term.update_attributes!(term_params)
        payload = {academicSession: term.to_roster_hash}
        request_roster_api("/academicSessions/#{term.sourced_id}", :put, payload) if SYSTEM_ROSTER_SYNC == :on
      end
      flash.now[:message] = t('controllers.terms.updated')
      flash.now[:message_category] = 'info'
    rescue => error
      notify_error error, t('controllers.terms.update_failed')
    end
    render_term
  end

  def new
    render_term
  end

  def destroy
    term = Term.find params[:id]
    begin
      raise unless term.destroyable? session[:id]
      Term.transaction do
        term.destroy!
        request_roster_api("/academicSessions/#{term.sourced_id}", :delete) if SYSTEM_ROSTER_SYNC == :on
      end
      flash.now[:message] = t('controllers.terms.deleted')
      flash.now[:message_category] = 'info'
    rescue => error
      notify_error error, t('controllers.terms.delete_failed')
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
