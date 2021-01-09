module MediaRename

  class MovieTemplate

    attr_reader :template, :attributes

    def initialize(record:, media:)
      @template   = Liquid::Template.parse(SETTINGS['MOVIE_TEMPLATE'], error_mode: :strict)
      @media      = media
      @attributes = {
        title: record.title.to_s.gsub(':', '-'),
        year: record.year,
        video_format: MediaRename::Media.video_format(media.width, media.height),
        video_codec: MediaRename::Media.video_codec(media.video_codec),
        audio_codec: MediaRename::Media.audio_codec(media.audio_codec, media.audio_channels),
        tags: "",
        ext: media.container
      }
    end

    def render
      params = attributes.inject({}){|memo,(k,v)| memo[k.to_s] = v; memo}
      template.render(params)
    end
  end

end