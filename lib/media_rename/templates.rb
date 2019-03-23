module MediaRename

  module Templates
    extend self

    def movie_template
      @movie_template ||= Liquid::Template.parse(SETTINGS['MOVIE_TEMPLATE'], error_mode: :strict)
    end

    def tv_template
      @tv_template ||= Liquid::Template.parse(SETTINGS['TV_TEMPLATE'], error_mode: :strict)
    end

    def render_template(media, options = {})
      movie      = media.movie
      template   = movie.type == 'movie' ? movie_template : tv_template
      attributes = {
        title: movie.title,
        year: movie.year,
        video_format: MediaRename::Media.video_format(media.width, media.height),
        video_codec: MediaRename::Media.video_codec(media.video_codec),
        audio_codec: MediaRename::Media.audio_codec(media.audio_codec, media.audio_channels),
        tags: "",
        ext: media.container
      }
      template.render(attributes.stringify_keys)
    end

  end

end