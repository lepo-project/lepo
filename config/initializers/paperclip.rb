Paperclip.interpolates :content_folder_id do |attachment, style|
  attachment.instance.content.folder_id
end

Paperclip.interpolates :folder_id do |attachment, style|
  attachment.instance.folder_id
end

Paperclip.interpolates :outcome_folder_id do |attachment, style|
  attachment.instance.outcome.folder_id
end

Paperclip.interpolates :outcome_manager_folder_id do |attachment, style|
  attachment.instance.outcome.manager.folder_id
end

Paperclip.interpolates :snippet_manager_folder_id do |attachment, style|
  attachment.instance.snippet.manager.folder_id
end

Paperclip.interpolates :snippet_id do |attachment, style|
  attachment.instance.snippet.id
end

Paperclip.interpolates :relative_url_root  do |attachment, style|
  Rails.application.config.relative_url_root.to_s
end
