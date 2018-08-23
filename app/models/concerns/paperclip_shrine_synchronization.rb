module PaperclipShrineSynchronization
  def write_shrine_data(name)
    attachment = send(name)

    if attachment.size.present?
      data = attachment_to_shrine_data(self.class.name.pluralize.downcase, self.id.to_s, attachment)

      if attachment.styles.any?
        data = {original: data}
        attachment.styles.each do |name, style|
          data[name] = style_to_shrine_data(style)
        end
      end

      write_attribute(:"#{name}_data", data.to_json)
    else
      write_attribute(:"#{name}_data", nil)
    end
  end

  private

  def attachment_to_shrine_data(class_name, instance_id, attachment)
    {
      px160: {
        id: class_name + '/' + instance_id + '/original/' + attachment.original_filename,
        storage: :store,
        metadata: {
          filename: attachment.original_filename,
          size: attachment.size,
          mime_type: attachment.content_type,
        }
      },
      px80: {
        id: class_name + '/' + instance_id + '/px80/' + attachment.original_filename,
        storage: :store,
        metadata: {
          filename: attachment.original_filename,
          size: attachment.size,
          mime_type: attachment.content_type,
        }
      },
      px40: {
        id: class_name + '/' + instance_id + '/px40/' + attachment.original_filename,
        storage: :store,
        metadata: {
          filename: attachment.original_filename,
          size: attachment.size,
          mime_type: attachment.content_type,
        }
      }
    }
  end
end
