require 'csv'
class ContentMembersController < ApplicationController
  include ::UsersController::AllActions
  # ====================================================================
  # Public Functions
  # ====================================================================
  def ajax_edit
    get_resources
    @form_category = ''
    @member_role = 'assistant'
    render 'layouts/renders/main_pane', locals: { resource: 'edit' }
  end

  def ajax_csv_candidates
    @form_category = 'csv'
    @member_role = ''
    @search_word = ''
    @candidates_csv = params[:candidates_csv] ? params[:candidates_csv] : ''

    @content = Content.find params[:content_id]
    manageable = @content.manager_changeable? session[:id]
    @candidates = csv_to_member_candidates @candidates_csv, manageable, 'content', @content.id
    render 'layouts/renders/resource', locals: { resource: 'edit' }
  end

  def ajax_search_candidates
    @content = Content.find params[:content_id]
    @form_category = 'search'
    @member_role = params[:member_role] ? params[:member_role] : ''
    @search_word = params[:search_word] ? params[:search_word] : ''
    @candidates_csv = ''

    candidates = User.search @search_word
    get_resources
    candidates = delete_existing candidates, [@content.manager]
    case @member_role
    when 'assistant'
      candidates = delete_existing candidates, @content.assistants
    when 'user'
      candidates = delete_existing candidates, @content.users
    end
    current_roles = []
    candidates.each do |cn|
      current_relation = ContentMember.find_by(user_id: cn.id, content_id: @content.id)
      current_role = current_relation ? current_relation.role : ''
      current_roles.push current_role
    end
    @candidates = candidates.zip current_roles, Array.new(candidates.size, @member_role)
    render 'layouts/renders/resource', locals: { resource: 'edit' }
  end

  def ajax_update_role
    if params[:update_to] == 'none'
      content_member = ContentMember.find_by(user_id: params[:user_id], content_id: params[:content_id])
      if content_member && content_member.deletable?
        content_member.destroy
        if session[:id] == params[:user_id].to_i
          flash.now[:message] = 'この教材のメンバー編集権限がなくなりました'
          flash[:message_category] = 'error'
        end
      end
    else
      manager_id = ContentMember.find_by(content_id: params[:content_id], role: 'manager').user_id
      ContentMember.transaction do
        update_role manager_id, params[:content_id], 'assistant' if params[:update_to] == 'manager'
        update_role params[:user_id], params[:content_id], params[:update_to]
      end
      flash.now[:message] = 'この教材のメンバー編集権限がなくなりました' if (session[:id] == params[:user_id].to_i) && (params[:update_to] == 'user')
      flash[:message_category] = 'error'
    end

    # replace page process
    case params[:form_category]
    when 'search'
      ajax_search_candidates
    when 'csv'
      ajax_csv_candidates
    else
      ajax_edit
    end
  end

  # ====================================================================
  # Private Functions
  # ====================================================================

  private

  def get_resources
    @content = Content.find params[:content_id]
    @content.fill_objectives
    @manager = @content.manager
    @assistants = User.sort_by_signin_name @content.assistants
    @users = User.sort_by_signin_name @content.users
  end

  def update_role(user_id, content_id, role)
    content_member = ContentMember.find_by(user_id: user_id, content_id: content_id)
    if content_member
      unless content_member.update_attributes!(role: role)
        flash.now[:message] = '教材の管理/利用許可者は、コース管理権限のあるユーザのみ登録できます'
        flash[:message_category] = 'error'
      end
    else
      new_content_member = ContentMember.new(user_id: user_id, content_id: content_id, role: role)
      unless new_content_member.save!
        flash.now[:message] = '教材の管理/利用許可者は、コース管理権限のあるユーザのみ登録できます'
        flash[:message_category] = 'error'
      end
    end
  end
end
