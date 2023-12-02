require 'json'
require 'ostruct'
require 'active_support/inflector'


module MediaInfo

  VIDEO_TAGS = %w|
    type
    id
    format
    duration
    bit_rate
    width
    height
    frame_rate_num
    title
    hdr_format
    transfer_characteristics
  |
  AUDIO_TAGS = %w|
    type
    id
    format
    codec_id
    duration
    bit_rate
    channels
    format_commercial_if_any
    language
    title
  |

  def self.get_info(file_path)
    output = `mediainfo --ParseSpeed=0 --Output=JSON "#{file_path}"`
    MediaInfo.create_media(JSON.parse(output))
  end

  def self.create_media(hash)
    obj = hash.each_with_object({}) do |(key, value), obj|
      key = key.underscore.gsub(/\@/i, '')
      next if key == "creating_library"
      if value.is_a?(Array)
        value = value.map { |v| v.is_a?(Hash) ? MediaInfo.create_media(v) : v }
        obj[key] = value
      else
        obj[key] = value.is_a?(Hash) ? MediaInfo.create_media(value) : value
      end
    end
    # only keep video tags
    obj = obj.select { |k, v| VIDEO_TAGS.include?(k) } if obj["type"] == "Video"
    # only keep audio tags
    obj = obj.select { |k, v| AUDIO_TAGS.include?(k) } if obj["type"] == "Audio"
    obj
  end
end
