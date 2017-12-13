class SigninController < ApplicationController
  # ====================================================================
  # Public Functions
  # ====================================================================

  def index
    set_nav_session 'signin', 'signin'
    @course_id = 0
  end

  def ajax_authenticate
    return unless request.post?

    user = User.authenticate(params[:signin_name], params[:password])
    if user
      if (user.system_staff? && !inside_ip?(SYSTEM_STAFF_SIGNIN_IP)) || user.role == 'suspended'
        # system administrator can only signin from SYSTEM_STAFF_SIGNIN_IP
        # suspended user can not signin
        flash[:message] = t('controllers.signin.error1')
        render 'layouts/renders/resource', locals: { resource: 'index' }
      else
        # update last_signin_at without updating updated_at
        user.update_column(:last_signin_at, Time.now.utc)
        Signin.create(user_id: user.id, src_ip: src_ip)
        session[:id] = user.id
        set_nav_session 'home', 'dashboard', 0
        render 'layouts/renders/all_for_signin'
      end
    else
      flash[:message] = t('controllers.signin.error2')
      render 'layouts/renders/resource', locals: { resource: 'index' }
    end
  end

  def ajax_create_admin_account
    if User.all.size.zero?
      user_hash = { signin_name: params[:signin_name], password: params[:password], password_confirmation: params[:password_confirmation], role: 'admin', family_name: 'LePo', given_name: 'Master' }
      user_hash[:phonetic_family_name] = 'LePo' if USER_PHONETIC_NAME_FLAG
      user_hash[:phonetic_given_name] = 'Master' if USER_PHONETIC_NAME_FLAG
      user = User.new(user_hash)
      if user.save
        url = I18n.default_locale == :ja ? 'https://lepo.info/' : 'https://lepo.info/en'
        Bookmark.transaction do
          web_page = WebPage.create! title: 'LePo', url: url
          Bookmark.create! manager_id: user.id, display_title: 'LePo Project', display_order: 1, target_type: 'web', target_id: web_page.id
        end
      else
        flash[:message] = t('controllers.signin.setup_error1')
        flash[:message_category] = 'error'
      end
    else
      flash[:message] = t('controllers.signin.setup_error2')
      flash[:message_category] = 'error'
    end
    render 'layouts/renders/resource', locals: { resource: 'setup' }
  end

  def signout
    session.each do |key, _value|
      session[key] = nil
    end
    redirect_to(controller: 'signin', action: 'index', protocol: app_protocol)
  end

  # ====================================================================
  # Private Functions
  # ====================================================================

  private

  def authorize
  end

  def src_ip
    request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip
  end

  def inside_ip?(ips)
    remote_ip = src_ip
    inside = false

    # Convert remote IP to an integer.
    bremote_ip = remote_ip.split('.').map(&:to_i).pack('C*').unpack('N').first
    ips.each do |ipstring|
      ip, mask = ipstring.split '/'
      # Convert tested IP to an integer.
      bip = ip.split('.').map(&:to_i).pack('C*').unpack('N').first
      # Convert mask to an integer, and assume /32 if not specified.
      mask = mask ? mask.to_i : 32
      bmask = ((1 << mask) - 1) << (32 - mask)
      if bip & bmask == bremote_ip & bmask
        inside = true
        break
      end
    end
    inside
  end
end
