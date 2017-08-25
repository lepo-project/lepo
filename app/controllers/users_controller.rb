class UsersController < ApplicationController
  module AllActions
    # ====================================================================
    # Public Functions
    # ====================================================================
    def ajax_destroy_user_image
      user = User.find(session[:id])
      user.image.clear
      if user.save
        flash[:message] = '画像を削除しました。'
        flash[:message_category] = 'info'
      end
      ajax_profile_pref
    end

    def ajax_account_pref
      render_main_pane 'account_pref'
    end

    def ajax_default_note_pref
      render_main_pane 'note_pref'
    end

    def ajax_new_user_pref
      current_user_info
      render 'layouts/renders/main_pane', locals: { resource: 'users/new_user_pref' }
    end

    def ajax_profile_pref
      render_main_pane 'profile_pref'
    end

    def ajax_user_account_pref
      # for security reason
      if User.system_staff? session[:id]
        @role = 'user'
        render_main_pane 'user_account_pref'
      else
        render_main_pane 'account_pref'
      end
    end

    def ajax_csv_candidates
      current_user_info
      @candidates_csv = params[:candidates_csv] ? params[:candidates_csv] : ''
      @candidates = csv_to_user_candidates params[:candidates_csv], @user.system_admin?
      render 'layouts/renders/resource', locals: { resource: 'users/new_user_pref' }
    end

    def ajax_create_user
      @user = User.find session[:id]
      @candidates_csv = params[:candidates_csv] ? params[:candidates_csv] : ''
      role = (params[:role] == 'admin') || (params[:role] == 'manager' && !@user.system_admin?) ? 'user' : params[:role]
      case params[:authentication]
      when 'local'
        user = User.new(role: role, authentication: 'local', user_id: params[:user_id], password: params[:password], familyname: params[:familyname], givenname: params[:givenname], familyname_alt: params[:familyname_alt], givenname_alt: params[:givenname_alt])
      when 'ldap'
        user = User.new(role: role, authentication: 'ldap', user_id: params[:user_id], familyname: params[:familyname], givenname: params[:givenname], familyname_alt: params[:familyname_alt], givenname_alt: params[:givenname_alt])
      end
      unless user.save
        flash.now[:message] = 'ユーザの新規作成に失敗しました'
        flash[:message_category] = 'error'
      end
      ajax_csv_candidates
    end

    def ajax_search_accounts
      @search_word = params[:search_word] ? params[:search_word] : ''
      @role = params[:role] ? params[:role] : ''
      @candidates = User.search @search_word, @role, USER_SEARCH_MAX_SIZE
      if @candidates.size.zero? || (!User.system_staff? session[:id])
        @candidates = nil
        flash[:message] = '条件を満たすユーザが見つかりません'
        flash[:message_category] = 'error'
      end
      render_main_pane 'user_account_pref'
    end

    def ajax_select_account
      # for security reason
      @search_word = params[:search_word] ? params[:search_word] : ''
      @role = params[:role] ? params[:role] : ''
      if User.system_staff? session[:id]
        @selected_user = User.find(params[:id])
        @candidates = User.search @search_word, @role, USER_SEARCH_MAX_SIZE
      else
        @selected_user = nil
        @candidates = nil
      end
      render_main_pane 'user_account_pref'
    end

    def ajax_update_role
      current_user_info
      if params[:update_to] == 'suspended'
        user = User.find(params[:user_id])
        if user && user.role != 'admin'
          user.update_attribute(:role, 'suspended')
        end
      end
      ajax_csv_candidates
    end

    def ajax_update_user_account
      if User.system_staff? session[:id]
        selected_user = User.find(params[:id])
        original_role = selected_user.role
        if params[:user][:password].nil? || selected_user.authentication == 'ldap'
          update_result = selected_user.update_attributes(role: params[:user][:role])
        else
          update_result = selected_user.update_attributes(user_params)
        end

        if update_result
          flash[:message] = selected_user.fullname + 'さんのアカウントを更新しました。'
          flash[:message_category] = 'info'
        else
          flash[:message] = '入力した情報に誤りがあります。'
          flash[:message_category] = 'error'
        end
      end
      @search_word = params[:search_word] ? params[:search_word] : ''
      @selected_user = original_role == params[:user][:role] ? @selected_user : nil
      @role = original_role
      @candidates = User.search @search_word, @role, USER_SEARCH_MAX_SIZE
      render_main_pane 'user_account_pref'
    end

    def ajax_update_account
      update_user 'account_pref'
    end

    def ajax_update_profile
      update_user 'profile_pref'
    end

    def ajax_update_default_note
      update_user 'note_pref'
    end

    # ====================================================================
    # Private Functions
    # ====================================================================

    private

    def csv_to_user_candidates(users_in_csv, manager_creatable)
      candidates = []
      CSV.parse(users_in_csv) do |row|
        unless appropriate_user_format? row
          flash[:message] = 'CSVデータに、不適切なフォーマットの行があります'
          flash[:message_category] = 'error'
          return candidates
        end

        role = row[0].strip == 'manager' ? 'manager' : 'user'
        authentication = row[1].strip
        user_id = row[2].strip
        password = row[3].nil? ? '' : row[3].strip
        familyname = row[4].strip
        givenname = row[5].nil? ? '' : row[5].strip
        familyname_alt = row[6].nil? ? '' : row[6].strip
        givenname_alt = row[7].nil? ? '' : row[7].strip

        if role == 'manager' && !manager_creatable
          flash[:message] = 'システム管理者は、システム最高管理者のみ登録出来ます'
          flash[:message_category] = 'error'
          return candidates
        end

        user = User.find_by_user_id(user_id)
        if user
          candidates.push [user, user.role, '']
        else
          candidates.push [User.new(user_id: user_id, authentication: authentication, password: password, role: role, familyname: familyname, givenname: givenname, familyname_alt: familyname_alt, givenname_alt: givenname_alt), '', role]
        end
      end
      candidates
    end

    def appropriate_user_format?(row)
      # role,authentication,user_id,password,familyname,givenname,familyname_alt,givenname_alt
      return false if row.size != 8
      return false if row[0].nil? || row[1].nil? || row[2].nil? || row[4].nil?
      true
    end

    def current_user_info
      @admin = User.system_admin
      @managers = User.system_managers
      @users = User.system_users(10)
      @users_size = User.system_users_size
      @user = User.find session[:id]
    end

    def user_params
      params.require(:user).permit(:user_id, :password, :password_confirmation, :role, :familyname, :familyname_alt, :givenname, :givenname_alt, :image, :web_url, :description, :default_note_id)
    end

    def render_main_pane(render_resource)
      @user = User.find session[:id]
      render 'layouts/renders/main_pane', locals: { resource: 'users/' + render_resource }
    end

    def update_user(render_resource)
      @user = User.find session[:id]
      if @user.update_attributes(user_params)
        @stickies = Sticky.size_by_user @user.id
        render 'layouts/renders/main_pane', locals: { resource: 'index' }
      else
        flash[:message] = '入力した情報に誤りがあります。'
        flash[:message_category] = 'error'
        render 'layouts/renders/resource', locals: { resource: render_resource }
      end
    end
  end
end
