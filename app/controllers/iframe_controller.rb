class IframeController < ApplicationController
  layout 'application_iframe'
  # ====================================================================
  # Public Functions
  # ====================================================================
  def image_page
    @file_page = Page.find params[:id]
  end

  def video_page
    @file_page = Page.find params[:id]
  end

  def object_page
    @file_page = Page.find params[:id]
  end
end
