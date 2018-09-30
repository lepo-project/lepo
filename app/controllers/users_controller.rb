class UsersController < ApplicationController
  def show_image
    @user = User.find(params[:id])
    if %w[px40 px80 px160].include? params[:version]
      image_id = @user.image_id(params[:version])
      return nil unless params[:file_id] == image_id
      url = @user.image_url(params[:version].to_sym).to_s
      filepath = Rails.root.join('storage', url[1, url.length-1])
      send_file filepath, disposition: "inline"
    end
  end

  module AllActions
    # ====================================================================
    # Public Functions
    # ====================================================================
    def ajax_account_pref
      render_main_pane 'account_pref'
    end

    def ajax_default_note_pref
      render_main_pane 'note_pref'
    end

    def ajax_new_user_pref
      existing_users_info
      render 'layouts/renders/main_pane', locals: { resource: 'users/new_user_pref' }
    end

    def ajax_profile_pref
      render_main_pane 'profile_pref'
    end

    def ajax_user_account_pref
      # for security reason
      if User.system_staff? session[:id]
        render_main_pane 'user_account_pref'
      else
        render_main_pane 'account_pref'
      end
    end

    def ajax_csv_candidates
      existing_users_info
      @candidates_csv = params[:candidates_csv] ? params[:candidates_csv] : ''
      @candidates = csv_to_user_candidates params[:candidates_csv], current_user.system_admin?
      render 'layouts/renders/resource', locals: { resource: 'users/new_user_pref' }
    end

    def ajax_create_user
      @candidates_csv = params[:candidates_csv] ? params[:candidates_csv] : ''
      role = (params[:role] == 'admin') || (params[:role] == 'manager' && !current_user.system_admin?) ? 'user' : params[:role]
      user_hash = { role: role, authentication: params[:authentication], signin_name: params[:signin_name], family_name: params[:family_name], given_name: params[:given_name] }
      user_hash[:password] = params[:password] if params[:authentication] == 'local'
      user_hash[:phonetic_family_name] = params[:phonetic_family_name] if USER_PHONETIC_NAME_FLAG
      user_hash[:phonetic_given_name] = params[:phonetic_given_name] if USER_PHONETIC_NAME_FLAG
      unless User.create(user_hash)
        flash.now[:message] = 'ユーザの新規作成に失敗しました'
        flash[:message_category] = 'error'
      end
      ajax_csv_candidates
    end

    def ajax_search_accounts
      @search_word = params[:search_word] ? params[:search_word] : ''
      @role = params[:role] ? params[:role] : ''
      @candidates = User.search @search_word, @role
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
        @selected_user = User.find params[:id]
        @candidates = User.search @search_word, @role
      else
        @selected_user = nil
        @candidates = nil
      end
      render_main_pane 'user_account_pref'
    end

    def ajax_update_role
      existing_users_info
      if params[:update_to] == 'suspended'
        user = User.find params[:user_id]
        if user && user.role != 'admin'
          user.update_attribute(:role, 'suspended')
        end
      end
      ajax_csv_candidates
    end

    def ajax_update_user_account
      if current_user.system_staff?
        selected_user = User.find params[:id]
        original_role = selected_user.role
        if params[:user][:password].nil? || selected_user.authentication == 'ldap'
          update_result = selected_user.update_attributes(role: params[:user][:role]) if User.role_editable? current_user.role, original_role
        elsif User.password_editable? current_user.role, original_role
          update_result = selected_user.update_attributes(user_params)
        end

        if update_result
          flash[:message] = selected_user.full_name + 'のアカウントを更新しました。'
          flash[:message_category] = 'info'
        else
          flash[:message] = '入力した情報に誤りがあります。'
          flash[:message_category] = 'error'
        end
      end
      @search_word = params[:search_word] ? params[:search_word] : ''
      @selected_user = original_role == params[:user][:role] ? @selected_user : nil
      @role = original_role
      @candidates = User.search @search_word, @role
      render_main_pane 'user_account_pref'
    end

    def ajax_update_account
      update_user '/users/account_pref'
    end

    def ajax_update_profile
      update_user '/users/profile_pref'
    end

    def ajax_update_default_note
      update_user '/users/note_pref'
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
        signin_name = row[2].strip
        password = row[3].nil? ? '' : row[3].strip
        family_name = row[4].strip
        given_name = row[5].nil? ? '' : row[5].strip
        if USER_PHONETIC_NAME_FLAG
          phonetic_family_name = row[6].nil? ? '' : row[6].strip
          phonetic_given_name = row[7].nil? ? '' : row[7].strip
        end

        if role == 'manager' && !manager_creatable
          flash[:message] = 'システム管理者は、システム最高管理者のみ登録出来ます'
          flash[:message_category] = 'error'
          return candidates
        end

        user = User.find_by(signin_name: signin_name)
        if user
          candidates.push [user, user.role, '']
        else
          user_hash = { signin_name: signin_name, authentication: authentication, password: password, role: role, family_name: family_name, given_name: given_name }
          user_hash[:phonetic_family_name] = phonetic_family_name if USER_PHONETIC_NAME_FLAG
          user_hash[:phonetic_given_name] = phonetic_given_name if USER_PHONETIC_NAME_FLAG
          candidates.push [User.new(user_hash), '', role]
        end
      end
      candidates
    end

    def appropriate_user_format?(row)
      # format: role,authentication,signin_name,password,family_name,given_name,phonetic_family_name,phonetic_given_name
      return false if (row.size != 8) && USER_PHONETIC_NAME_FLAG
      # format: role,authentication,signin_name,password,family_name,given_name
      return false if (row.size != 6) && !USER_PHONETIC_NAME_FLAG
      return false if row[0].nil? || row[1].nil? || row[2].nil? || row[4].nil?
      return false if %w[manager user].exclude? row[0]
      return false if %w[local ldap].exclude? row[1]
      true
    end

    def existing_users_info
      @admin = User.system_admin
      @managers = User.system_managers
      @users = User.system_users(10)
      @users_size = User.system_users_size
    end

    def user_params
      params.require(:user).permit(:signin_name, :password, :password_confirmation, :role, :family_name, :phonetic_family_name, :given_name, :phonetic_given_name, :image, :remove_image, :web_url, :description, :default_note_id)
    end

    def render_main_pane(render_resource)
      render 'layouts/renders/main_pane', locals: { resource: 'users/' + render_resource }
    end

    def update_user(render_resource)
      # Remedy for both new file upload and delete_image are selected
      params.require(:user).delete(:remove_image) if user_params[:image] && user_params[:image].size.nonzero?

      if current_user.update_attributes(user_params)
        @stickies = Sticky.size_by_user session[:id]
        render 'layouts/renders/main_pane', locals: { resource: 'index' }
      else
        flash[:message] = '入力した情報に誤りがあります。'
        flash[:message_category] = 'error'
        render 'layouts/renders/resource', locals: { resource: render_resource }
      end
    end
  end
end
