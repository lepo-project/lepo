class OutcomeUploader < Shrine
  plugin :delete_promoted
  plugin :validation_helpers

  Attacher.validate do
    validate_max_size OUTCOME_MAX_FILE_SIZE.megabytes
  end

  def generate_location(io, context)
    class_name = 'users'
    directory_name1 = context[:record].outcome.manager_id
    directory_name2 = context[:record].outcome.folder_name
    # Use original filename instead of GUID
    file_name  = context[:metadata]['filename']

    [class_name, directory_name1, directory_name2, file_name].compact.join("/")
  end
end
