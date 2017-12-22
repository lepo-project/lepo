class TermsController < ApplicationController
  # ====================================================================
  # Public Functions
  # ====================================================================
  def ajax_create
    @term = Term.new(term_params)
    if @term.save
      flash.now[:message] = '学期を追加しました'
      flash.now[:message_category] = 'info'
      @term = Term.new
    else
      flash.now[:message] = '学期の追加に失敗しました'
      flash.now[:message_category] = 'error'
    end

    render_term
  end

  def ajax_update
    term = Term.find params[:term][:id]

    if term.update_attributes(term_params)
      flash.now[:message] = '学期情報を更新しました'
      flash.now[:message_category] = 'info'
    else
      flash.now[:message] = '学期情報の更新に失敗しました'
      flash.now[:message_category] = 'error'
    end

    render_term
  end

  def ajax_new
    render_term
  end

  def ajax_destroy
    term = Term.find params[:id]
    if term.deletable? session[:id]
      term.destroy
    else
      flash.now[:message] = '学期の削除に失敗しました。学期は登録コースがゼロの時のみ、削除可能です。'
      flash.now[:message_category] = 'error'
    end
    render_term
  end

  # ====================================================================
  # Private Functions
  # ====================================================================

  private

  def term_params
    params.require(:term).permit(:id, :title, :start_at, :end_at)
  end

  def render_term
    @term = Term.new unless @term
    @terms = Term.all.order(start_at: :desc)
    render 'layouts/renders/main_pane', locals: { resource: 'new' }
  end
end
