class OutcomeFilesController < ApplicationController
  # ====================================================================
  # Public Functions
  # ====================================================================
  def ajax_create
    new_file = OutcomeFile.new(outcome_file_params)

    if new_file.valid?
      @outcome = Outcome.find new_file.outcome_id
      @outcome.set_folder_name
      @outcome.save

      same_name_file = new_file.same_name_file
      if same_name_file
        same_name_file.destroy
        flash.now[:message] = '提出ファイル「' + new_file.file_name + '」を更新しました'
        flash[:message_category] = 'info'
      end
      new_file.save
    else
      flash.now[:message] = '「' + new_file.file_name + '」のアップロードに失敗しました'
      flash[:message_category] = 'error'
    end

    # Thic action is only executed by learner
    @lesson_role = 'learner'
    render 'layouts/renders/file_outcome'
  end

  def ajax_destroy
    outcome_file = OutcomeFile.find params[:id]
    @outcome = Outcome.find outcome_file.outcome_id
    outcome_file.destroy

    # Thic action is only executed by learner
    @lesson_role = 'learner'
    render 'layouts/renders/file_outcome'
  end

  def show_upload
    file = OutcomeFile.find params[:id]
    return nil unless params[:folder_id] == file.outcome.folder_name
    url = file.upload_url
    filepath = Rails.root.join('storage', url[1, url.length-1])
    send_file filepath, disposition: "inline"
  end

  # ====================================================================
  # Private Functions
  # ====================================================================

  private

  def outcome_file_params
    params.require(:outcome_file).permit(:outcome_id, :upload)
  end
end
