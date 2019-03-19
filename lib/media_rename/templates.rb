module MediaRename

  module Templates
    extend self

    def movie_template
      @movie_template ||= Liquid::Template.parse(SETTINGS['MOVIE_TEMPLATE'], error_mode: :strict)
    end

    def tv_template
      @tv_template ||= Liquid::Template.parse(SETTINGS['TV_TEMPLATE'], error_mode: :strict)
    end

    def render_movie(movie, mediafile, options = {})
      attributes = {
        title: movie.title,
        year: movie.year,
        video_format: mediafile.video_format,
        video_codec: mediafile.video_codec,
        audio_codec: mediafile.audio_codec,
        tags: mediafile.tags,
        ext: mediafile.ext,
        target_path: options[:target_path]
      }
      movie_template.render(attributes.stringify_keys)
    end

    def render_tv(tv, mediafile, options = {})
      attributes = {
        title: tv.title,
        year: tv.year,
        tv_season: mediafile.tv_season,
        tv_episode: mediafile.tv_episode,
        video_format: mediafile.video_format,
        video_codec: mediafile.video_codec,
        audio_codec: mediafile.audio_codec,
        tags: mediafile.tags,
        ext: mediafile.ext,
        target_path: options[:target_path]
      }
      tv_template.render(attributes.stringify_keys)
    end
  end

end