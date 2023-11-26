require 'json'
require 'ostruct'
require 'active_support/inflector'

module MediaInfo
  def self.get_info(file_path)
    output = `mediainfo --Output=JSON "#{file_path}"`
    MediaInfo.create_media(JSON.parse(output))
  end

  def self.create_media(hash)
    hash.each_with_object({}) do |(key, value), obj|
      key = key.underscore.gsub(/\@/i, '')
      next if key == "creating_library"
      if value.is_a?(Array)
        value = value.map { |v| v.is_a?(Hash) ? MediaInfo.create_media(v) : v }
        obj[key] = value
      else
        obj[key] = value.is_a?(Hash) ? MediaInfo.create_media(value) : value
      end
    end
  end
end
