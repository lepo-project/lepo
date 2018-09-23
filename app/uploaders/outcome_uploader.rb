class OutcomeUploader < Shrine
  plugin :delete_promoted
  plugin :validation_helpers

  Attacher.validate do
    validate_max_size OUTCOME_MAX_FILE_SIZE.megabytes
  end

  def generate_location(io, context)
    class_name = 'users'
    folder_name1 = context[:record].outcome.manager_id
    folder_name2 = context[:record].outcome.folder_name
    # Use original filename instead of UUID
    file_name  = context[:metadata]['filename']

    [class_name, folder_name1, folder_name2, file_name].compact.join("/")
  end
end
