module MediaRename

  class MovieTemplate

    attr_reader :template, :attributes

    def initialize(media)
      @template   = Liquid::Template.parse(SETTINGS['MOVIE_TEMPLATE'], error_mode: :strict)
      @media      = media
      @attributes = {
        title: media.parent.title,
        year: media.parent.year,
        video_format: MediaRename::Media.video_format(media.width, media.height),
        video_codec: MediaRename::Media.video_codec(media.video_codec),
        audio_codec: MediaRename::Media.audio_codec(media.audio_codec, media.audio_channels),
        tags: "",
        ext: media.hash['container']
      }
    end

    def render
      template.render(attributes.stringify_keys)
    end
  end

end