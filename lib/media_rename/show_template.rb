module MediaRename

  class ShowTemplate < MovieTemplate

    # record => episode
    def initialize(record:, media:, part:)
      @template   = Liquid::Template.parse(SETTINGS['TV_TEMPLATE'], error_mode: :strict)
      @media      = media
      @attributes = {
        title: record.show_title.to_s.gsub(':', '-'),
        year: (record.year rescue ''),
        video_format: MediaRename::Media.video_format(media.width, media.height),
        video_codec: MediaRename::Media.video_codec(media.video_codec),
        audio_codec: MediaRename::Media.audio_codec(media.audio_codec, media.audio_channels),
        tags: "",
        part: part,
        ext: media.container,
        tv_season: record.season,
        tv_episode: record.episode
      }
    end
  end

end