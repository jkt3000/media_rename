module MediaRename

  class ShowTemplate < MovieTemplate

    def initialize(media)
      @template   = Liquid::Template.parse(SETTINGS['TV_TEMPLATE'], error_mode: :strict)
      @media      = media
      @attributes = {
        title: media.parent.show_title.to_s.gsub(':', '-'),
        year: media.parent.try(:year),
        video_format: MediaRename::Media.video_format(media.width, media.height),
        video_codec: MediaRename::Media.video_codec(media.video_codec),
        audio_codec: MediaRename::Media.audio_codec(media.audio_codec, media.audio_channels),
        tags: "",
        ext: media.hash['container'],
        tv_season: media.parent.season,
        tv_episode: media.parent.episode
      }
    end
  end

end