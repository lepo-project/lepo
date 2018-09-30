require "image_processing/mini_magick"

class ImageUploader < Shrine
  plugin :delete_promoted
  plugin :delete_raw
  plugin :determine_mime_type
  plugin :processing
  plugin :remove_attachment
  plugin :validation_helpers
  plugin :versions

  Attacher.validate do
    validate_max_size IMAGE_MAX_FILE_SIZE.megabytes
    validate_extension_inclusion %w[gif jpg jpeg png]
    validate_mime_type_inclusion %w[image/gif image/jpeg image/pjpeg image/png image/x-png]
  end

  process(:store) do |io, context|
    original = io.download
    pipeline = ImageProcessing::MiniMagick.source(original)

    case context[:record].class.name.downcase
    when 'user', 'course'
      px160_img = pipeline.resize_to_limit!(160, 160)
      px80_img = pipeline.resize_to_limit!(80, 80)
      px40_img = pipeline.resize_to_limit!(40, 40)
      original.close!
      { px160: px160_img, px80: px80_img, px40: px40_img }
    when 'snippet'
      px1280_img = pipeline.resize_to_limit!(1280, 1280)
      original.close!
      { px1280: px1280_img }
    end
  end

  def generate_location(io, context)
    class_name = context[:record].class.name.pluralize.downcase if context[:record]
    case class_name
    when 'courses', 'users'
      directory_name = context[:record].id
      file_name  = super # the default unique identifier
    when 'snippets'
      class_name = 'users'
      directory_name = context[:record].manager_id
      file_name  = super # the default unique identifier
    end

    [class_name, directory_name, file_name].compact.join("/")
  end
end
