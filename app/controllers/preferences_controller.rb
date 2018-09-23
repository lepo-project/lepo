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
    when '0.2.3'
      flash[:message_category] = 'error' unless update_0_2_3
    when '0.2.4'
      flash[:message_category] = 'error' unless update_0_2_4
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

  def update_0_2_4
    # fix for course.image data
    Course.record_timestamps = false
    Course.find_each do |course|
      Paperclip::AttachmentRegistry.each_definition do |klass, name, options|
        course.write_shrine_data(name) if klass == Course && course.image_data.nil?
      end
      course.save!
    end
    Course.record_timestamps = true

    # fix for user.image data
    User.record_timestamps = false
    User.find_each do |user|
      Paperclip::AttachmentRegistry.each_definition do |klass, name, options|
        user.write_shrine_data(name) if klass == User && user.image_data.nil?
      end
      user.save!
    end
    User.record_timestamps = true

    # fix for snippet.image data
    Snippet.record_timestamps = false
    Snippet.find_each do |snippet|
      if (snippet.category == 'image') && (snippet.source_type == 'upload') && snippet.image_data.nil?
        snippet_file = snippet.snippet_file
        data =
        {
          px1280: {
            id: 'users/' + snippet.manager_id.to_s + '/upload_snippets/' + snippet.id.to_s + '/' + snippet_file.upload_file_name,
            storage: :store,
            metadata: {
              filename: snippet_file.upload_file_name,
              size: snippet_file.upload_file_size,
              mime_type: snippet_file.upload_content_type,
            }
          }
        }
        snippet.write_attribute(:image_data, data.to_json)
        snippet.save!
      end
    end
    Snippet.record_timestamps = true

    # fix for outfome_file.upload data
    OutcomeFile.record_timestamps = false
    OutcomeFile.find_each do |file|
      if file.upload_data.nil?
        outcome = file.outcome
        data =
        {
          id: 'users/' + outcome.manager_id.to_s + '/assignment_outcomes/' + outcome.folder_name + '/' + file.upload_file_name,
          storage: :store,
          metadata: {
            filename: file.upload_file_name,
            size: file.upload_file_size,
            mime_type: file.upload_content_type,
          }
        }
        file.write_attribute(:upload_data, data.to_json)
        file.save!
      end
    end
    OutcomeFile.record_timestamps = true
  end

  def update_0_2_3
    # Update pages table
    Content.all.each do |content|
      if content.cover_page.nil?
        page = Page.create(content_id: content.id, display_order: 0, category: 'cover')
        unless page.save
          flash[:message] = 'Error: Failed to create cover page for content.id = ' + content.id.to_s
          return false
        end
      end

      next unless content.assignment_page.nil?
      display_order = content.file_pages.size + 1
      page = Page.create(content_id: content.id, display_order: display_order, category: 'assignment')
      unless page.save
        flash[:message] = 'Error: Failed to create assignment page for content.id = ' + content.id.to_s
        return false
      end
    end

    # Update stickys table
    Sticky.all.each do |sticky|
      next unless sticky.target_type == 'PageFile'
      unless sticky.update_columns(target_type: 'Page')
        flash[:message] = 'Error: sticky target_id update, ' + sticky.id.to_s
        return false
      end

      next if sticky.target_id > 0
      category = sticky.target_id.zero? ? 'cover' : 'assignment'
      target_id = Page.find_by(content_id: sticky.content_id, category: category).id
      unless sticky.update_columns(target_id: target_id)
        flash[:message] = 'Error: sticky target_id update, ' + sticky.id.to_s
        return false
      end
    end

    # Update snippets table
    Snippet.all.each do |snippet|
      next unless snippet.source_type == 'page_file'
      unless snippet.update_columns(source_type: 'page')
        flash[:message] = 'Error: snippet source_type update, ' + snippet.id.to_s
        return false
      end
    end
    true
  end
end
