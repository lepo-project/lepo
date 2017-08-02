class DevicesController < ApplicationController
  # FIXME: PushNotification
  # ====================================================================
  # Public Functions
  # ====================================================================
  def ajax_index
    @user = User.find session[:id]
    render_device 'index'
  end

  def ajax_new
    @user = User.find session[:id]
    @device = @user.devices.build
    render_device 'new'
  end

  def ajax_create
    @device = Device.new
    @user = User.find session[:id]
    @device.manager_id = @user.id
    @device.title = params[:device][:title]
    @device.registration_id = params[:device][:registration_id]
    if @device.save
      render_device 'index'
    else
      flash[:message] = '入力した情報に誤りがあります。'
      flash[:message_category] = 'error'
      render_device 'new'
    end
  end

  def ajax_edit
    @device = Device.find params[:id]
    render_device 'edit'
  end

  def ajax_update
    @device = Device.find params[:id]
    @user = User.find session[:id]
    @device.manager_id = @user.id
    @device.title = params[:device][:title]
    @device.registration_id = params[:device][:registration_id]
    @device.save
    render_device 'index'
  end

  def ajax_destroy
    @device = Device.find params[:id]
    @device.destroy if @device
    @user = User.find session[:id]
    render_device 'index'
  end

  def ajax_push
    registration_id = params[:id]
    send_push_notification(registration_id) if registration_id
  end

  # ====================================================================
  # Private Functions
  # ====================================================================

  private

  def render_device(render_resource)
    render 'layouts/renders/main_pane', locals: { resource: render_resource }
  end
end
