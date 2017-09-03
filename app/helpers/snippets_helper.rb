module SnippetsHelper
  # ====================================================================
  # Public Functions
  # ====================================================================

  def lepo_bookmarklet_script
    # This code is inspired by the gem "rails-bookmarklet", https://github.com/oliverfriedmann/rails-bookmarklet.git

    full_url = system_url + '/snippets/create_web_snippet'
    params = { 'u' => "'+encodeURIComponent(d.location.href)+'", 't' => "'+encodeURIComponent(d.title)+'", 'd' => "'+encodeURIComponent((window.getSelection)?window.getSelection().toString():d.selection.createRange().text)+'", 'c' => 't', 'tk' => current_user.token, 'v' => '3.2' }

    params.each do |key, value|
      unless (full_url.ends_with? '?') || (full_url.ends_with? '&')
        full_url += full_url.include?('?') ? '&' : '?'
      end
      full_url += key + '=' + value
    end

    "javascript:(function(){var d=document,z=d.createElement('scr'+'ipt'),b=d.body;try{" \
    "if(!b)throw(0);if((d.location.href.indexOf('://www.bing.com/search') > -1) || (d.location.href.indexOf('://www.bing.com/images/') > -1) || (d.location.href.indexOf('://www.bing.com/videos/') > -1))throw(0);z.setAttribute('src','" + full_url + "');b.appendChild(z);}" \
    "catch(e){alert('エラー：このページは、+Note できません');}}).call(this);"
  end
end
