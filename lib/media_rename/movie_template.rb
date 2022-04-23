module MediaRename

  class MovieTemplate

    attr_reader :template, :attributes

    def initialize(record:, media:, part:)
      @template   = Liquid::Template.parse(SETTINGS['MOVIE_TEMPLATE'], error_mode: :strict)
      @media      = media
      video_codec = []
      video_codec << MediaRename::Media.video_format(media.width, media.height)
      if MediaRename::Media.video_codec(media.video_codec) == "HEVC"
        video_codec << MediaRename::Media.video_codec(media.video_codec) 
      end
      video_codec << MediaRename::Media.tags(media)
      video_codec.compact!.flatten!
      @attributes = {
        title: record.title.to_s.gsub(':', '-'),
        year: record.year,
        parts_count: @media.parts.count,
        part: part,
        video_format: MediaRename::Media.video_format(media.width, media.height),
        video_codec: video_codec,
        audio_codec: MediaRename::Media.audio_codec(media.audio_codec, media.audio_channels),
        ext: media.container
      }
      puts @attributes.inspect
      @attributes
    end

    def render
      params = attributes.inject({}){|memo,(k,v)| memo[k.to_s] = v; memo}
      template.render(params)
    end
  end

end