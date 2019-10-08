Paperclip.interpolates :content_folder_name do |attachment, style|
  attachment.instance.content.folder_name
end

Paperclip.interpolates :folder_name do |attachment, style|
  attachment.instance.folder_name
end

Paperclip.interpolates :outcome_folder_name do |attachment, style|
  attachment.instance.outcome.folder_name
end

Paperclip.interpolates :snippet_id do |attachment, style|
  attachment.instance.snippet.id
end
