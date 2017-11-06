class IframeController < ApplicationController
  layout 'application_iframe'
  # ====================================================================
  # Public Functions
  # ====================================================================
  def image_page
    @page_file = PageFile.find(params[:id].to_i)
  end

  def video_page
    @page_file = PageFile.find(params[:id].to_i)
  end

  def object_page
    @page_file = PageFile.find(params[:id].to_i)
  end
end
